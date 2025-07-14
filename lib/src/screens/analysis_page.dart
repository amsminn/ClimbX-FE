import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import '../models/video.dart';
import '../utils/color_schemes.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AnalysisPage extends HookWidget {
  final bool isActive;

  const AnalysisPage({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final videos = useState<List<AssetEntity>>([]);
    final isLoading = useState(false);
    final picker = useMemoized(() => ImagePicker(), []);
    final uploadedVideos = useState<List<Video>>(
      [],
    ); // 업로드된 영상을 임시로 구현해둠 (API개발 이후에는 캐싱으로 사용 또는 제거할듯)

    // 갤러리에서 비디오 로드
    Future<void> loadGalleryVideos() async {
      if (!isActive) return;

      isLoading.value = true;

      try {
        // 권한 요청
        final PermissionState ps = await PhotoManager.requestPermissionExtend();
        developer.log('권한 상태: $ps', name: 'AnalysisPage');

        if (!ps.hasAccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('갤러리 접근 권한이 필요합니다.'),
                action: SnackBarAction(
                  label: '설정',
                  onPressed: () async {
                    final result = await openAppSettings();
                    developer.log('설정 페이지 열기: $result', name: 'AnalysisPage');
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
            isLoading.value = false;
          }
          return;
        }

        // 비디오만 필터링하여 최신순으로 가져오기
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.video,
          filterOption: FilterOptionGroup(
            imageOption: const FilterOption(
              needTitle: true,
              sizeConstraint: SizeConstraint(ignoreSize: true),
            ),
            videoOption: const FilterOption(
              needTitle: true,
              sizeConstraint: SizeConstraint(ignoreSize: true),
            ),
            createTimeCond: DateTimeCond(
              min: DateTime(1970),
              max: DateTime.now(),
            ),
            orders: [
              const OrderOption(type: OrderOptionType.createDate, asc: false),
            ],
          ),
        );

        developer.log('앨범 개수: ${paths.length}', name: 'AnalysisPage');

        if (paths.isNotEmpty) {
          final recentPath = paths.first;
          final assetCount = await recentPath.assetCountAsync;
          developer.log(
            '첫 번째 앨범: ${recentPath.name}, 비디오 개수: $assetCount',
            name: 'AnalysisPage',
          );

          final assets = await recentPath.getAssetListRange(start: 0, end: 100);

          if (context.mounted) {
            videos.value = assets;
            developer.log(
              '갤러리에서 ${assets.length}개의 비디오 로드됨',
              name: 'AnalysisPage',
            );
          }
        } else {
          developer.log('사용 가능한 앨범이 없음', name: 'AnalysisPage');
        }
      } catch (e) {
        developer.log('갤러리 비디오 로드 실패: $e', name: 'AnalysisPage', error: e);
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    // XFile을 받아서 업로드 처리 (썸네일 생성, Video 객체 생성, 리스트 추가, 스낵바 안내)
    Future<void> handleVideoUpload(XFile picked, String successMsg) async {
      final Uint8List? thumb = await VideoThumbnail.thumbnailData(
        video: picked.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 200,
        quality: 75,
      );
      final video = Video(
        videoId: DateTime.now().millisecondsSinceEpoch,
        userId: 0,
        videoUrl: picked.path,
        videoMetadata: thumb != null ? {'thumbnail': thumb} : null,
      );
      if (context.mounted) {
        uploadedVideos.value = [...uploadedVideos.value, video];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMsg)));
      }
    }

    // 비디오 촬영
    Future<void> recordVideo() async {
      try {
        // 카메라 권한 요청
        final cameraStatus = await Permission.camera.request();
        developer.log('카메라 권한 상태: $cameraStatus', name: 'AnalysisPage');

        if (!cameraStatus.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('카메라 접근 권한이 필요합니다.'),
                action: SnackBarAction(
                  label: '설정',
                  onPressed: () async {
                    final result = await openAppSettings();
                    developer.log('설정 페이지 열기: $result', name: 'AnalysisPage');
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
          await handleVideoUpload(video, '촬영 영상 임시 업로드 완료');
        }
      } catch (e) {
        developer.log('비디오 촬영 실패: $e', name: 'AnalysisPage', error: e);
      }
    }

    // 갤러리에서 영상 선택 후 업로드 (임시 메모리에 올라감. 실제로는 서버로 보내야함)
    Future<void> selectFromGallery() async {
      final XFile? picked = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null) {
        await handleVideoUpload(picked, '갤러리 영상 임시 업로드 완료');
      }
    }

    // 탭이 활성화될 때마다 갤러리 비디오 로드
    useEffect(() {
      if (isActive) {
        loadGalleryVideos();
      }
      return null;
    }, [isActive]);

    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundPrimary,
      body: SafeArea(
        child: isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: 2 + uploadedVideos.value.length,
                      // 촬영 버튼 + 갤러리에서 선택 버튼 + 서버의 영상
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 촬영 버튼
                          return _buildGridTile(
                            icon: Icons.videocam_outlined,
                            label: '촬영하기',
                            onTap: recordVideo,
                          );
                        } else if (index == 1) {
                          // 갤러리에서 선택 버튼
                          return _buildGridTile(
                            icon: Icons.photo_library_outlined,
                            label: '갤러리에서 선택',
                            onTap: selectFromGallery,
                          );
                        } else {
                          final uploadedVideo = uploadedVideos.value[index - 2];
                          return _buildUploadedVideoTile(uploadedVideo);
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGridTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorSchemes.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColorSchemes.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColorSchemes.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedVideoTile(Video video) {
    final thumb = video.videoMetadata?['thumbnail'];
    return Container(
      decoration: BoxDecoration(
        color: AppColorSchemes.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (thumb != null && thumb is Uint8List)
            Image.memory(thumb, width: 80, height: 80, fit: BoxFit.cover)
          else
            const Icon(
              Icons.video_file_outlined,
              size: 32,
              color: AppColorSchemes.textSecondary,
            ),
          const SizedBox(height: 8),
          Text(
            video.videoUrl.split('/').last,
            style: const TextStyle(
              color: AppColorSchemes.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
