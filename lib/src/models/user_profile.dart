import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/tier_colors.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    @Default('') String nickname,
    @Default('') String statusMessage,
    String? profileImageCdnUrl,
    @Default(0) int ranking,
    @Default(UserRating()) UserRating rating,
    @Default('') String tier,
    @Default(<CategoryRating>[]) List<CategoryRating> categoryRatings,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int solvedCount,
    @Default(0) int submissionCount,
    @Default(0) int contributionCount,
    // 서버 호환을 위해 rivalCount는 받아두지만 사용하지 않습니다.
    @Default(0) int rivalCount,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  // 표시용 티어 문자열
  String get displayTier =>
      TierColors.getTierStringFromRating(rating.totalRating);

  // 색상/아이콘 계산을 위한 티어 타입
  TierType get tierType =>
      TierColors.getTierTypeFromRating(rating.totalRating);
}

@Freezed(fromJson: true, toJson: true)
abstract class UserRating with _$UserRating {
  const factory UserRating({
    @Default(0) int totalRating,
    @Default(0) int topProblemRating,
    @Default(0) int solvedRating,
    @Default(0) int submissionRating,
    @Default(0) int contributionRating,
  }) = _UserRating;

  factory UserRating.fromJson(Map<String, dynamic> json) =>
      _$UserRatingFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class CategoryRating with _$CategoryRating {
  const factory CategoryRating({
    @Default('') String category,
    @Default(0) int rating,
  }) = _CategoryRating;

  factory CategoryRating.fromJson(Map<String, dynamic> json) =>
      _$CategoryRatingFromJson(json);
}
