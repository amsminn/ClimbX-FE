import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'util/api_client.dart';
import 'util/token_storage.dart';

/// 인증 관련 API 호출 함수들
class AuthApi {
  static final _dio = ApiClient.instance.dio;

  /// Google OAuth 로그인 API 호출
  static final signInWithGoogle = () {
    developer.log('Google OAuth 로그인 API 호출 시작', name: 'AuthApi');
    
    return _dio.get(
      '/api/auth/oauth2/GOOGLE/callback',
      queryParameters: {'code': 'testCode'},
    )
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? 'OAuth API 호출 실패');
        }
        return apiResponse.data as Map<String, dynamic>;
      })
      .then((data) {
        final token = data['accessToken'];
        if (token == null || token.isEmpty) {
          throw Exception('응답에서 accessToken을 찾을 수 없음');
        }
        developer.log('OAuth 토큰 발급 성공', name: 'AuthApi');
        return token as String;
      })
      .catchError((e) {
        developer.log('OAuth API 호출 중 예외 발생: $e', name: 'AuthApi');
        throw Exception('Google 로그인에 실패했습니다: $e');
      });
  };

  /// 토큰 유효성 검증 API 호출
  static final validateToken = () {
    developer.log('토큰 유효성 검증 API 호출', name: 'AuthApi');
    
    return _dio.get('/api/auth/validate')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (apiResponse.success) {
          developer.log('토큰 유효성 검증 성공', name: 'AuthApi');
          return true;
        } else {
          developer.log('토큰 유효성 검증 실패: ${apiResponse.error}', name: 'AuthApi');
          return false;
        }
      })
      .catchError((e) {
        developer.log('토큰 유효성 검증 중 예외 발생: $e', name: 'AuthApi');
        return false;
      });
  };

  /// 토큰 갱신 API 호출
  static final refreshToken = () {
    developer.log('토큰 갱신 API 호출', name: 'AuthApi');
    
    return _dio.post('/api/auth/refresh')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '토큰 갱신 실패');
        }
        return apiResponse.data as Map<String, dynamic>;
      })
      .then((data) {
        final newToken = data['accessToken'];
        if (newToken == null || newToken.isEmpty) {
          throw Exception('토큰 갱신 실패: accessToken을 찾을 수 없음');
        }
        developer.log('토큰 갱신 성공', name: 'AuthApi');
        return newToken as String;
      })
      .catchError((e) {
        developer.log('토큰 갱신 중 예외 발생: $e', name: 'AuthApi');
        throw Exception('토큰 갱신에 실패했습니다: $e');
      });
  };
}

/// 인증 상태 관리 헬퍼 함수들 (로컬 저장소 기반)
class AuthHelpers {
  /// 로그인 상태 확인
  static final isLoggedIn = () async {
    return await TokenStorage.hasToken();
  };

  /// 토큰 삭제
  static final clearToken = () async {
    await TokenStorage.clearToken();
  };
} 