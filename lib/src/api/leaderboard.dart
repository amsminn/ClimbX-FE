import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import '../models/leaderboard_item.dart';
import '../utils/leaderboard_type.dart';
import '../utils/tier_colors.dart';

/// 리더보드 관련 API 호출 함수들
class LeaderboardApi {
  static final _apiClient = ApiClient.instance;

  // API 응답 데이터 키값 상수 정의
  static const String _keyRating = 'rating';
  static const String _keyCurrentStreak = 'currentStreak';
  static const String _keyLongestStreak = 'longestStreak';
  static const String _keySolvedCount = 'solvedCount';
  static const String _keyRankingList = 'rankings';

  // Criteria 값 상수 정의 (switch문에서 사용하기 위해)
  static const String _criteriaRating = 'rating';
  static const String _criteriaStreak = 'current_streak';
  static const String _criteriaLongestStreak = 'longest_streak';
  static const String _criteriaSolvedProblems = 'solved_count';

  /// 리더보드 조회
  /// 서버 규격: /api/ranking/users?criteria=...&page=0&size=10&sort=desc
  static Future<List<LeaderboardItem>> getRanking({
    required LeaderboardType type,
    String order = 'desc',
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/ranking/users',
        queryParameters: {
          'criteria': type.criteria,
          'sort': order, // desc | asc
          'page': page,
          'size': size,
        },
        logContext: 'LeaderboardApi',
      );

      final rankingListData = response[_keyRankingList] as List<dynamic>? ?? [];

      // LeaderboardItem 리스트로 변환
      final users = rankingListData.asMap().entries.map((entry) {
        final index = entry.key;
        final userData = entry.value as Map<String, dynamic>;

        // 프론트엔드에서 계산되는 값들
        final tier = TierColors.getTierStringFromRating(
          userData[_keyRating] ?? 0,
        );
        final value = _getValueByCriteria(userData, type.criteria);

        return LeaderboardItem.fromJson(
          userData,
          tier: tier,
          value: value,
        );
      }).toList();

      developer.log('리더보드 조회 성공 - ${users.length}명 조회', name: 'LeaderboardApi');

      return users;
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('리더보드 조회 실패: $e', name: 'LeaderboardApi', error: e);
      throw Exception('리더보드 정보를 불러올 수 없습니다');
    }
  }

  /// criteria에 따라 적절한 value를 선택하는 헬퍼 메서드
  static String _getValueByCriteria(
    Map<String, dynamic> userData,
    String criteria,
  ) {
    switch (criteria) {
      case _criteriaRating:
        return (userData[_keyRating] ?? 0).toString();
      case _criteriaStreak:
        return (userData[_keyCurrentStreak] ?? 0).toString();
      case _criteriaLongestStreak:
        return (userData[_keyLongestStreak] ?? 0).toString();
      case _criteriaSolvedProblems:
        final count = userData[_keySolvedCount] ?? 0;
        return count.toString();
      default:
        return (userData[_keyRating] ?? 0).toString();
    }
  }
}
