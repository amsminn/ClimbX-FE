import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

/// JWT 토큰 저장소 - 토큰 관리만 담당
class TokenStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _userNicknameKey = 'user_nickname'; // 사용자 닉네임 저장용

  /// Access Token, Refresh Token, 사용자 닉네임 동시 저장
  static Future<void> saveTokensAndUserInfo({
    required String accessToken,
    required String refreshToken,
    required String nickname,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _userNicknameKey, value: nickname),
    ]);
    developer.log('Access Token, Refresh Token, 사용자 닉네임이 저장되었습니다', name: 'TokenStorage');
  }

  /// Access Token 저장 (개별)
  static Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
    developer.log('Access Token이 저장되었습니다', name: 'TokenStorage');
  }

  /// Refresh Token 저장 (개별)
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
    developer.log('Refresh Token이 저장되었습니다', name: 'TokenStorage');
  }

  /// 사용자 닉네임 저장 (개별)
  static Future<void> saveUserNickname(String nickname) async {
    await _secureStorage.write(key: _userNicknameKey, value: nickname);
    developer.log('사용자 닉네임이 저장되었습니다', name: 'TokenStorage');
  }

  /// 사용자 닉네임 가져오기
  static Future<String?> getUserNickname() async {
    return await _secureStorage.read(key: _userNicknameKey);
  }

  /// Access Token과 Refresh Token 동시 저장 (기존 메서드 유지)
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    developer.log('Access Token과 Refresh Token이 저장되었습니다', name: 'TokenStorage');
  }

  /// Access Token 가져오기
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Refresh Token 가져오기
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// 모든 토큰과 사용자 정보 삭제
  static Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userNicknameKey),
    ]);
    developer.log('모든 토큰과 사용자 정보가 삭제되었습니다', name: 'TokenStorage');
  }

  /// 토큰 존재 여부 확인 (Access Token 기준)
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 토큰 유효성 간단 검증 (형식만 체크)
  static Future<bool> isTokenValid() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    
    // JWT 형식 기본 검증 (3개 부분으로 나뉘어져 있는지)
    final parts = token.split('.');
    return parts.length == 3;
  }

  // === 하위 호환성을 위한 기존 메서드들 ===
  
  /// 토큰 저장 (기존 메서드 - Access Token만)
  static Future<void> saveToken(String token) => saveAccessToken(token);

  /// 저장된 토큰 가져오기 (기존 메서드 - Access Token)
  static Future<String?> getToken() => getAccessToken();

  /// 토큰 삭제 (기존 메서드 - 모든 토큰 삭제)
  static Future<void> clearToken() => clearTokens();
} 