import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import 'util/core/query_params_builder.dart';
import 'util/core/request_body_builder.dart';
import '../models/problem_vote.dart';
import '../models/problem.dart';

/// 문제 난이도 기여(투표) 관련 API
class ProblemVoteApi {
  static final ApiClient _client = ApiClient.instance;

  /// 투표(의견) 목록 조회 - 페이지/사이즈 기반
  static Future<List<ProblemVote>> getVotes({
    required String problemId,
    int page = 0,
    int size = 20,
  }) async {
    developer.log('투표 목록 조회 시작 - problemId: $problemId page=$page size=$size', name: 'ProblemVoteApi');
    final data = await _client.get<List<ProblemVote>>(
      '/api/problems/$problemId/votes',
      queryParameters: QueryParamsBuilder()
          .add('page', page)
          .add('size', size)
          .build(),
      fromJson: (json) => (json as List)
          .map((item) => ProblemVote.fromJson(item as Map<String, dynamic>))
          .toList(),
      logContext: 'ProblemVoteApi',
    );
    return data;
  }

  /// 투표(의견) 생성 - tier 필수, tags 선택, comment 선택
  static Future<Problem> createVote({
    required String problemId,
    required String tier,
    List<String> tags = const [],
    String? comment,
  }) async {
    developer.log('투표 생성 요청 - problemId: $problemId', name: 'ProblemVoteApi');
    final result = await _client.post<Problem>(
      '/api/problems/$problemId/votes',
      data: RequestBodyBuilder()
          .add('tier', tier)
          .addIfNotEmpty('tags', tags)
          .addIfNotEmpty('comment', comment)
          .build(),
      fromJson: (json) => Problem.fromJson(json as Map<String, dynamic>),
      logContext: 'ProblemVoteApi',
    );
    developer.log('투표 생성 완료 - problemId: $problemId', name: 'ProblemVoteApi');
    return result;
  }
}


