import 'dart:developer' as developer;
import 'util/api_client.dart';
import '../models/user_profile.dart';
import '../models/history_data.dart';

/// 사용자 관련 API 호출 함수들
class UserApi {
  static final _dio = ApiClient.instance.dio;

  /// 현재 사용자 프로필 조회 (기존 alice 엔드포인트)
  static Future<UserProfile> getCurrentUserProfile() {
    developer.log('현재 사용자 프로필 조회 시작', name: 'UserApi');
    
    return _dio.get('/api/users/alice')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '사용자 프로필 조회 실패');
        }
        return apiResponse.data as Map<String, dynamic>;
      })
      .then((data) {
        final userProfile = UserProfile.fromJson(data);
        developer.log('사용자 프로필 조회 성공', name: 'UserApi');
        return userProfile;
      })
      .catchError((e) {
        developer.log('사용자 프로필 조회 중 예외 발생: $e', name: 'UserApi');
        throw Exception('프로필 정보를 불러올 수 없습니다: $e');
      });
  }

  /// 편의 메서드: getUserProfile() -> getCurrentUserProfile() 호출
  static Future<UserProfile> getUserProfile() async {
    return await getCurrentUserProfile();
  }

  /// 특정 사용자 프로필 조회 (확장 가능)
  static Future<UserProfile> getUserProfileByUsername(String username) {
    developer.log('사용자 프로필 조회 시작 - $username', name: 'UserApi');
    
    return _dio.get('/api/users/$username')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '사용자 프로필 조회 실패');
        }
        return apiResponse.data as Map<String, dynamic>;
      })
      .then((data) {
        final userProfile = UserProfile.fromJson(data);
        developer.log('사용자 프로필 조회 성공 - $username', name: 'UserApi');
        return userProfile;
      })
      .catchError((e) {
        developer.log('사용자 프로필 조회 중 예외 발생: $e', name: 'UserApi');
        throw Exception('프로필 정보를 불러올 수 없습니다: $e');
      });
  }

  /// 사용자 히스토리 조회 (기존 방식과 동일한 쿼리 파라미터 처리)
  static Future<HistoryData> getUserHistory({
    String username = 'alice',
    String? from,
    String? to,
    String criteria = 'RATING',
  }) {
    developer.log('사용자 히스토리 조회 시작 - $username', name: 'UserApi');

    // 쿼리 파라미터 구성 (기존 UserService와 동일한 방식)
    final queryParams = <String, String>{'criteria': criteria};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    // URL 쿼리 문자열 생성 (기존 방식과 동일)
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    final url = '/api/users/$username/history${queryString.isNotEmpty ? '?$queryString' : ''}';

    return _dio.get(url)
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '히스토리 데이터 조회 실패');
        }
        return apiResponse.data;
      })
      .then((data) {
        // HistoryData는 List<dynamic>을 기대하므로 타입 체크
        if (data is List) {
          return HistoryData.fromJson(data);
        } else {
          developer.log('HistoryData: List가 아닌 데이터, 빈 리스트 사용', name: 'UserApi');
          return HistoryData.fromJson([]);
        }
      })
      .then((historyData) {
        developer.log('사용자 히스토리 조회 성공 - $username', name: 'UserApi');
        return historyData;
      })
      .catchError((e) {
        developer.log('사용자 히스토리 조회 중 예외 발생: $e', name: 'UserApi');
        throw Exception('히스토리 데이터를 불러올 수 없습니다: $e');
      });
  }

  /// 현재 사용자 히스토리 조회 (간편 메서드)
  static Future<HistoryData> getCurrentUserHistory({
    String? from,
    String? to,
    String criteria = 'RATING',
  }) async {
    return await getUserHistory(
      username: 'alice',
      from: from,
      to: to,
      criteria: criteria,
    );
  }
} 