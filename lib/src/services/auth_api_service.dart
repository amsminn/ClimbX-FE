import 'dart:developer' as developer;
import 'api_client.dart';

/// 인증 관련 API 호출 전담 서비스
class AuthApiService {
  static final _apiClient = ApiClient.instance;

  /// Google OAuth 토큰 발급 API 호출
  static Future<String?> requestGoogleOAuthToken() async {
    try {
      developer.log('Google OAuth 토큰 발급 API 호출 시작', name: 'AuthApiService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/auth/oauth2/GOOGLE/callback',
        queryParameters: {'code': 'testCode'},
        needsAuth: false,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        developer.log('OAuth API 응답: $data', name: 'AuthApiService');

        final token = data['accessToken'];
        final tokenType = data['tokenType'];
        final expiresIn = data['expiresIn'];

        if (token != null) {
          developer.log(
            'OAuth 토큰 발급 성공 - Type: $tokenType, ExpiresIn: $expiresIn',
            name: 'AuthApiService',
          );
          return token;
        } else {
          developer.log('응답에서 accessToken을 찾을 수 없음', name: 'AuthApiService');
          return null;
        }
      } else {
        developer.log('OAuth API 호출 실패: ${response.error}', name: 'AuthApiService');
        return null;
      }
    } catch (e) {
      developer.log('OAuth API 호출 중 예외 발생: $e', name: 'AuthApiService');
      return null;
    }
  }

  /// 토큰 유효성 검증 API 호출 (서버에서 검증)
  static Future<bool> validateToken(String token) async {
    try {
      developer.log('토큰 유효성 검증 API 호출', name: 'AuthApiService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/auth/validate',
        needsAuth: true, // 검증할 토큰을 헤더에 포함
      );

      if (response.success) {
        developer.log('토큰 유효성 검증 성공', name: 'AuthApiService');
        return true;
      } else {
        developer.log('토큰 유효성 검증 실패: ${response.error}', name: 'AuthApiService');
        return false;
      }
    } catch (e) {
      developer.log('토큰 유효성 검증 중 예외 발생: $e', name: 'AuthApiService');
      return false;
    }
  }

  /// 토큰 갱신 API 호출
  static Future<String?> refreshToken() async {
    try {
      developer.log('토큰 갱신 API 호출', name: 'AuthApiService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        needsAuth: true,
      );

      if (response.success && response.data != null) {
        final newToken = response.data!['accessToken'];
        if (newToken != null) {
          developer.log('토큰 갱신 성공', name: 'AuthApiService');
          return newToken;
        }
      }

      developer.log('토큰 갱신 실패: ${response.error}', name: 'AuthApiService');
      return null;
    } catch (e) {
      developer.log('토큰 갱신 중 예외 발생: $e', name: 'AuthApiService');
      return null;
    }
  }
} 