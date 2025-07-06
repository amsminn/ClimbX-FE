import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import '../models/user_profile.dart';
import '../models/history_data.dart';
import '../models/streak_data.dart';

/// 사용자 관련 API 호출 함수들
class UserApi {
  static final _apiClient = ApiClient.instance;

  /// 현재 사용자 프로필 조회 (기존 alice 엔드포인트)
  static Future<UserProfile> getCurrentUserProfile() async {
    try {
      return await _apiClient.get<UserProfile>(
        '/api/users/alice',
        fromJson: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('프로필 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('프로필 정보를 불러올 수 없습니다');
    }
  }

  /// 편의 메서드: getUserProfile() -> getCurrentUserProfile() 호출
  static Future<UserProfile> getUserProfile() async {
    return await getCurrentUserProfile();
  }

  /// 특정 사용자 프로필 조회 (확장 가능)
  static Future<UserProfile> getUserProfileByNickname(String nickname) async {
    try {
      return await _apiClient.get<UserProfile>(
        '/api/users/$nickname',
        fromJson: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('프로필 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('프로필 정보를 불러올 수 없습니다');
    }
  }

  /// 사용자 히스토리 조회 (queryParameters 방식 사용)
  static Future<HistoryData> getUserHistory({
    String nickname = 'alice',
    String? from,
    String? to,
    String criteria = 'RATING',
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{'criteria': criteria};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final data = await _apiClient.get<dynamic>(
        '/api/users/$nickname/history',
        queryParameters: queryParams,
        logContext: 'UserApi',
      );

      return HistoryData.fromJson(data);
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('히스토리 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('히스토리 데이터를 불러올 수 없습니다');
    }
  }

  /// 현재 사용자 히스토리 조회 (간편 메서드)
  static Future<HistoryData> getCurrentUserHistory({
    String? from,
    String? to,
    String criteria = 'RATING',
  }) async {
    return await getUserHistory(
      nickname: 'alice',
      from: from,
      to: to,
      criteria: criteria,
    );
  }

  /// 사용자 스트릭 조회 (queryParameters 방식 사용)
  static Future<StreakData> getUserStreak({
    String nickname = 'alice',
    String? from,
    String? to,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final data = await _apiClient.get<dynamic>(
        '/api/users/$nickname/streak',
        queryParameters: queryParams,
        logContext: 'UserApi',
      );

      return StreakData.fromJson(data);
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('스트릭 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('스트릭 데이터를 불러올 수 없습니다');
    }
  }

  /// 현재 사용자 스트릭 조회 (간편 메서드)
  static Future<StreakData> getCurrentUserStreak({
    String? from,
    String? to,
  }) async {
    return await getUserStreak(
      nickname: 'alice',
      from: from,
      to: to,
    );
  }
} 