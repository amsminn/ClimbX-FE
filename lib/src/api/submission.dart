import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import 'util/core/query_params_builder.dart';
import '../models/submission.dart';
import 'util/auth/user_identity.dart';

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
    // nickname 우선 사용, 없으면 헬퍼로 조회
    final String finalNickname =
        nickname ?? await UserIdentity.getOrFetchNickname(logContext: 'SubmissionApi');

    final data = await _client.get<SubmissionPageData>(
      '/api/submissions',
      queryParameters: QueryParamsBuilder()
          .add('nickname', finalNickname)
          .add('size', size)
          .add('cursor', cursor)
          .build(),
      fromJson: (json) => SubmissionPageData.fromJson(json as Map<String, dynamic>),
      logContext: 'SubmissionApi',
    );
    return data;
  }
}

