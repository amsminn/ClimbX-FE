import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_vote.freezed.dart';
part 'problem_vote.g.dart';

@freezed
abstract class ProblemVote with _$ProblemVote {
  const factory ProblemVote({
    required String nickname,
    String? tier,
    @Default(<String>[]) List<String> tags,
    String? comment,
    DateTime? createdAt,
  }) = _ProblemVote;

  factory ProblemVote.fromJson(Map<String, dynamic> json) =>
      _$ProblemVoteFromJson(json);
}


