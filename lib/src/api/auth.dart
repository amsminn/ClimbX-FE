import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:dio/dio.dart';
import 'util/core/api_client.dart';
import 'util/auth/token_storage.dart';

/// 인증 관련 API 호출 함수들
class AuthApi {
  static final _apiClient = ApiClient.instance;

  // 헤더 접근용 순수 Dio 인스턴스 (인터셉터 없음)
  static final _pureDio = Dio(
    BaseOptions(
      baseUrl: ApiClient.baseUrl ?? '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// nonce 생성 함수
  static String _generateNonce() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        32,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// 카카오 로그인
  static Future<String> signInWithKakao() async {
    try {
      // nonce 생성
      final nonce = _generateNonce();
      if (kDebugMode) {
        developer.log('생성된 nonce: $nonce', name: 'AuthApi');
      }

      // 카카오톡 설치 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인 시도 (nonce 포함)
          await UserApi.instance.loginWithKakaoTalk(nonce: nonce);
          developer.log('카카오톡으로 로그인 성공', name: 'AuthApi');
        } catch (error) {
          developer.log('카카오톡으로 로그인 실패: $error', name: 'AuthApi');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리
          if (error is PlatformException && error.code == 'CANCELED') {
            throw Exception('카카오 로그인이 취소되었습니다.');
          }

          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount(nonce: nonce);
            developer.log('카카오계정으로 로그인 성공', name: 'AuthApi');
          } catch (error) {
            developer.log('카카오계정으로 로그인 실패: $error', name: 'AuthApi');
            throw Exception('카카오계정으로 로그인에 실패했습니다: $error');
          }
        }
      } else {
        // 카카오톡이 설치되지 않은 경우 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount(nonce: nonce);
          developer.log('카카오계정으로 로그인 성공', name: 'AuthApi');
        } catch (error) {
          developer.log('카카오계정으로 로그인 실패: $error', name: 'AuthApi');
          throw Exception('카카오계정으로 로그인에 실패했습니다: $error');
        }
      }

      // 카카오에서 받은 토큰 정보 가져오기
      final tokenManager = TokenManagerProvider.instance.manager;
      final token = await tokenManager.getToken();

      if (token?.accessToken == null) {
        throw Exception('카카오 토큰을 가져올 수 없습니다.');
      }

      // id_token 추출 및 null 체크
      final idToken = token!.idToken;

      // idToken null 체크 - Kakao OAuth에서 선택적 필드이므로 필수 검증
      if (idToken == null || idToken.isEmpty) {
        developer.log('idToken이 null이거나 비어있음', name: 'AuthApi');
        throw Exception('카카오 ID 토큰을 받을 수 없습니다. 다시 시도해주세요.');
      }

      if (kDebugMode) {
        // 카카오 토큰 정보 전체 출력 (디버그 모드만)
        developer.log('카카오 토큰 정보: ${token.toJson()}', name: 'AuthApi');
        developer.log('id_token: $idToken', name: 'AuthApi');
        developer.log('전송할 nonce: $nonce', name: 'AuthApi');
      }

      // 백엔드로 id_token과 nonce 전송하여 JWT 토큰 받기 (idToken 검증 후)
      // 헤더에서 Refresh-Token을 받기 위해 순수 Dio 사용 (인터셉터 없음)
      final dioResponse = await _pureDio.post(
        '/api/auth/oauth2/kakao/callback',
        data: {'idToken': idToken, 'nonce': nonce},
      );

      if (kDebugMode) {
        developer.log('=== 로그인 응답 헤더 확인 ===', name: 'AuthApi Debug');
        developer.log('응답 헤더들: ${dioResponse.headers.map}', name: 'AuthApi Debug');
        developer.log('Refresh-Token 헤더: ${dioResponse.headers.value('Refresh-Token')}', name: 'AuthApi Debug');
        developer.log('응답 데이터: ${dioResponse.data}', name: 'AuthApi Debug');
        developer.log('============================', name: 'AuthApi Debug');
      }

      // 순수 응답 데이터에서 access token 추출
      final responseData = dioResponse.data;
      
      if (responseData is! Map<String, dynamic>) {
        throw Exception('응답 형식이 올바르지 않습니다: ${responseData.runtimeType}');
      }

      // 백엔드 응답 구조에 맞게 데이터 추출
      Map<String, dynamic> bodyData;
      if (responseData.containsKey('body') && responseData['body'] is Map<String, dynamic>) {
        final body = responseData['body'] as Map<String, dynamic>;
        if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
          bodyData = body['data'] as Map<String, dynamic>;
        } else {
          bodyData = body;
        }
      } else if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        bodyData = responseData['data'] as Map<String, dynamic>;
      } else {
        bodyData = responseData;
      }

      final accessToken = bodyData['accessToken'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('응답에서 accessToken을 찾을 수 없음: $bodyData');
      }

      // 응답 헤더에서 Refresh-Token 추출
      final refreshToken = dioResponse.headers.value('Refresh-Token');
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('응답 헤더에서 Refresh-Token을 찾을 수 없음');
      }

      // 두 토큰 모두 저장
      await TokenStorage.saveTokens(
        accessToken: accessToken as String,
        refreshToken: refreshToken,
      );

      // 로그인 성공 후 사용자 닉네임도 저장
      try {
        final authMeResponse = await _pureDio.get('/api/auth/me');
        final authData = authMeResponse.data;
        
        if (authData is Map<String, dynamic>) {
          final nickname = authData['nickname'] as String?;
          if (nickname != null && nickname.isNotEmpty) {
            await TokenStorage.saveUserNickname(nickname);
            developer.log('사용자 닉네임 저장 완료: $nickname', name: 'AuthApi');
          }
        }
      } catch (e) {
        developer.log('사용자 닉네임 저장 실패: $e', name: 'AuthApi');
        // 닉네임 저장 실패는 로그인 실패로 처리하지 않음
      }

      developer.log('로그인 성공 - 토큰 저장 완료', name: 'AuthApi');
      return accessToken;
    } catch (e) {
      throw Exception('카카오 로그인에 실패했습니다: $e');
    }
  }

  /// 토큰 유효성 검증 API 호출
  static Future<bool> validateToken() async {
    try {
      await _apiClient.get<Map<String, dynamic>>(
        '/api/auth/validate',
        logContext: 'AuthApi',
      );
      return true;
    } catch (e) {
      developer.log('토큰 유효성 검증 실패: $e', name: 'AuthApi');
      return false;
    }
  }

  /// 토큰 갱신 API 호출
  static Future<String> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh Token이 없습니다');
      }

      // 헤더에서 새로운 Refresh-Token을 받기 위해 순수 Dio 사용 (인터셉터 없음)
      final dioResponse = await _pureDio.post(
        '/api/auth/oauth2/refresh',
        options: Options(
          headers: {
            'Refresh-Token': refreshToken,
          },
        ),
      );

      if (kDebugMode) {
        developer.log('=== 토큰 갱신 응답 헤더 확인 ===', name: 'AuthApi Debug');
        developer.log('응답 헤더들: ${dioResponse.headers.map}', name: 'AuthApi Debug');
        developer.log('Refresh-Token 헤더: ${dioResponse.headers.value('Refresh-Token')}', name: 'AuthApi Debug');
        developer.log('응답 데이터: ${dioResponse.data}', name: 'AuthApi Debug');
        developer.log('===============================', name: 'AuthApi Debug');
      }

      // 순수 응답 데이터에서 새로운 access token 추출
      final responseData = dioResponse.data;
      
      if (responseData is! Map<String, dynamic>) {
        throw Exception('토큰 갱신 응답 형식이 올바르지 않습니다: ${responseData.runtimeType}');
      }

      // 백엔드 응답 구조에 맞게 데이터 추출
      Map<String, dynamic> bodyData;
      if (responseData.containsKey('body') && responseData['body'] is Map<String, dynamic>) {
        final body = responseData['body'] as Map<String, dynamic>;
        if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
          bodyData = body['data'] as Map<String, dynamic>;
        } else {
          bodyData = body;
        }
      } else if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        bodyData = responseData['data'] as Map<String, dynamic>;
      } else {
        bodyData = responseData;
      }

      final newAccessToken = bodyData['accessToken'];
      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw Exception('토큰 갱신 실패: accessToken을 찾을 수 없음: $bodyData');
      }

      // 응답 헤더에서 새로운 Refresh-Token 추출
      final newRefreshToken = dioResponse.headers.value('Refresh-Token');
      
      // refresh token 없음
      if (newRefreshToken == null || newRefreshToken.isEmpty) {
        throw Exception('토큰 갱신 실패: 새로운 Refresh Token을 받지 못했습니다. 서버 응답을 확인하세요.');
      }
      
      // 새 토큰들 저장
      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      developer.log('토큰 갱신 성공', name: 'AuthApi');
      return newAccessToken;
    } catch (e) {
      throw Exception('토큰 갱신에 실패했습니다: $e');
    }
  }
}

/// 인증 상태 관리 헬퍼 함수들 (로컬 저장소 기반)
class AuthHelpers {
  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    return await TokenStorage.hasToken();
  }

  /// 로그아웃 (카카오 로그아웃 + 로컬 토큰 삭제)
  static Future<void> signOut() async {
    try {
      // 카카오 로그아웃
      await UserApi.instance.logout();
      developer.log('카카오 로그아웃 성공', name: 'AuthHelpers');
    } catch (e) {
      developer.log('카카오 로그아웃 실패: $e', name: 'AuthHelpers');
    }

    // 로컬 토큰 삭제
    await TokenStorage.clearTokens();
  }

  /// 토큰 삭제 (하위 호환성을 위해 유지)
  static Future<void> clearToken() async {
    await signOut();
  }
}