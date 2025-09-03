import 'package:flutter/material.dart';
import '../widgets/search_body.dart';
import '../utils/color_schemes.dart';

/// 영상에서 시작하는 문제 선택 전용 화면
/// - videoId가 주어지면 SearchBody가 제출 모드로 동작하여
///   문제 선택 시 곧바로 ProblemSubmitPage로 이동하고 영상이 선선택됨
class VideoSubmissionFlowPage extends StatelessWidget {
  final String? videoId;
  final int? initialGymId;

  const VideoSubmissionFlowPage({super.key, this.videoId, this.initialGymId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundSecondary,
      appBar: AppBar(
        title: const Text('문제 선택'),
        backgroundColor: AppColorSchemes.backgroundPrimary,
        foregroundColor: AppColorSchemes.textPrimary,
        elevation: 0,
      ),
      body: SearchBody(
        initialGymId: initialGymId,
        submissionVideoId: videoId,
      ),
    );
  }
}

