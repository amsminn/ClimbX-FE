import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

/// JWT 토큰 저장소 - 토큰 관리만 담당
class TokenStorage {
  static const FlutterSecureStorage _secure_storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  /// 토큰 저장
  static Future<void> saveToken(String token) async {
    await _secure_storage.write(key: _tokenKey, value: token);
    developer.log('토큰이 안전하게 저장되었습니다', name: 'TokenStorage');
  }

  /// 저장된 토큰 가져오기
  static Future<String?> getToken() async {
    return await _secure_storage.read(key: _tokenKey);
  }

  /// 토큰 삭제
  static Future<void> clearToken() async {
    await _secure_storage.delete(key: _tokenKey);
    developer.log('토큰이 삭제되었습니다', name: 'TokenStorage');
  }

  /// 토큰 존재 여부 확인
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 토큰 유효성 간단 검증 (형식만 체크)
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    
    // JWT 형식 기본 검증 (3개 부분으로 나뉘어져 있는지)
    final parts = token.split('.');
    return parts.length == 3;
  }
} 