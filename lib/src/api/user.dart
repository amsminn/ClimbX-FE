import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import '../models/user_profile.dart';
import '../models/history_data.dart';
import '../models/streak_data.dart';
import 'util/auth/token_storage.dart'; // TokenStorage import 수정

/// 사용자 관련 API 호출 함수들
class UserApi {
  static final _apiClient = ApiClient.instance;

  /// 현재 사용자 프로필 조회 (JWT 토큰 기반)
  static Future<UserProfile> getCurrentUserProfile() async {
    try {
      // 저장된 닉네임 확인
      String? nickname = await TokenStorage.getUserNickname();
      
      // 저장된 닉네임이 없으면 /api/auth/me로 조회 후 저장
      if (nickname == null || nickname.isEmpty) {
        developer.log('저장된 닉네임이 없음 - /api/auth/me 호출', name: 'UserApi');
        
        final authResponse = await _apiClient.get<Map<String, dynamic>>(
          '/api/auth/me',
          logContext: 'UserApi',
        );

        nickname = authResponse['nickname'] as String?;
        if (nickname == null || nickname.isEmpty) {
          throw Exception('현재 사용자의 nickname을 찾을 수 없습니다');
        }

        // 닉네임 저장 (다음번에는 바로 사용)
        await TokenStorage.saveUserNickname(nickname);
        developer.log('닉네임 저장 완료: $nickname', name: 'UserApi');
      }

      developer.log('사용자 프로필 조회 - nickname: $nickname', name: 'UserApi');

      // /api/users/{nickname}으로 상세 프로필 조회
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

  /// 현재 사용자 히스토리 조회 (JWT 토큰 기반)
  static Future<HistoryData> getCurrentUserHistory({
    String? from,
    String? to,
    String criteria = 'RATING',
  }) async {
    try {
      // 저장된 닉네임 확인
      String? nickname = await TokenStorage.getUserNickname();
      
      // 저장된 닉네임이 없으면 /api/auth/me로 조회 후 저장
      if (nickname == null || nickname.isEmpty) {
        developer.log('저장된 닉네임이 없음 - /api/auth/me 호출', name: 'UserApi');
        
        final authResponse = await _apiClient.get<Map<String, dynamic>>(
          '/api/auth/me',
          logContext: 'UserApi',
        );

        nickname = authResponse['nickname'] as String?;
        if (nickname == null || nickname.isEmpty) {
          throw Exception('현재 사용자의 nickname을 찾을 수 없습니다');
        }

        // 닉네임 저장 (다음번에는 바로 사용)
        await TokenStorage.saveUserNickname(nickname);
        developer.log('닉네임 저장 완료: $nickname', name: 'UserApi');
      }

      developer.log('사용자 히스토리 조회 - nickname: $nickname', name: 'UserApi');

      // /api/users/{nickname}/history로 히스토리 조회
      final queryParams = <String, String>{'criteria': criteria};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      return await _apiClient.get<HistoryData>(
        '/api/users/$nickname/history',
        queryParameters: queryParams,
        fromJson: (data) => HistoryData.fromJson(data as List<dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('히스토리 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('히스토리 데이터를 불러올 수 없습니다');
    }
  }

  /// 특정 사용자 히스토리 조회 (queryParameters 방식 사용)
  static Future<HistoryData> getUserHistory({
    String nickname = 'alice', // 테스트용 기본값
    String? from,
    String? to,
    String criteria = 'RATING',
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{'criteria': criteria};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      return await _apiClient.get<HistoryData>(
        '/api/users/$nickname/history',
        queryParameters: queryParams,
        fromJson: (data) => HistoryData.fromJson(data as List<dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('히스토리 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('히스토리 데이터를 불러올 수 없습니다');
    }
  }

  /// 현재 사용자 스트릭 조회 (JWT 토큰 기반)
  static Future<StreakData> getCurrentUserStreak({
    String? from,
    String? to,
  }) async {
    try {
      // 저장된 닉네임 확인
      String? nickname = await TokenStorage.getUserNickname();
      
      // 저장된 닉네임이 없으면 /api/auth/me로 조회 후 저장
      if (nickname == null || nickname.isEmpty) {
        developer.log('저장된 닉네임이 없음 - /api/auth/me 호출', name: 'UserApi');
        
        final authResponse = await _apiClient.get<Map<String, dynamic>>(
          '/api/auth/me',
          logContext: 'UserApi',
        );

        nickname = authResponse['nickname'] as String?;
        if (nickname == null || nickname.isEmpty) {
          throw Exception('현재 사용자의 nickname을 찾을 수 없습니다');
        }

        // 닉네임 저장 (다음번에는 바로 사용)
        await TokenStorage.saveUserNickname(nickname);
        developer.log('닉네임 저장 완료: $nickname', name: 'UserApi');
      }

      developer.log('사용자 스트릭 조회 - nickname: $nickname', name: 'UserApi');

      // /api/users/{nickname}/streak으로 스트릭 조회
      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      return await _apiClient.get<StreakData>(
        '/api/users/$nickname/streak',
        queryParameters: queryParams,
        fromJson: (data) => StreakData.fromJson(data as List<dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('스트릭 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('스트릭 데이터를 불러올 수 없습니다');
    }
  }

  /// 특정 사용자 스트릭 조회 (queryParameters 방식 사용)
  static Future<StreakData> getUserStreak({
    String nickname = 'alice', // 테스트용 기본값
    String? from,
    String? to,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      return await _apiClient.get<StreakData>(
        '/api/users/$nickname/streak',
        queryParameters: queryParams,
        fromJson: (data) => StreakData.fromJson(data as List<dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('스트릭 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('스트릭 데이터를 불러올 수 없습니다');
    }
  }
} 