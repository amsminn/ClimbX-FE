import 'package:flutter/material.dart';
import '../widgets/map_body.dart';
import '../widgets/profile_body.dart';
import '../widgets/leaderboard_body.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../utils/tier_colors.dart';
import '../utils/bottom_nav_tab.dart';
import '../utils/navigation_helper.dart';
import '../screens/analysis_page.dart';

class MainPage extends StatefulWidget {
  final BottomNavTab? initialTab;
  
  const MainPage({super.key, this.initialTab});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late BottomNavTab _currentTab;

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
  void initState() {
    super.initState();
    // 초기 탭 설정
    _currentTab = widget.initialTab ?? BottomNavTab.profile;
  }

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
          const LeaderboardBody(),
          // 2: 분석
          AnalysisPage(isActive: _currentTab == BottomNavTab.analysis),
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
          // 지도 탭이면 MapPage로 이동, 아니면 현재 페이지에서 탭 변경
          if (tab == BottomNavTab.map) {
            NavigationHelper.handleTabChange(
              context,
              _currentTab, // 현재 탭
              tab, // 이동할 탭
            );
          } else {
            // 현재 페이지 내에서 탭 변경
            setState(() {
              _currentTab = tab;
            });
          }
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
