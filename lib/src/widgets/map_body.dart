import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../services/gym_service.dart';
import '../models/gym.dart';

class MapBody extends HookWidget {
  const MapBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useState<NaverMapController?>(null);
    final searchController = useTextEditingController();
    final searchQuery = useState<String>('');
    final debounceTimer = useRef<Timer?>(null);

    // useQuery 효과를 위한 커스텀 hook
    final gymsQuery = useFuture(
      useMemoized(() {
        if (searchQuery.value.trim().isEmpty) {
          return GymService.getAllGyms();
        } else {
          return GymService.searchGymsByKeyword(searchQuery.value.trim());
        }
      }, [searchQuery.value]),
    );

    final gyms = gymsQuery.data ?? <Gym>[];
    final isLoading = gymsQuery.connectionState == ConnectionState.waiting;

    // 커스텀 마커 아이콘 생성 함수
    final createCustomMarkerIcon = useCallback((String gymName) async {
      return await NOverlayImage.fromWidget(
        widget: SizedBox(
          width: 80,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 마커 아이콘
              Icon(
                Icons.location_on,
                color: const Color(0xFFFF6B35), // 주황색 고정
                size: 40,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // 클라이밍장 이름
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  gymName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        size: const Size(80, 60),
        context: context,
      );
    }, []);

    // 바텀시트 표시 함수
    final showGymDetailBottomSheet = useCallback((Gym gym) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // 핸들
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 상단 이미지 영역 (임시 컨테이너)
                            Container(
                              width: double.infinity,
                              height: 200,
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '클라이밍장 사진',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 클라이밍장 정보 영역
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 클라이밍장 이름
                                  Text(
                                    gym.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // 주소
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          gym.address,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // 운영시간 (임시 데이터)
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '영업 중',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF059669),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        ', 24:00에 영업 종료',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // 전화번호
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        gym.phoneNumber,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // 표준 난이도 분포 섹션
                                  const Text(
                                    '표준 난이도 분포',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: _buildDifficultyChart(),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }, []);

    // 마커 추가 함수
    final addMarkersToMap = useCallback((
      NaverMapController mapController,
      List<Gym> gymList,
    ) async {
      if (gymList.isEmpty) return;

      try {
        // 기존 마커 제거
        await mapController.clearOverlays();

        // 각 클라이밍장을 마커로 병렬 추가
        await Future.wait(
          gymList.map((gym) async {
            // 각 클라이밍장마다 개별 마커 아이콘 생성
            final markerIcon = await createCustomMarkerIcon(gym.name);

            final marker = NMarker(
              id: 'gym_${gym.gymId}',
              position: NLatLng(gym.latitude, gym.longitude),
              icon: markerIcon, // 클라이밍장 이름이 포함된 커스텀 마커
            );

            // 마커 클릭 이벤트
            marker.setOnTapListener((NMarker marker) {
              showGymDetailBottomSheet(gym);
            });

            // 마커 추가
            await mapController.addOverlay(marker);
          }),
        );

        developer.log('${gymList.length}개 이름 포함 마커 추가 완료', name: 'MapBody');
      } catch (e) {
        developer.log('마커 추가 중 오류: $e', name: 'MapBody');
      }
    }, [createCustomMarkerIcon, showGymDetailBottomSheet]);

    // 마커 추가 useEffect
    useEffect(() {
      if (controller.value != null && gyms.isNotEmpty) {
        addMarkersToMap(controller.value!, gyms);
      }
      return null;
    }, [controller.value, gyms, addMarkersToMap]);

    // 디바운스 정리 useEffect
    useEffect(() {
      return () => debounceTimer.value?.cancel();
    }, []);

    // 검색 디바운스 함수
    void onSearchChanged(String value) {
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(const Duration(milliseconds: 500), () {
        searchQuery.value = value;
      });
    }

    return Stack(
      children: [
        // 네이버 지도 (배경)
        NaverMap(
          options: const NaverMapViewOptions(
            // 서울 중심으로 설정
            initialCameraPosition: NCameraPosition(
              target: NLatLng(37.5665, 126.9780),
              zoom: 14,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
            // 줌 레벨 제한 설정
            minZoom: 8,
            // 최소 줌 (더 멀리)
            maxZoom: 20, // 최대 줌 (더 가까이)
          ),
          onMapReady: (NaverMapController mapController) {
            controller.value = mapController;
          },
        ),

        // 로딩 인디케이터
        if (isLoading) const Center(child: CircularProgressIndicator()),

        // 상단 검색바
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: '주변 클라이밍장 찾기',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 24),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                isDense: true,
              ),
              onSubmitted: (value) => searchQuery.value = value,
              onChanged: onSearchChanged,
            ),
          ),
        ),

        // 클라이밍장 개수 표시
        Positioned(
          top: 80,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '클라이밍장 ${gyms.length}개',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  /// 난이도 분포 차트 빌드
  Widget _buildDifficultyChart() {
    // 우리 표준 티어 시스템 (위에서 아래로: M -> B3)
    final tiers = [
      'M',
      'D1',
      'D2',
      'D3',
      'P1',
      'P2',
      'P3',
      'G1',
      'G2',
      'G3',
      'S1',
      'S2',
      'S3',
      'B1',
      'B2',
      'B3',
    ];

    // 클라이밍장 색깔 난이도와 우리 티어 매핑 (더미 데이터)
    final gymColorGrades = [
      {'name': '흰색', 'color': Colors.white, 'startTier': 'B3', 'endTier': 'B2'},
      {
        'name': '노란색',
        'color': Colors.yellow,
        'startTier': 'B2',
        'endTier': 'B1',
      },
      {
        'name': '주황색',
        'color': Colors.orange,
        'startTier': 'B1',
        'endTier': 'S3',
      },
      {
        'name': '초록색',
        'color': Colors.green,
        'startTier': 'S3',
        'endTier': 'G3',
      },
      {'name': '파란색', 'color': Colors.blue, 'startTier': 'G3', 'endTier': 'P3'},
      {'name': '빨간색', 'color': Colors.red, 'startTier': 'P3', 'endTier': 'P1'},
      {
        'name': '보라색',
        'color': Colors.purple,
        'startTier': 'P1',
        'endTier': 'D3',
      },
      {'name': '회색', 'color': Colors.grey, 'startTier': 'D3', 'endTier': 'D1'},
      {'name': '갈색', 'color': Colors.brown, 'startTier': 'D1', 'endTier': 'M'},
    ];

    return Container(
      height: 500,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // 왼쪽 티어 라벨들
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tiers.map((tier) {
                return SizedBox(
                  height: 26,
                  child: Text(
                    tier,
                    style: TextStyle(
                      color: _getStandardTierColor(tier),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(width: 8),

          // 차트 영역 - 가로선들과 색깔 컬럼들
          Expanded(
            child: Stack(
              children: [
                // 가로선들
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: tiers.map((tier) {
                    return SizedBox(
                      height: 26,
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 12.5),
                      ),
                    );
                  }).toList(),
                ),

                // 색깔별 개별 컬럼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: gymColorGrades.map((colorGrade) {
                    return SizedBox(
                      width: 24, // 고정 너비
                      child: _buildColorColumn(
                        colorGrade['color'] as Color,
                        colorGrade['startTier'] as String,
                        colorGrade['endTier'] as String,
                        tiers,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 색깔별 컬럼 빌드
  Widget _buildColorColumn(
    Color color,
    String startTier,
    String endTier,
    List<String> tiers,
  ) {
    final startIndex = tiers.indexOf(startTier);
    final endIndex = tiers.indexOf(endTier);

    if (startIndex == -1 || endIndex == -1) return Container();

    final minIndex = startIndex < endIndex ? startIndex : endIndex;
    final maxIndex = startIndex > endIndex ? startIndex : endIndex;

    // 전체 높이를 부모 컨테이너의 높이에 따라 동적으로 계산
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight - 24; // 24 padding
        final tierHeight = totalHeight / 16;

        // 각 영역 높이 계산
        final topSpaceHeight = minIndex * tierHeight;
        final rangeBoxHeight = (maxIndex - minIndex + 1) * tierHeight;
        final bottomSpaceHeight = (15 - maxIndex) * tierHeight;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          child: Column(
            children: [
              // 상단 여백
              SizedBox(height: topSpaceHeight),

              // 범위 박스
              Container(
                width: double.infinity,
                height: rangeBoxHeight,
                decoration: BoxDecoration(
                  color: color == Colors.white
                      ? Colors.grey[100]!.withValues(alpha: 0.9)
                      : color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: color == Colors.white
                      ? Border.all(color: Colors.grey[400]!, width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // 하단 여백
              SizedBox(height: bottomSpaceHeight),
            ],
          ),
        );
      },
    );
  }

  /// 표준 티어 색상 반환
  Color _getStandardTierColor(String tier) {
    if (tier.startsWith('B')) {
      return const Color(0xFFD2691E); // Bronze
    } else if (tier.startsWith('S')) {
      return const Color(0xFF708090); // Silver
    } else if (tier.startsWith('G')) {
      return const Color(0xFFFFA500); // Gold
    } else if (tier.startsWith('P')) {
      return const Color(0xFF27CCCA); // Platinum
    } else if (tier.startsWith('D')) {
      return const Color(0xFF1E90FF); // Diamond
    } else if (tier == 'M') {
      return const Color(0xFF805AD5); // Master
    }
    return Colors.grey;
  }
}
