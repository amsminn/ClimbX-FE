import 'dart:developer' as developer;
import 'token_storage.dart';
import 'auth_api_service.dart';

/// 인증 비즈니스 로직 담당
class AuthService {
  /// Google OAuth 로그인
  static Future<String?> signInWithGoogle() async {
    try {
      developer.log('Google OAuth 로그인 시작', name: 'AuthService');

      // 1. API를 통해 토큰 발급
      final token = await AuthApiService.requestGoogleOAuthToken();

      if (token != null) {
        // 2. 토큰 저장
        await TokenStorage.saveToken(token);
        developer.log('Google OAuth 로그인 완료', name: 'AuthService');
        return token;
      } else {
        developer.log('Google OAuth 로그인 실패: 토큰 발급 실패', name: 'AuthService');
        return null;
      }
    } catch (e) {
      developer.log('Google OAuth 로그인 중 예외 발생: $e', name: 'AuthService');
      return null;
    }
  }

  /// 로그아웃 (토큰 삭제)
  static Future<void> logout() async {
    try {
      developer.log('로그아웃 시작', name: 'AuthService');
      await TokenStorage.clearToken();
      developer.log('로그아웃 완료', name: 'AuthService');
    } catch (e) {
      developer.log('로그아웃 중 예외 발생: $e', name: 'AuthService');
    }
  }

  /// 로그인 상태 확인 (토큰 존재 여부)
  static Future<bool> isLoggedIn() async {
    return await TokenStorage.hasToken();
  }

  /// 저장된 토큰 가져오기 (다른 서비스에서 사용)
  static Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }

  /// 토큰 삭제 (다른 서비스에서 사용 - 예: API 401 에러 시)
  static Future<void> clearToken() async {
    await TokenStorage.clearToken();
  }

  /// 토큰 유효성 검증 (로컬 + 서버)
  static Future<bool> validateCurrentToken() async {
    try {
      // 1. 로컬에서 토큰 형식 검증
      final isLocalValid = await TokenStorage.isTokenValid();
      if (!isLocalValid) {
        developer.log('토큰 로컬 검증 실패', name: 'AuthService');
        return false;
      }

      // 2. 서버에서 토큰 유효성 검증
      final token = await TokenStorage.getToken();
      if (token != null) {
        final isServerValid = await AuthApiService.validateToken(token);
        if (!isServerValid) {
          developer.log('토큰 서버 검증 실패 - 토큰 삭제', name: 'AuthService');
          await TokenStorage.clearToken();
        }
        return isServerValid;
      }

      return false;
    } catch (e) {
      developer.log('토큰 검증 중 예외 발생: $e', name: 'AuthService');
      return false;
    }
  }

  /// 토큰 자동 갱신
  static Future<String?> refreshTokenIfNeeded() async {
    try {
      developer.log('토큰 갱신 시도', name: 'AuthService');

      // 1. API를 통해 토큰 갱신
      final newToken = await AuthApiService.refreshToken();

      if (newToken != null) {
        // 2. 새 토큰 저장
        await TokenStorage.saveToken(newToken);
        developer.log('토큰 갱신 완료', name: 'AuthService');
        return newToken;
      } else {
        // 갱신 실패 시 기존 토큰 삭제
        developer.log('토큰 갱신 실패 - 기존 토큰 삭제', name: 'AuthService');
        await TokenStorage.clearToken();
        return null;
      }
    } catch (e) {
      developer.log('토큰 갱신 중 예외 발생: $e', name: 'AuthService');
      return null;
    }
  }
}
