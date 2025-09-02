class ProblemVote {
  final String nickname;
  final String? tier; // 서버가 제공할 수 있음(현재 작성은 코멘트만)
  final List<String> tags; // 서버가 제공할 수 있음(현재 작성은 코멘트만)
  final String? comment;
  final DateTime? createdAt; // 서버 응답에 존재할 경우 표시용

  const ProblemVote({
    required this.nickname,
    this.tier,
    this.tags = const [],
    this.comment,
    this.createdAt,
  });

  factory ProblemVote.fromJson(Map<String, dynamic> json) {
    return ProblemVote(
      nickname: (json['nickname'] ?? '') as String,
      tier: json['tier'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      if (tier != null) 'tier': tier,
      'tags': tags,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}


