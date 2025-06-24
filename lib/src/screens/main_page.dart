import 'package:flutter/material.dart';
import '../widgets/map_body.dart';
import '../widgets/profile_body.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../utils/tier_colors.dart';
import '../utils/bottom_nav_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BottomNavTab _currentTab = BottomNavTab.profile; // 프로필 페이지가 기본

  // 현재 티어를 저장 (임시로 디버깅용으로 이렇게 해두었음, 수정 예정)
  String currentTier = [
    'Bronze I',
    'Silver I',
    'Gold I',
    'Platinum I',
    'Diamond I',
    'Master',
  ][3];

  @override
  Widget build(BuildContext context) {
    // 현재 티어 색상 정보 가져옴
    final TierType tierType = TierColors.getTierFromString(currentTier);
    final TierColorScheme colorScheme = TierColors.getColorScheme(tierType);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // 상단 앱바
      appBar: CustomAppBar(
        currentTier: currentTier,
        onTierChanged: (String selectedTier) {
          setState(() {
            currentTier = selectedTier;
          });
        },
      ),
      // Body - Indexed Stack으로 화면 전환
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          // 0: 홈
          _buildComingSoon('홈', Icons.home, colorScheme),
          // 1: 리더보드
          _buildComingSoon('리더보드', Icons.leaderboard, colorScheme),
          // 2: 분석
          _buildComingSoon('분석', Icons.camera_alt, colorScheme),
          // 3: 지도
          const MapBody(),
          // 4: 프로필
          ProfileBody(currentTier: currentTier, colorScheme: colorScheme),
        ],
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: CustomBottomNavigationBar(
        currentTab: _currentTab,
        colorScheme: colorScheme,
        onTap: (tab) {
          setState(() {
            _currentTab = tab;
          });
        },
      ),
    );
  }

  // 출시 예정 페이지 (임시페이지임 삭제 예정)
  Widget _buildComingSoon(
    String title,
    IconData icon,
    TierColorScheme colorScheme,
  ) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: screenSize.width * 0.85,
        height: screenSize.height * 0.4,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenSize.width * 0.05),
              decoration: BoxDecoration(
                gradient: colorScheme.gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: screenSize.width * 0.08,
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Text(
              title,
              style: TextStyle(
                fontSize: screenSize.width * 0.05,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              '곧 출시 예정입니다',
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
