import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'token_storage.dart';
import '../../auth.dart';
import '../core/response_interceptor.dart';

/// JWT 인증 토큰 인터셉터
class AuthInterceptor {
  // 동시성 처리를 위한 상태 관리
  static bool _isRefreshing = false;
  static final List<Completer<void>> _refreshQueue = [];

  /// 인증 토큰 인터셉터 생성
  static InterceptorsWrapper createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        await _handleRequest(options, handler);
      },
      onResponse: (response, handler) {
        _handleResponse(response, handler);
      },
      onError: (error, handler) async {
        await _handleError(error, handler);
      },
    );
  }

  // 콜백 함수들
  static Function()? _onUnauthorized;

  /// 콜백 함수 설정
  static void setOnUnauthorized(Function()? callback) {
    _onUnauthorized = callback;
  }

  /// Request 인터셉터 핸들러 - JWT 토큰 자동 추가
  static Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 무한 루프 방지: refresh API 호출은 토큰 추가 스킵
      if (options.path.contains('/api/auth/oauth2/refresh')) {
        if (kDebugMode) {
          developer.log('Refresh API 호출 - 토큰 추가 스킵', name: 'AuthInterceptor');
        }
        handler.next(options);
        return;
      }

      // JWT 토큰 자동 추가
      final token = await TokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          developer.log('Access Token 추가됨', name: 'AuthInterceptor');
        }
      } else {
        if (kDebugMode) {
          developer.log(
            'Access Token 없음 - 인증이 필요한 요청일 수 있음',
            name: 'AuthInterceptor',
          );
        }
      }

      // 요청 ID 추가 (디버깅용)
      if (kDebugMode) {
        options.headers['X-Request-ID'] = DateTime.now().millisecondsSinceEpoch
            .toString();
      }

      handler.next(options);
    } catch (e) {
      developer.log('Auth Request 인터셉터 오류: $e', name: 'AuthInterceptor');
      handler.next(options);
    }
  }

  /// Response 인터셉터 핸들러 - 인증 관련 응답 처리
  static void _handleResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final requestId = response.requestOptions.headers['X-Request-ID'];
      developer.log(
        '[${response.statusCode}] ${response.requestOptions.uri} (ID: $requestId)',
        name: 'AuthInterceptor',
      );
    }
    handler.next(response);
  }

  /// Error 인터셉터 핸들러 - 인증 관련 에러 처리
  static Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode ?? 0;

    // 401 Unauthorized 처리
    if (statusCode == 401) {
      developer.log('401 에러 감지 - 토큰 갱신 시도', name: 'AuthInterceptor');

      // refresh API 호출에서 401이 나면 refresh token도 만료된 것
      if (error.requestOptions.path.contains('/api/auth/oauth2/refresh')) {
        developer.log('Refresh Token 만료 - 완전 로그아웃 처리', name: 'AuthInterceptor');
        await _handleCompleteLogout();
        handler.next(error);
        return;
      }

      // 토큰 갱신 시도
      final success = await _attemptTokenRefreshWithQueue();

      if (success) {
        // 갱신 성공 시 원래 요청 재시도
        try {
          final newAccessToken = await TokenStorage.getAccessToken();
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            error.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            // 새로운 Dio 인스턴스로 재시도 (순환 참조 방지)
            // ResponseInterceptor도 포함해야 함
            final retryDio = Dio(
              BaseOptions(
                baseUrl: error.requestOptions.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

            // ResponseInterceptor 추가
            retryDio.interceptors.add(_createResponseInterceptor());

            final response = await retryDio.fetch(error.requestOptions);
            developer.log('토큰 갱신 후 요청 재시도 성공', name: 'AuthInterceptor');
            return handler.resolve(response);
          }
        } catch (retryError) {
          developer.log('재시도 실패: $retryError', name: 'AuthInterceptor');
        }
      }

      // 갱신 실패 시 로그아웃 처리
      await _handleCompleteLogout();
    }
    // 403 Forbidden 처리
    else if (statusCode == 403) {
      developer.log('접근 권한 없음 - 권한 확인 필요', name: 'AuthInterceptor');
    }

    handler.next(error);
  }

  /// 토큰 갱신 시도 (동시성 처리)
  static Future<bool> _attemptTokenRefreshWithQueue() async {
    // 이미 갱신 중이면 대기
    if (_isRefreshing) {
      developer.log('이미 토큰 갱신 중 - 대기 큐에 추가', name: 'AuthInterceptor');
      final completer = Completer<void>();
      _refreshQueue.add(completer);

      try {
        await completer.future;
        // 갱신 완료 후 새 토큰 확인
        final newToken = await TokenStorage.getAccessToken();
        return newToken != null && newToken.isNotEmpty;
      } catch (e) {
        developer.log('대기 중 에러 발생: $e', name: 'AuthInterceptor');
        return false;
      }
    }

    _isRefreshing = true;

    try {
      // AuthApi.refreshToken() 호출
      await AuthApi.refreshToken();

      // 대기 중인 요청들 깨우기
      for (final completer in _refreshQueue) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
      _refreshQueue.clear();

      developer.log('토큰 갱신 성공', name: 'AuthInterceptor');
      return true;
    } catch (e) {
      developer.log('토큰 갱신 실패: $e', name: 'AuthInterceptor');

      // 대기 중인 요청들 에러 처리
      for (final completer in _refreshQueue) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
      _refreshQueue.clear();

      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 완전 로그아웃 처리 - 토큰 삭제 및 콜백 호출
  static Future<void> _handleCompleteLogout() async {
    try {
      await TokenStorage.clearTokens();
      developer.log('만료된 토큰들 삭제 완료', name: 'AuthInterceptor');

      // 콜백 호출 (예: 로그인 페이지로 이동)
      _onUnauthorized?.call();
    } catch (e) {
      developer.log('토큰 삭제 실패: $e', name: 'AuthInterceptor');
    }
  }

  /// 토큰 유효성 검증
  static Future<bool> isTokenValid() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // 토큰 만료 시간 확인 (JWT 디코딩)
      return await TokenStorage.isTokenValid();
    } catch (e) {
      developer.log('토큰 유효성 검증 실패: $e', name: 'AuthInterceptor');
      return false;
    }
  }

  /// 토큰 갱신이 필요한지 확인
  static Future<bool> shouldRefreshToken() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // 토큰 형식 기본 확인
      return await TokenStorage.isTokenValid();
    } catch (e) {
      developer.log('토큰 갱신 확인 실패: $e', name: 'AuthInterceptor');
      return false;
    }
  }

  /// ResponseInterceptor 생성 (재시도용)
  static InterceptorsWrapper _createResponseInterceptor() {
    return ResponseInterceptor.createInterceptor();
  }
}
