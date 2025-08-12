import 'dart:developer' as developer;
import 'util/core/api_client.dart';

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
}

