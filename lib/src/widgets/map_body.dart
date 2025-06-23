import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapBody extends StatefulWidget {
  const MapBody({super.key});

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  // NaverMapController? _controller; // 추후 사용 예정
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
          onMapReady: (NaverMapController controller) {
            // _controller = controller; 추후 사용 예정
          },
        ),
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
              controller: _searchController,
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
              onChanged: (value) {
                // 추후 검색 로직 구현
              },
            ),
          ),
        ),
      ],
    );
  }
}
