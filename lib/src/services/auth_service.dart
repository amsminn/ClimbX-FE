import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  // Mock API base URL
  static const String _baseUrl = 'http://54.180.64.110:8080';

  /// Google OAuth로 토큰 발급 받기 (Mock 이라서 나중에 바꿔야 함)
  static Future<String?> signInWithGoogle() async {
          try {
        // log
        developer.log('Google OAuth 토큰 발급 시작...', name: 'AuthService');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/oauth2/GOOGLE/callback?code=testCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
        developer.log('API 호출 실패: ${response.statusCode}, Body: ${response.body}', name: 'AuthService');
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
