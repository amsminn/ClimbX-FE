import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_item.freezed.dart';
part 'leaderboard_item.g.dart';

/// 리더보드 아이템 정보를 담는 모델
@freezed
abstract class LeaderboardItem with _$LeaderboardItem {
  const factory LeaderboardItem({
    @Default('') String nickname,
    @Default('') String statusMessage,
    String? profileImageCdnUrl,
    @Default(0) int rating,
    @Default(0) int ranking,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int solvedCount,
    // 프론트 계산 필드
    @Default('') String tier,
    @Default('') String value,
  }) = _LeaderboardItem;

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardItemFromJson(json);

  /// API 응답에 프론트 계산 필드(tier/value)를 합쳐 생성하는 헬퍼 팩토리
  factory LeaderboardItem.withTierAndValue(
    Map<String, dynamic> json, {
    required String tier,
    required String value,
  }) =>
      LeaderboardItem.fromJson({
        ...json,
        'tier': tier,
        'value': value,
      });
}
