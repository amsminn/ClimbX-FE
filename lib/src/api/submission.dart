import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import '../models/submission.dart';
import 'util/auth/token_storage.dart';

/// 제출 관련 API 호출 함수들
class SubmissionApi {
  static final ApiClient _client = ApiClient.instance;

  static Future<void> submit({
    required String videoId,
    required String problemId,
  }) async {
    developer.log('문제 제출 요청 시작 - videoId: $videoId, problemId: $problemId', name: 'SubmissionApi');
    await _client.post<Map<String, dynamic>>(
      '/api/submissions',
      data: {
        'videoId': videoId,
        'problemId': problemId,
      },
      logContext: 'SubmissionApi',
    );
    developer.log('문제 제출 요청 완료', name: 'SubmissionApi');
  }

  /// 제출 목록 조회 (커서 기반)
  static Future<SubmissionPageData> getSubmissions({
    String? cursor,
    int size = 20,
    String? nickname,
  }) async {
    // nickname 필수: 없으면 TokenStorage 또는 /api/auth/me 로 획득
    String? finalNickname = nickname ?? await TokenStorage.getUserNickname();
    if (finalNickname == null || finalNickname.isEmpty) {
      final me = await _client.get<Map<String, dynamic>>(
        '/api/auth/me',
        logContext: 'SubmissionApi',
      );
      final fetchedNickname = me['nickname'] as String?;
      if (fetchedNickname == null || fetchedNickname.isEmpty) {
        throw Exception('현재 사용자의 nickname을 찾을 수 없습니다');
      }
      await TokenStorage.saveUserNickname(fetchedNickname);
      finalNickname = fetchedNickname;
    }

    final query = <String, dynamic>{
      'nickname': finalNickname,
      'size': size,
      if (cursor != null) 'cursor': cursor,
    };

    final data = await _client.get<SubmissionPageData>(
      '/api/submissions',
      queryParameters: query,
      fromJson: (json) => SubmissionPageData.fromJson(json as Map<String, dynamic>),
      logContext: 'SubmissionApi',
    );
    return data;
  }
}

