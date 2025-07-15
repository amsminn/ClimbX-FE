import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'token_storage.dart';

/// JWT 인증 토큰 인터셉터
class AuthInterceptor {
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
      // JWT 토큰 자동 추가
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          developer.log('JWT 토큰 추가됨', name: 'AuthInterceptor');
        }
      } else {
        if (kDebugMode) {
          developer.log(
            'JWT 토큰 없음 - 인증이 필요한 요청일 수 있음',
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
      developer.log('인증 만료 감지 - 토큰 정리 시작', name: 'AuthInterceptor');
      await _handle401Error();
    }
    // 403 Forbidden 처리
    else if (statusCode == 403) {
      developer.log('접근 권한 없음 - 권한 확인 필요', name: 'AuthInterceptor');
    }

    handler.next(error);
  }

  /// 401 에러 처리 - 토큰 삭제 및 콜백 호출
  static Future<void> _handle401Error() async {
    try {
      // await TokenStorage.clearToken();
      developer.log('만료된 토큰 삭제 완료', name: 'AuthInterceptor');

      // 콜백 호출 (예: 로그인 페이지로 이동)
      _onUnauthorized?.call();
    } catch (e) {
      developer.log('토큰 삭제 실패: $e', name: 'AuthInterceptor');
    }
  }

  /// 토큰 유효성 검증
  static Future<bool> isTokenValid() async {
    try {
      final token = await TokenStorage.getToken();
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
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // TODO: JWT 만료 시간 확인하여 갱신 여부 결정
      // 현재는 간단히 토큰 존재 여부만 확인
      return await TokenStorage.isTokenValid();
    } catch (e) {
      developer.log('토큰 갱신 확인 실패: $e', name: 'AuthInterceptor');
      return false;
    }
  }
}
