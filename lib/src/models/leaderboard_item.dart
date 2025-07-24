/// 리더보드 아이템 정보를 담는 모델
class LeaderboardItem {
  final String nickname;
  final String statusMessage;
  final String? profileImageUrl;
  final int rating;
  final int currentStreak;
  final int longestStreak;
  final int solvedCount;
  
  // 프론트엔드에서 계산되는 필드들
  final int rank;
  final String tier;
  final String value;

  const LeaderboardItem({
    required this.nickname,
    required this.statusMessage,
    this.profileImageUrl,
    required this.rating,
    required this.currentStreak,
    required this.longestStreak,
    required this.solvedCount,
    required this.rank,
    required this.tier,
    required this.value,
  });

  /// 백엔드 응답에서 LeaderboardItem 객체 생성
  factory LeaderboardItem.fromJson(
    Map<String, dynamic> json, {
    required int rank,
    required String tier,
    required String value,
  }) {
    return LeaderboardItem(
      nickname: json['nickname'] ?? '',
      statusMessage: json['statusMessage'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      rating: json['rating'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      solvedCount: json['solvedCount'] ?? 0,
      rank: rank,
      tier: tier,
      value: value,
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'statusMessage': statusMessage,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'solvedCount': solvedCount,
      'rank': rank,
      'tier': tier,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'LeaderboardItem(rank: $rank, nickname: $nickname, rating: $rating, value: $value)';
  }
} 