import 'dart:developer' as developer;
import 'token_storage.dart';
import 'api_client.dart';

/// 인증 관련 모든 로직 담당 (API 호출 + 비즈니스 로직)
class AuthService {
  static final _apiClient = ApiClient.instance;
  
  /// AuthService 초기화 - ApiClient의 401 에러 콜백 설정
  static void initialize() {
    _apiClient.onUnauthorized = () async {
      developer.log('API에서 401 에러 발생 - 토큰 정리 시작', name: 'AuthService');
      await TokenStorage.clearToken();
    };
  }

  /// Google OAuth 로그인
  static Future<String?> signInWithGoogle() async {
    try {
      developer.log('Google OAuth 로그인 시작', name: 'AuthService');

      // 1. API를 통해 토큰 발급
      final token = await _requestGoogleOAuthToken();

      // 토큰 발급 실패 시 바로 리턴
      if (token == null) {
        developer.log('Google OAuth 로그인 실패: 토큰 발급 실패', name: 'AuthService');
        return null;
      }

      // 2. 토큰 저장
      await TokenStorage.saveToken(token);
      developer.log('Google OAuth 로그인 완료', name: 'AuthService');
      return token;
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
      if (token == null) {
        return false;
      }

      final isServerValid = await _validateToken(token);
      if (!isServerValid) {
        developer.log('토큰 서버 검증 실패 - 토큰 삭제', name: 'AuthService');
        await TokenStorage.clearToken();
      }
      return isServerValid;
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
      final newToken = await _refreshToken();

      // 갱신 실패 시 바로 리턴
      if (newToken == null) {
        developer.log('토큰 갱신 실패 - 기존 토큰 삭제', name: 'AuthService');
        await TokenStorage.clearToken();
        return null;
      }

      // 2. 새 토큰 저장
      await TokenStorage.saveToken(newToken);
      developer.log('토큰 갱신 완료', name: 'AuthService');
      return newToken;
    } catch (e) {
      developer.log('토큰 갱신 중 예외 발생: $e', name: 'AuthService');
      return null;
    }
  }

  // ========== 내부 API 호출 메서드들 ==========

  /// Google OAuth 토큰 발급 API 호출 (내부 메서드)
  static Future<String?> _requestGoogleOAuthToken() async {
    try {
      developer.log('Google OAuth 토큰 발급 API 호출 시작', name: 'AuthService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/auth/oauth2/GOOGLE/callback',
        queryParameters: {'code': 'testCode'},
      );

      // API 호출 실패 시 바로 리턴
      if (!response.success || response.data == null) {
        developer.log('OAuth API 호출 실패: ${response.error}', name: 'AuthService');
        return null;
      }

      final data = response.data!;
      developer.log('OAuth API 응답: $data', name: 'AuthService');

      final token = data['accessToken'];
      final tokenType = data['tokenType'];
      final expiresIn = data['expiresIn'];

      // 토큰이 없으면 바로 리턴
      if (token == null) {
        developer.log('응답에서 accessToken을 찾을 수 없음', name: 'AuthService');
        return null;
      }

      developer.log(
        'OAuth 토큰 발급 성공 - Type: $tokenType, ExpiresIn: $expiresIn',
        name: 'AuthService',
      );
      return token;
    } catch (e) {
      developer.log('OAuth API 호출 중 예외 발생: $e', name: 'AuthService');
      return null;
    }
  }

  /// 토큰 유효성 검증 API 호출 (내부 메서드)
  static Future<bool> _validateToken(String token) async {
    try {
      developer.log('토큰 유효성 검증 API 호출', name: 'AuthService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/auth/validate',
      );

      if (response.success) {
        developer.log('토큰 유효성 검증 성공', name: 'AuthService');
        return true;
      } else {
        developer.log('토큰 유효성 검증 실패: ${response.error}', name: 'AuthService');
        return false;
      }
    } catch (e) {
      developer.log('토큰 유효성 검증 중 예외 발생: $e', name: 'AuthService');
      return false;
    }
  }

  /// 토큰 갱신 API 호출 (내부 메서드)
  static Future<String?> _refreshToken() async {
    try {
      developer.log('토큰 갱신 API 호출', name: 'AuthService');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/auth/refresh',
      );

      // API 호출 실패 시 바로 리턴
      if (!response.success || response.data == null) {
        developer.log('토큰 갱신 실패: ${response.error}', name: 'AuthService');
        return null;
      }

      final newToken = response.data!['accessToken'];
      if (newToken == null) {
        developer.log('토큰 갱신 실패: accessToken을 찾을 수 없음', name: 'AuthService');
        return null;
      }

      developer.log('토큰 갱신 성공', name: 'AuthService');
      return newToken;
    } catch (e) {
      developer.log('토큰 갱신 중 예외 발생: $e', name: 'AuthService');
      return null;
    }
  }
}
