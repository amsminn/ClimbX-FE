/// 클라이밍 문제 정보 모델
class Problem {
  final int id;
  final int gymId;
  final String localLevel;      // 난이도 색상 (빨강, 파랑, 초록 등)
  final String holdColor;       // 홀드 색상 (빨강, 파랑, 초록 등)
  final int problemRating;      // 문제 난이도 점수
  final int spotId;             // 스팟 ID
  final double spotXRatio;      // X 좌표 비율
  final double spotYRatio;      // Y 좌표 비율
  final String imageUrl;        // 문제 이미지 URL
  final DateTime createdAt;
  final DateTime updatedAt;

  Problem({
    required this.id,
    required this.gymId,
    required this.localLevel,
    required this.holdColor,
    required this.problemRating,
    required this.spotId,
    required this.spotXRatio,
    required this.spotYRatio,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] ?? 0,
      gymId: json['gym_id'] ?? 0,
      localLevel: json['local_level'] ?? '',
      holdColor: json['hold_color'] ?? '',
      problemRating: json['problem_rating'] ?? 0,
      spotId: json['spot_id'] ?? 0,
      spotXRatio: (json['spot_x_ratio'] ?? 0.0).toDouble(),
      spotYRatio: (json['spot_y_ratio'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'local_level': localLevel,
      'hold_color': holdColor,
      'problem_rating': problemRating,
      'spot_id': spotId,
      'spot_x_ratio': spotXRatio,
      'spot_y_ratio': spotYRatio,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Problem(id: $id, gymId: $gymId, localLevel: $localLevel, holdColor: $holdColor, rating: $problemRating)';
  }
} 