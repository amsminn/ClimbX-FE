import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem.freezed.dart';
part 'problem.g.dart';

/// 클라이밍 문제 정보 모델
@freezed
abstract class Problem with _$Problem {
  const factory Problem({
    @Default('') String problemId,
    @Default(0) int gymId,
    @Default(0) int gymAreaId,
    @Default('') String gymAreaName,
    @Default('') String localLevel,
    @Default('') String holdColor,
    @Default(0) int problemRating,
    @Default('') String problemImageCdnUrl,
    @Default('ACTIVE') String activeStatus,
    required DateTime createdAt,
  }) = _Problem;

  factory Problem.fromJson(Map<String, dynamic> json) => _$ProblemFromJson(json);

  const Problem._();

  @override
  String toString() {
    return 'Problem(problemId: $problemId, gymId: $gymId, gymAreaName: $gymAreaName, localLevel: $localLevel, holdColor: $holdColor, rating: $problemRating)';
  }
}
