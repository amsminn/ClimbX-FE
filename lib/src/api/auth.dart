import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import 'util/auth/token_storage.dart';

/// 인증 관련 API 호출 함수들
class AuthApi {
  static final _apiClient = ApiClient.instance;

  /// Google OAuth 로그인 API 호출
  static Future<String> signInWithGoogle() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/auth/oauth2/GOOGLE/callback',
        queryParameters: {'code': 'testCode'},
        logContext: 'AuthApi',
      );
      
      final token = response['accessToken'];
      if (token == null || token.isEmpty) {
        throw Exception('응답에서 accessToken을 찾을 수 없음');
      }
      
      return token as String;
    } catch (e) {
      throw Exception('Google 로그인에 실패했습니다: $e');
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
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        logContext: 'AuthApi',
      );
      
      final newToken = response['accessToken'];
      if (newToken == null || newToken.isEmpty) {
        throw Exception('토큰 갱신 실패: accessToken을 찾을 수 없음');
      }
      
      return newToken as String;
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

  /// 토큰 삭제
  static Future<void> clearToken() async {
    await TokenStorage.clearToken();
  }
} 