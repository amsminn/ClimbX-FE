import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';

class AnalysisPage extends HookWidget {
  final bool isActive;
  
  const AnalysisPage({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final videos = useState<List<AssetEntity>>([]);
    final isLoading = useState(false);
    final picker = useMemoized(() => ImagePicker(), []);

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
          }
          isLoading.value = false;
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
              const OrderOption(
                type: OrderOptionType.createDate,
                asc: false,
              ),
            ],
          ),
        );

        developer.log('앨범 개수: ${paths.length}', name: 'AnalysisPage');

        if (paths.isNotEmpty) {
          final recentPath = paths.first;
          final assetCount = await recentPath.assetCountAsync;
          developer.log('첫 번째 앨범: ${recentPath.name}, 비디오 개수: $assetCount', name: 'AnalysisPage');
          
          final assets = await recentPath.getAssetListRange(
            start: 0,
            end: 100,
          );
          
          if (context.mounted) {
            videos.value = assets;
            developer.log('갤러리에서 ${assets.length}개의 비디오 로드됨', name: 'AnalysisPage');
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
          // 새로 촬영한 비디오가 갤러리에 저장되면 자동으로 목록에 표시되도록
          // 갤러리를 다시 로드
          loadGalleryVideos();
          developer.log('비디오 촬영 완료: ${video.path}', name: 'AnalysisPage');
        }
      } catch (e) {
        developer.log('비디오 촬영 실패: $e', name: 'AnalysisPage', error: e);
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
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: videos.value.length + 1, // 촬영 버튼 + 비디오들
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 촬영 버튼
                  return _buildGridTile(
                    icon: Icons.videocam_outlined,
                    label: '촬영하기',
                    onTap: recordVideo,
                  );
                } else {
                  // 비디오 썸네일
                  final video = videos.value[index - 1];
                  return _buildVideoTile(video);
                }
              },
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
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTile(AssetEntity video) {
    return FutureBuilder<Uint8List?>(
      future: video.thumbnailDataWithSize(const ThumbnailSize.square(200)),
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            image: snapshot.hasData
                ? DecorationImage(
                    image: MemoryImage(snapshot.data!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !snapshot.hasData
              ? const Center(
                  child: Icon(
                    Icons.video_file_outlined,
                    size: 32,
                    color: Color(0xFF64748B),
                  ),
                )
              : Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // 비디오 길이 표시
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(video.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 