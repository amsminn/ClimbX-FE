import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import 'util/core/query_params_builder.dart';
import '../models/user_profile.dart';
import '../models/history_data.dart';
import '../models/streak_data.dart';
import 'util/auth/token_storage.dart';
import 'util/auth/user_identity.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

/// 사용자 관련 API 호출 함수들
class UserApi {
  static final _apiClient = ApiClient.instance;

  /// 닉네임이 null이면 현재 사용자 닉네임을 조회하여 반환
  static Future<String> _resolveNickname(String? nickname) async {
    return nickname ?? await UserIdentity.getOrFetchNickname(logContext: 'UserApi');
  }

  /// 현재 사용자 프로필 조회 (JWT 토큰 기반)
  static Future<UserProfile> getCurrentUserProfile() async {
    try {
      // 닉네임을 캐시에서 가져오거나 서버에서 조회
      final String nickname =
          await UserIdentity.getOrFetchNickname(logContext: 'UserApi');

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
    return await getUserHistory(from: from, to: to, criteria: criteria);
  }

  /// 특정 사용자 히스토리 조회 (queryParameters 방식 사용)
  static Future<HistoryData> getUserHistory({
    String? nickname,
    String? from,
    String? to,
    String criteria = 'RATING',
  }) async {
    try {
      // 닉네임이 주어지지 않으면 현재 사용자 닉네임 사용
      final String finalNickname = await _resolveNickname(nickname);

      return await _apiClient.get<HistoryData>(
        '/api/users/$finalNickname/history',
        queryParameters: QueryParamsBuilder()
            .add('criteria', criteria)
            .add('from', from)
            .add('to', to)
            .build(),
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
    return await getUserStreak(from: from, to: to);
  }

  /// 특정 사용자 스트릭 조회 (queryParameters 방식 사용)
  static Future<StreakData> getUserStreak({
    String? nickname,
    String? from,
    String? to,
  }) async {
    try {
      // 닉네임이 주어지지 않으면 현재 사용자 닉네임 사용
      final String finalNickname = await _resolveNickname(nickname);

      return await _apiClient.get<StreakData>(
        '/api/users/$finalNickname/streak',
        queryParameters: QueryParamsBuilder()
            .add('from', from)
            .add('to', to)
            .build(),
        fromJson: (data) => StreakData.fromJson(data as List<dynamic>),
        logContext: 'UserApi',
      );
    } catch (e) {
      // 디버깅용 상세 로그 남기기
      developer.log('스트릭 데이터 조회 실패: $e', name: 'UserApi', error: e);
      throw Exception('스트릭 데이터를 불러올 수 없습니다');
    }
  }

  /// 프로필 업데이트 (닉네임, 상태 메세지)
  static Future<void> updateProfile({
    required String currentNickname,
    String? newNickname,
    String? newStatusMessage,
  }) async {
    await _apiClient.put<void>(
      '/api/users/$currentNickname',
      data: {'newNickname': newNickname, 'newStatusMessage': newStatusMessage},
      logContext: 'UserApi',
    );

    // 닉네임이 변경되면 로컬 저장 닉네임 갱신
    if (newNickname != null && newNickname.isNotEmpty) {
      await TokenStorage.saveUserNickname(newNickname);
    }
  }

  /// 프로필 이미지 업데이트 (file == null 이면 기본 이미지로 변경)
  static Future<void> updateProfileImage({
    required String nickname,
    required XFile? file,
  }) async {
    final formData = FormData.fromMap({
      if (file != null)
        'profileImage': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
          contentType: MediaType('image', 'jpeg'), // 모든 사진은 jpeg로 통일
        ),
    });

    try {
      await _apiClient.dio.put(
        '/api/users/$nickname/profile-image',
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } catch (e) {
      developer.log('프로필 이미지 업데이트 실패: $e', name: 'UserApi', error: e);
      throw Exception('프로필 이미지를 업데이트할 수 없습니다.');
    }
  }
}
