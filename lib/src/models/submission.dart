import '../utils/color_codes.dart';

enum SubmissionStatus {
  pending('PENDING'),
  processing('PROCESSING'),
  completed('COMPLETED'),
  failed('FAILED');

  const SubmissionStatus(this.value);
  final String value;

  static SubmissionStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return SubmissionStatus.pending;
      case 'PROCESSING':
        return SubmissionStatus.processing;
      case 'COMPLETED':
        return SubmissionStatus.completed;
      case 'FAILED':
        return SubmissionStatus.failed;
      default:
        return SubmissionStatus.pending;
    }
  }
}

class Submission {
  final String videoId;
  final String problemId;
  final String problemLocalLevel; // e.g. BLUE
  final String problemHoldColor;  // e.g. BLUE
  final int problemRating;
  final String gymName;
  final SubmissionStatus status;
  final String userNickname;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final DateTime submittedAt;
  final DateTime updatedAt;

  Submission({
    required this.videoId,
    required this.problemId,
    required this.problemLocalLevel,
    required this.problemHoldColor,
    required this.problemRating,
    required this.gymName,
    required this.status,
    required this.userNickname,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      videoId: json['videoId'] as String,
      problemId: json['problemId'] as String,
      problemLocalLevel: json['problemLocalLevel'] as String,
      problemHoldColor: json['problemHoldColor'] as String,
      problemRating: (json['problemRating'] as num).toInt(),
      gymName: json['gymName'] as String,
      status: SubmissionStatus.fromString(json['status'] as String),
      userNickname: json['userNickname'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get formattedDuration {
    if (durationSeconds == null) return '';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 서버 코드(예: BLUE, GRAY)를 사용자 표시 라벨/색으로 변환
  (String, int) get localLevelLabelAndColor {
    final pair = ColorCodes.labelAndColorFromAny(problemLocalLevel);
    if (pair != null) {
      return (pair.$1, pair.$2.toARGB32());
    }
    return (problemLocalLevel, 0xFF3B82F6);
  }

  (String, int) get holdColorLabelAndColor {
    final pair = ColorCodes.labelAndColorFromAny(problemHoldColor);
    if (pair != null) {
      return (pair.$1, pair.$2.toARGB32());
    }
    return (problemHoldColor, 0xFF3B82F6);
  }
}

class SubmissionPageData {
  final List<Submission> submissions;
  final int totalCount;
  final bool hasNext;
  final String? nextCursor;

  SubmissionPageData({
    required this.submissions,
    required this.totalCount,
    required this.hasNext,
    required this.nextCursor,
  });

  factory SubmissionPageData.fromJson(Map<String, dynamic> json) {
    final list = (json['submissions'] as List<dynamic>)
        .map((e) => Submission.fromJson(e as Map<String, dynamic>))
        .toList();
    return SubmissionPageData(
      submissions: list,
      totalCount: (json['totalCount'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

