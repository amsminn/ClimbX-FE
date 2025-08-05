/// 사용자 프로필 정보를 담는 모델
class UserProfile {
  final String nickname;
  final String statusMessage;
  final String? profileImageCdnUrl;
  final int ranking;
  final int rating;
  final String tier;
  final List<CategoryRating> categoryRatings;
  final int currentStreak;
  final int longestStreak;
  final int solvedCount;
  final int submissionCount;
  final int contributionCount;
  final int rivalCount;

  UserProfile({
    required this.nickname,
    required this.statusMessage,
    this.profileImageCdnUrl,
    required this.ranking,
    required this.rating,
    required this.tier,
    required this.categoryRatings,
    required this.currentStreak,
    required this.longestStreak,
    required this.solvedCount,
    required this.submissionCount,
    required this.contributionCount,
    required this.rivalCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '',
      statusMessage: json['statusMessage'] ?? '',
      profileImageCdnUrl: json['profileImageCdnUrl'],
      ranking: json['ranking'] ?? 0,
      rating: json['rating'] ?? 0,
      tier: json['tier'] ?? '',
      categoryRatings: (json['categoryRatings'] as List<dynamic>?)
          ?.map((item) => CategoryRating.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      solvedCount: json['solvedCount'] ?? 0,
      submissionCount: json['submissionCount'] ?? 0,
      contributionCount: json['contributionCount'] ?? 0,
      rivalCount: json['rivalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'statusMessage': statusMessage,
      'profileImageCdnUrl': profileImageCdnUrl,
      'ranking': ranking,
      'rating': rating,
      'tier': tier,
      'categoryRatings': categoryRatings.map((item) => item.toJson()).toList(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'solvedCount': solvedCount,
      'submissionCount': submissionCount,
      'contributionCount': contributionCount,
      'rivalCount': rivalCount,
    };
  }

  @override
  String toString() {
    return 'UserProfile(nickname: $nickname, ranking: $ranking, rating: $rating, tier: $tier, streak: $currentStreak)';
  }
}

/// 카테고리별 레이팅 정보를 담는 모델
class CategoryRating {
  final String category;
  final int rating;

  CategoryRating({
    required this.category,
    required this.rating,
  });

  factory CategoryRating.fromJson(Map<String, dynamic> json) {
    return CategoryRating(
      category: json['category'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'CategoryRating(category: $category, rating: $rating)';
  }
} 