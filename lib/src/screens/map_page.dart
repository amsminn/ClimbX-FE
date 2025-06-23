import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../utils/tier_colors.dart';
import 'profile_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // NaverMapController? _controller; // 추후 사용예정, 지도에서 코드로 제어할때 사용함

  // 티어 색상 (프로필 페이지와 동일하게해야함 추후 변경예정)
  final TierColorScheme colorScheme = TierColors.getColorScheme(
    TierType.platinum,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // 상단 앱바 (프로필 페이지와 동일한 구조)
      appBar: AppBar(
        // 앱바에 대한 설정
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // 뒤로 가기 버튼 제거

        // 로고
        title: const Text(
          'ClimbX',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        // 액션들 (팔레트, 알림, 메뉴)
        actions: [
          // 알림
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF64748B),
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
          // 메뉴
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // 가운데 body 부분 - 지도 표시
      body: NaverMap(
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
          // _controller = controller; // 여기도 추후 사용예정
        },
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 20,
              offset: Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: 3,
          // 지도 탭이 선택된 상태
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: '리더보드',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: '분석',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
          onTap: (idx) {
            if (idx == 4) {
              // 프로필 탭을 눌렀을 때
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const ProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
            // 다른 페이지 전환 로직 추가 가능
          },
        ),
      ),
    );
  }
}
