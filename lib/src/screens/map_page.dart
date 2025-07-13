import 'package:flutter/material.dart';
import '../utils/tier_colors.dart';
import '../utils/bottom_nav_tab.dart';
import '../utils/navigation_helper.dart';
import '../utils/color_schemes.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/map_body.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // 티어 색상 (프로필 페이지와 동일하게해야함 추후 변경예정)
  final TierColorScheme colorScheme = TierColors.getColorScheme(
    TierType.platinum,
  );

  /// 메모리 정리 공통 메서드
  void _cleanupResources() {
    // MapBody에서 자체적으로 리소스 정리를 하므로 여기서는 별도 처리 없음
  }

  /// 탭 변경 처리
  void _handleTabChange(BottomNavTab tab) {
    NavigationHelper.handleTabChange(
      context,
      BottomNavTab.map, // 현재 탭
      tab, // 이동할 탭
      onDispose: _cleanupResources, // 리소스 정리 콜백
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundSecondary,

      // 상단 앱바 (프로필 페이지와 동일한 구조)
      appBar: AppBar(
        // 앱바에 대한 설정
        backgroundColor: AppColorSchemes.backgroundPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // 뒤로 가기 버튼 제거

        // 로고
        title: const Text(
          'ClimbX',
          style: TextStyle(
            color: AppColorSchemes.textPrimary,
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
              color: AppColorSchemes.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColorSchemes.textSecondary,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
          // 메뉴
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColorSchemes.textSecondary,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // 가운데 body 부분 - MapBody 위젯 사용
      body: const MapBody(),

      // 하단 네비게이션 바
      bottomNavigationBar: CustomBottomNavigationBar(
        currentTab: BottomNavTab.map,
        colorScheme: colorScheme,
        onTap: _handleTabChange,
      ),
    );
  }
}
