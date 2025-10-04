import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;
import '../models/video.dart';
import '../api/video.dart';
import '../utils/color_schemes.dart';
import '../utils/tier_provider.dart';
import '../utils/tier_colors.dart';
import 'video_overlay_player.dart';
import '../utils/navigation_helper.dart';
import '../utils/analytics_helper.dart';

class VideoGalleryWidget extends HookWidget {
  final bool isActive;
  final bool readOnly; // 읽기 전용 여부
  final String? nickname; // 특정 유저의 영상 목록을 보기 위한 닉네임

  const VideoGalleryWidget({
    super.key,
    this.isActive = true,
    this.readOnly = false,
    this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final isPickerActive = useState(false);
    final picker = useMemoized(() => ImagePicker(), []);

    // 서버에서 가져온 영상 목록
    final serverVideos = useState<List<Video>>([]);

    // 로컬에서 업로드 중인 영상 목록
    final localVideos = useState<List<Video>>([]);

    // 티어 색상 정보 가져오기
    final TierColorScheme colorScheme = TierProvider.of(context);

    // 통합 영상 목록 (로컬, 서버) - getter 함수로 정의
    List<Video> getAllVideos() => [...localVideos.value, ...serverVideos.value];

    // 업로드 중 영상이 하나라도 있는지 여부
    final bool isAnyUploading =
        localVideos.value.any((video) => video.isUploading);

    // 서버에서 영상 목록 로드
    Future<void> loadServerVideos() async {
      if (!isActive) return;

      try {
        developer.log('서버 영상 목록 로드 시작', name: 'VideoGalleryWidget');
        final videos = nickname == null
            ? await VideoApi.getCurrentUserVideos()
            : await VideoApi.getUserVideosByNickname(nickname!);

        if (context.mounted) {
          serverVideos.value = videos;
          developer.log(
            '서버 영상 목록 로드 완료: ${videos.length}개',
            name: 'VideoGalleryWidget',
          );
        }
      } catch (e) {
        developer.log(
          '서버 영상 목록 로드 실패: $e',
          name: 'VideoGalleryWidget',
          error: e,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('영상 목록을 불러올 수 없습니다: $e'),
              backgroundColor: AppColorSchemes.accentRed,
            ),
          );
        }
      }
    }

    // 영상 목록 새로고침
    Future<void> refreshVideos() async {
      isLoading.value = true;
      try {
        // 새로고침 시 로컬 영상 목록 초기화 (업로드 중인 것들 제거)
        localVideos.value = [];
        await loadServerVideos();
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    // 영상 업로드 처리
    Future<void> handleVideoUpload(XFile pickedFile, String successMsg) async {
      final contextMounted = context.mounted;
      if (!contextMounted) return;

      try {
        // 로컬 Video 객체 생성 (업로드 전)
        final localVideo = Video.fromLocalFile(pickedFile.path);
        localVideos.value = [localVideo, ...localVideos.value];

        // 성공 메시지 표시
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMsg)));
        }

        developer.log(
          '영상 업로드 시작: ${pickedFile.path}',
          name: 'VideoGalleryWidget',
        );

        // 업로드 시작 - 진행률 표시를 위해 상태 업데이트
        final uploadingVideo = localVideo.copyWith(isUploading: true);
        final index = localVideos.value.indexWhere(
          (v) => v.localPath == pickedFile.path,
        );
        localVideos.value = [
          ...localVideos.value.take(index),
          uploadingVideo,
          ...localVideos.value.skip(index + 1),
        ];

        // 실제 업로드 수행
        final videoId = await VideoApi.uploadVideo(
          filePath: pickedFile.path,
          onProgress: (progress) {
            final currentIndex = localVideos.value.indexWhere(
              (v) => v.localPath == pickedFile.path,
            );
            if (currentIndex != -1) {
              final updatedVideo = uploadingVideo.copyWith(
                uploadProgress: progress,
              );
              localVideos.value = [
                ...localVideos.value.take(currentIndex),
                updatedVideo,
                ...localVideos.value.skip(currentIndex + 1),
              ];
            }
          },
        );

        developer.log('영상 업로드 완료: $videoId', name: 'VideoGalleryWidget');

        // 업로드 완료 - 업로드 상태만 해제하고 로컬에서 삭제하지 않음
        final currentIndex = localVideos.value.indexWhere(
          (v) => v.localPath == pickedFile.path,
        );
        if (currentIndex != -1) {
          final completedVideo = localVideos.value[currentIndex].copyWith(
            isUploading: false,
            uploadProgress: 1.0,
          );
          localVideos.value = [
            ...localVideos.value.take(currentIndex),
            completedVideo,
            ...localVideos.value.skip(currentIndex + 1),
          ];
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('업로드 완료!'),
              backgroundColor: AppColorSchemes.accentGreen,
            ),
          );
        }

        refreshVideos();
      } catch (e) {
        developer.log('영상 업로드 실패: $e', name: 'VideoGalleryWidget', error: e);

        // 실패한 영상을 로컬 목록에서 제거
        localVideos.value = localVideos.value
            .where((v) => v.localPath != pickedFile.path)
            .toList();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('영상 업로드 실패: $e'),
              backgroundColor: AppColorSchemes.accentRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }

    // 비디오 촬영
    Future<void> recordVideo() async {
      if (isPickerActive.value) {
        developer.log('이미 picker가 활성화되어 있습니다', name: 'VideoGalleryWidget');
        return;
      }

      try {
        isPickerActive.value = true;

        // 카메라 권한 요청
        final cameraStatus = await Permission.camera.request();
        developer.log('카메라 권한 상태: $cameraStatus', name: 'VideoGalleryWidget');

        if (!cameraStatus.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('카메라 접근 권한이 필요합니다.'),
                action: SnackBarAction(
                  label: '설정',
                  onPressed: () async {
                    final result = await openAppSettings();
                    developer.log(
                      '설정 페이지 열기: $result',
                      name: 'VideoGalleryWidget',
                    );
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        final XFile? video = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 1),
        );

        if (video != null) {
          await handleVideoUpload(video, '영상을 업로드하고 있어요...');
        }
      } catch (e) {
        developer.log('비디오 촬영 실패: $e', name: 'VideoGalleryWidget', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비디오 촬영 실패: $e'),
              backgroundColor: AppColorSchemes.accentRed,
            ),
          );
        }
      } finally {
        isPickerActive.value = false;
      }
    }

    // 갤러리에서 영상 선택
    Future<void> selectFromGallery() async {
      if (isPickerActive.value) {
        developer.log('이미 picker가 활성화되어 있습니다', name: 'VideoGalleryWidget');
        return;
      }

      try {
        isPickerActive.value = true;

        final XFile? picked = await picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 5),
        );

        if (picked != null) {
          await handleVideoUpload(picked, '영상을 업로드하고 있어요...');
        }
      } catch (e) {
        developer.log(
          '갤러리 영상 선택 실패: $e',
          name: 'VideoGalleryWidget',
          error: e,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('갤러리 영상 선택 실패: $e'),
              backgroundColor: AppColorSchemes.accentRed,
            ),
          );
        }
      } finally {
        isPickerActive.value = false;
      }
    }

    // 탭이 활성화될 때마다 서버 영상 목록 로드
    useEffect(() {
      if (isActive) {
        refreshVideos();
      }
      return null;
    }, [isActive]);

    void onVideoTap(BuildContext context, Video video) {
      if (video.isCompleted && video.hasValidUrl) {
        final BuildContext parentContext = context;
        showDialog(
          context: parentContext,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          builder: (BuildContext dialogContext) {
            return VideoOverlayPlayer(
              video: video,
              tierColors: colorScheme,
              showSubmitButton: !readOnly,
              onSubmitPressed: readOnly
                  ? null
                  : () {
                      NavigationHelper.startVideoSubmissionFlow(
                        parentContext,
                        videoId: video.videoId,
                      );
                    },
            );
          },
        );
      } else if (video.isPending || video.isProcessing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('영상 처리가 완료되면 재생할 수 있습니다'),
            backgroundColor: AppColorSchemes.accentOrange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('영상을 재생할 수 없습니다'),
            backgroundColor: AppColorSchemes.accentRed,
          ),
        );
      }
    }

    // 업로드 옵션 선택 팝업 표시
    void showUploadOptions() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorSchemes.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '영상 업로드',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColorSchemes.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // 촬영하기 옵션
                      ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.videocam_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        title: const Text(
                          '촬영하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColorSchemes.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          '새로운 영상을 촬영합니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorSchemes.textSecondary,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          AnalyticsHelper.clickMyVideoFilming();
                          recordVideo();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 갤러리에서 선택 옵션
                      ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.photo_library_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        title: const Text(
                          '갤러리에서 선택',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColorSchemes.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          '기존 영상을 선택합니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorSchemes.textSecondary,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          AnalyticsHelper.clickMyVideoUpload();
                          selectFromGallery();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    }

    // 빈 상태 UI
    Widget buildEmptyState() {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.videocam_off_outlined,
                size: 32,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '아직 영상이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColorSchemes.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColorSchemes.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: '우측 상단의 '),
                  WidgetSpan(
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                  const TextSpan(text: ' 버튼을 눌러\n첫 영상을 업로드해보세요'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColorSchemes.defaultGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: colorScheme.gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VIDEOS',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColorSchemes.backgroundPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 업로드 버튼 (읽기 전용이 아닐 때만 표시)
                    if (!readOnly) ...[
                      IconButton(
                        onPressed: isPickerActive.value ? null : showUploadOptions,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: isPickerActive.value 
                              ? AppColorSchemes.textTertiary
                              : colorScheme.primary,
                        ),
                        tooltip: '영상 업로드',
                      ),
                    ],
                    // 새로고침 버튼
                    IconButton(
                      onPressed: (isLoading.value || isAnyUploading) ? null : () {
                        AnalyticsHelper.clickMyVideoRefresh();
                        refreshVideos();
                      },
                      icon: isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 20),
                      tooltip: '목록 새로고침',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 비디오 그리드 또는 빈 상태
            isLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : getAllVideos().isEmpty
                    ? buildEmptyState()
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: getAllVideos().length,
                        // 영상들만 표시
                        itemBuilder: (context, index) {
                          final video = getAllVideos()[index];
                          return _buildVideoTile(
                            context,
                            video,
                            () => onVideoTap(context, video),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  /// 영상 타일
  Widget _buildVideoTile(
    BuildContext context,
    Video video,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: video.isUploading
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : AppColorSchemes.textTertiary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 썸네일/상태 표시 (업로드 중/서버 처리중/정상 썸네일)
              Positioned.fill(
                child: video.isUploading
                    ? Container(
                        color: AppColorSchemes.backgroundSecondary,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    TierProvider.of(context).primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '업로드 중',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorSchemes.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : (video.isPending || video.isProcessing)
                        ? Container(
                            color: AppColorSchemes.backgroundSecondary,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        TierProvider.of(context).primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '처리 중',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColorSchemes.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : video.getThumbnailWidget(fit: BoxFit.cover),
              ),

              // 재생 시간 (좌측 하단)
              if (video.formattedDuration.isNotEmpty)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.formattedDuration,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1,
                            color: Colors.black.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 업로드 진행률 오버레이
              if (video.isUploading && video.uploadProgress != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: video.uploadProgress,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(video.uploadProgress! * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
