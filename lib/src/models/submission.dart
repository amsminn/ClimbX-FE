import '../utils/color_codes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission.freezed.dart';
part 'submission.g.dart';

enum SubmissionStatus { pending, processing, accepted, failed }

class SubmissionStatusConverter
    implements JsonConverter<SubmissionStatus, String> {
  const SubmissionStatusConverter();
  @override
  SubmissionStatus fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'PENDING':
        return SubmissionStatus.pending;
      case 'PROCESSING':
        return SubmissionStatus.processing;
      case 'ACCEPTED':
        return SubmissionStatus.accepted;
      case 'FAILED':
        return SubmissionStatus.failed;
      default:
        return SubmissionStatus.pending;
    }
  }

  @override
  String toJson(SubmissionStatus object) {
    switch (object) {
      case SubmissionStatus.pending:
        return 'PENDING';
      case SubmissionStatus.processing:
        return 'PROCESSING';
      case SubmissionStatus.accepted:
        return 'ACCEPTED';
      case SubmissionStatus.failed:
        return 'FAILED';
    }
  }
}

@freezed
abstract class Submission with _$Submission {
  const factory Submission({
    @Default('') String videoId,
    @Default('') String problemId,
    @Default('') String problemLocalLevel,
    @Default('') String problemHoldColor,
    @Default(0) int problemRating,
    @Default('') String gymName,
    @SubmissionStatusConverter() @Default(SubmissionStatus.pending) SubmissionStatus status,
    @Default('') String userNickname,
    String? thumbnailUrl,
    int? durationSeconds,
    @Default(0) int page,
    @Default('') String? comment,
    required DateTime submittedAt,
    required DateTime updatedAt,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);

  const Submission._();

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

@freezed
abstract class SubmissionPageData with _$SubmissionPageData {
  const factory SubmissionPageData({
    @Default(<Submission>[]) List<Submission> submissions,
    @Default(0) int totalCount,
    @Default(false) bool hasNext,
    String? nextCursor,
  }) = _SubmissionPageData;

  factory SubmissionPageData.fromJson(Map<String, dynamic> json) =>
      _$SubmissionPageDataFromJson(json);
}
