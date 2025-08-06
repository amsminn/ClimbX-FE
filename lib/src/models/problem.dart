/// 클라이밍 문제 정보 모델
class Problem {
  final String problemId;       // UUID 형태의 문제 ID
  final int gymId;              // 클라이밍장 ID
  final String gymName;         // 클라이밍장 이름
  final int gymAreaId;          // 클라이밍장 영역 ID
  final String gymAreaName;     // 클라이밍장 영역 이름 (예: "메인홀")
  final String localLevel;      // 난이도 색상 (빨강, 파랑, 초록 등)
  final String holdColor;       // 홀드 색상 (빨강, 파랑, 초록 등)
  final int problemRating;      // 문제 난이도 점수
  final String? problemTier;    // 문제 티어 (b3, b2, b1, s3 등)
  final String problemImageCdnUrl; // 문제 이미지 CDN URL
  final String activeStatus;    // 활성 상태 (ACTIVE, INACTIVE 등)
  final DateTime createdAt;     // 생성일

  Problem({
    required this.problemId,
    required this.gymId,
    required this.gymName,
    required this.gymAreaId,
    required this.gymAreaName,
    required this.localLevel,
    required this.holdColor,
    required this.problemRating,
    this.problemTier,
    required this.problemImageCdnUrl,
    required this.activeStatus,
    required this.createdAt,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      problemId: json['problemId'] ?? '',
      gymId: json['gymId'] ?? 0,
      gymName: json['gymName'] ?? '',
      gymAreaId: json['gymAreaId'] ?? 0,
      gymAreaName: json['gymAreaName'] ?? '',
      localLevel: json['localLevel'] ?? '',
      holdColor: json['holdColor'] ?? '',
      problemRating: json['problemRating'] ?? 0,
      problemTier: json['problemTier'],
      problemImageCdnUrl: json['problemImageCdnUrl'] ?? '',
      activeStatus: json['activeStatus'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemId': problemId,
      'gymId': gymId,
      'gymName': gymName,
      'gymAreaId': gymAreaId,
      'gymAreaName': gymAreaName,
      'localLevel': localLevel,
      'holdColor': holdColor,
      'problemRating': problemRating,
      'problemTier': problemTier,
      'problemImageCdnUrl': problemImageCdnUrl,
      'activeStatus': activeStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Problem(problemId: $problemId, gymId: $gymId, gymAreaName: $gymAreaName, localLevel: $localLevel, holdColor: $holdColor, rating: $problemRating)';
  }
} 