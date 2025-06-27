import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// 사용자 프로필 정보 모델 (실제 API 응답에 맞추었으나 추후 변경예정)
class UserProfile {
  final String nickname;
  final String statusMessage;
  final String profileImageUrl;
  final int ranking;
  final int rating;
  final Map<String, dynamic> categoryRatings;
  final int currentStreak;
  final int longestStreak;
  final int solvedProblemsCount;
  final int rivalCount;

  UserProfile({
    required this.nickname,
    required this.statusMessage,
    required this.profileImageUrl,
    required this.ranking,
    required this.rating,
    required this.categoryRatings,
    required this.currentStreak,
    required this.longestStreak,
    required this.solvedProblemsCount,
    required this.rivalCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '',
      statusMessage: json['statusMessage'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      ranking: json['ranking'] ?? 0,
      rating: json['rating'] ?? 0,
      categoryRatings: json['categoryRatings'] ?? {},
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      solvedProblemsCount: json['solvedProblemsCount'] ?? 0,
      rivalCount: json['rivalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'statusMessage': statusMessage,
      'profileImageUrl': profileImageUrl,
      'ranking': ranking,
      'rating': rating,
      'categoryRatings': categoryRatings,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'solvedProblemsCount': solvedProblemsCount,
      'rivalCount': rivalCount,
    };
  }

  @override
  String toString() {
    return 'UserProfile(nickname: $nickname, ranking: $ranking, rating: $rating, streak: $currentStreak)';
  }
}

/// 사용자 API 서비스 클래스
class UserService {
  /// alice 사용자 프로필 조회 (실제 API 연결)
  static Future<ApiResponse<UserProfile>> getAliceProfile() async {
    debugPrint('[UserService] Alice 프로필 조회 시작');
    developer.log('Alice 프로필 조회 시작', name: 'UserService');

    debugPrint(
      '[UserService] API 요청 URL: http://54.180.64.110:8080/api/users/alice',
    );

    final response = await ApiClient.get<UserProfile>(
      '/api/users/alice',
      needsAuth: false, // 이 API는 인증이 필요없다고 가정(나중에는 인증해야함)
      fromJson: (json) => UserProfile.fromJson(json),
    );

    if (response.success) {
      debugPrint('[UserService] Alice 프로필 조회 성공: ${response.data?.nickname}');
      developer.log('Alice 프로필 조회 성공: ${response.data}', name: 'UserService');
    } else {
      debugPrint(
        '[UserService] Alice 프로필 조회 실패: ${response.error} (상태코드: ${response.statusCode})',
      );
      developer.log('Alice 프로필 조회 실패: ${response.error}', name: 'UserService');
    }

    return response;
  }

  /// 특정 사용자 프로필 조회 (확장 가능)
  static Future<ApiResponse<UserProfile>> getUserProfile(
    String username,
  ) async {
    developer.log('$username 프로필 조회 시작', name: 'UserService');

    final response = await ApiClient.get<UserProfile>(
      '/api/users/$username',
      needsAuth: false,
      fromJson: (json) => UserProfile.fromJson(json),
    );

    if (response.success) {
      developer.log(
        '$username 프로필 조회 성공: ${response.data}',
        name: 'UserService',
      );
    } else {
      developer.log(
        '$username 프로필 조회 실패: ${response.error}',
        name: 'UserService',
      );
    }

    return response;
  }
}
