import 'dart:developer' as developer;
import '../core/api_client.dart';
import 'token_storage.dart';

/// 사용자 식별 헬퍼: 닉네임을 캐시에서 가져오거나 서버에서 조회하여 저장 후 반환
class UserIdentity {
  static final ApiClient _apiClient = ApiClient.instance;

  /// 저장된 닉네임이 있으면 반환하고, 없으면 /api/auth/me로 조회 후 저장하여 반환
  static Future<String> getOrFetchNickname({String logContext = 'UserIdentity'}) async {
    // 1) 캐시 확인
    final String? nickname = await TokenStorage.getUserNickname();
    if (nickname != null && nickname.isNotEmpty) return nickname;

    // 2) 서버에서 조회
    developer.log('저장된 닉네임이 없음 - /api/auth/me 호출', name: logContext);
    final me = await _apiClient.get<Map<String, dynamic>>(
      '/api/auth/me',
      logContext: logContext,
    );
    final fetchedNickname = me['nickname'] as String?;
    if (fetchedNickname == null || fetchedNickname.isEmpty) {
      throw Exception('현재 사용자의 nickname을 찾을 수 없습니다');
    }

    // 3) 캐시에 저장 후 반환
    await TokenStorage.saveUserNickname(fetchedNickname);
    developer.log('닉네임 저장 완료: $fetchedNickname', name: logContext);
    return fetchedNickname;
  }
}

