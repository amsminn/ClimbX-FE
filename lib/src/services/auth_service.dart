import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  /// Google OAuth로 토큰 발급 받기 (Mock 이라서 나중에 바꿔야 함)
  static Future<String?> signInWithGoogle() async {
    try {
      developer.log('Google OAuth 토큰 발급 시작...', name: 'AuthService');

      // ApiClient를 사용하여 API 호출
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/auth/oauth2/GOOGLE/callback',
        queryParameters: {'code': 'testCode'},
        needsAuth: false,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        developer.log('API 응답: $data', name: 'AuthService');

        final token = data['accessToken']; // accessToken 필드 사용
        final tokenType = data['tokenType']; // Bearer
        final expiresIn = data['expiresIn']; // 3600

        if (token != null) {
          await _saveToken(token);
          developer.log('토큰 발급 및 저장 성공 - Type: $tokenType, ExpiresIn: $expiresIn', name: 'AuthService');
          // 임시 출력용 (나중에 지울 것)
          developer.log('발급받은 토큰 내용: $token', name: 'AuthService');
          return token;
        } else {
          developer.log('응답에서 accessToken을 찾을 수 없음', name: 'AuthService');
          return null;
        }
      } else {
        developer.log('OAuth 토큰 발급 실패: ${response.error}', name: 'AuthService');
        return null;
      }
    } catch (e) {
      developer.log('OAuth 토큰 발급 실패: $e', name: 'AuthService');
      return null;
    }
  }

  /// 토큰 저장
  static Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    developer.log('토큰이 안전하게 저장되었습니다', name: 'AuthService'); // log 추가 (나중에 지움)
  }

  /// 저장된 토큰 가져오기
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// 토큰 삭제 (로그아웃)
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
