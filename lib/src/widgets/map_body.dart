import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapBody extends StatefulWidget {
  const MapBody({super.key});

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  // NaverMapController? _controller; // 추후 사용 예정

  @override
  Widget build(BuildContext context) {
    return NaverMap(
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
    );
  }
}
