import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video.dart';
import 'dart:developer' as developer;
import '../utils/tier_colors.dart';

class VideoOverlayPlayer extends StatefulWidget {
  final Video video;
  final String? tierName;

  const VideoOverlayPlayer({super.key, required this.video, this.tierName});

  @override
  State<VideoOverlayPlayer> createState() => _VideoOverlayPlayerState();
}

class _VideoOverlayPlayerState extends State<VideoOverlayPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    if (widget.video.isCompleted && widget.video.hasValidUrl) {
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    // 위젯이 화면에서 사라질 때 타이머와 컨트롤러를 반드시 해제
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.hlsCdnUrl!),
    );

    _controller
        .initialize()
        .then((_) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
          // 영상이 시작되면 3초 후 컨트롤 숨김
          _startHideControlsTimer();
        })
        .catchError((error) {
          developer.log(
            'Video initialization error: $error',
            name: 'VideoPlayer',
          );
        });
  }

  void _closePlayer() {
    Navigator.of(context).pop();
  }

  void _togglePlayPause() {
    // 버튼을 누를 때마다 타이머를 리셋해서 컨트롤이 바로 사라지지 않게 함
    _resetHideControlsTimer();

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  // 컨트롤을 보이거나 숨기는 메인 함수
  void _toggleControls() {
    setState(() {
      if (_showControls) {
        _showControls = false;
        _hideControlsTimer?.cancel(); // 수동으로 숨기면 타이머 취소
      } else {
        _showControls = true;
        _resetHideControlsTimer(); // 컨트롤을 보이면 다시 숨김 타이머 시작
      }
    });
  }

  // 3초 뒤에 컨트롤을 숨기는 타이머 시작
  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  // 타이머 리셋
  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _startHideControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final tierColors = TierColors.getColorScheme(
      TierColors.getTierFromString(widget.tierName ?? 'Bronze III'),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.black,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 40,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: _isInitialized
                  ? GestureDetector(
                      // 1. 배경 탭: 컨트롤 보이기/숨기기
                      onTap: _toggleControls,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 2. 영상: 화면 비율 유지
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),

                          // 3. 컨트롤 오버레이
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: _showControls ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              // IgnorePointer: 컨트롤이 숨겨졌을 땐 탭 이벤트를 받지 않음
                              child: IgnorePointer(
                                ignoring: !_showControls,
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                  child: Stack(
                                    children: [
                                      // 중앙 재생/일시정지 버튼
                                      Center(
                                        child: GestureDetector(
                                          onTap: _togglePlayPause,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _controller.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 상단 우측 닫기 버튼
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: _closePlayer,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  // 로딩 인디케이터
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 16),
          // 하단 영상 제출하기 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // TODO 영상 체출 흐름으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('영상 제출 기능은 준비 중입니다')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tierColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '영상 제출하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
