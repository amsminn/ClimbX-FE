/// 클라이밍 문제 정보 모델
class Problem {
  final String problemId;       // UUID 형태의 문제 ID
  final int gymId;              // 클라이밍장 ID
  final int gymAreaId;          // 클라이밍장 영역 ID
  final String gymAreaName;     // 클라이밍장 영역 이름 (예: "메인홀")
  final String localLevel;      // 난이도 색상 (빨강, 파랑, 초록 등)
  final String holdColor;       // 홀드 색상 (빨강, 파랑, 초록 등)
  final int problemRating;      // 문제 난이도 점수
  final String problemImageCdnUrl; // 문제 이미지 CDN URL
  final String activeStatus;    // 활성 상태 (ACTIVE, INACTIVE 등)
  final DateTime createdAt;     // 생성일

  Problem({
    required this.problemId,
    required this.gymId,
    required this.gymAreaId,
    required this.gymAreaName,
    required this.localLevel,
    required this.holdColor,
    required this.problemRating,
    required this.problemImageCdnUrl,
    required this.activeStatus,
    required this.createdAt,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      problemId: json['problemId'] ?? '',
      gymId: json['gymId'] ?? 0,
      gymAreaId: json['gymAreaId'] ?? 0,
      gymAreaName: json['gymAreaName'] ?? '',
      localLevel: json['localLevel'] ?? '',
      holdColor: json['holdColor'] ?? '',
      problemRating: json['problemRating'] ?? 0,
      problemImageCdnUrl: json['problemImageCdnUrl'] ?? '',
      activeStatus: json['activeStatus'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemId': problemId,
      'gymId': gymId,
      'gymAreaId': gymAreaId,
      'gymAreaName': gymAreaName,
      'localLevel': localLevel,
      'holdColor': holdColor,
      'problemRating': problemRating,
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