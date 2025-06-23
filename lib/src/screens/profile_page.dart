import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/tier_widget.dart';
import '../widgets/history_widget.dart';
import '../widgets/streak_widget.dart';
import '../utils/tier_test_helper.dart';
import '../utils/tier_colors.dart';
import 'map_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

      // 상단 앱바 (ClimbX, 팔레트(임시), 알림, 메뉴)
      appBar: AppBar(
        // 앱바에 대한 설정
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거

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
          // 팔레트
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.palette_outlined,
                color: Color(0xFF64748B),
                size: 22,
              ),
              onPressed: () {
                TierTestHelper.showTierSelector(context, (String selectedTier) {
                  setState(() {
                    currentTier = selectedTier;
                  });
                });
              },
            ),
          ),
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

      // 가운데 body 부분
      body: DefaultTabController(
        length: 5, // 탭바의 길이 (개요, 히스토리, 스트릭, 분야별 티어, 내 영상)
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // SliverToBoxAdapter로 감싸면 스크롤이 가능
              SliverToBoxAdapter(child: ProfileHeader(tierName: currentTier)),

              // SliverPersistentHeader는 스크롤이 되지만 화면에 고정되는 것
              SliverPersistentHeader(
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: const Color(0xFFFFFFFF),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicator: BoxDecoration(
                      gradient: colorScheme.gradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: [
                      _buildTab('개요'),
                      _buildTab('히스토리'),
                      _buildTab('스트릭'),
                      _buildTab('분야별 티어'),
                      _buildTab('내 영상'),
                    ],
                  ),
                ),
                pinned: true, // 탭바를 화면에 고정
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildTabContent(child: TierWidget(tierName: currentTier)),
              _buildTabContent(child: HistoryWidget(tierName: currentTier)),
              _buildTabContent(child: StreakWidget(tierName: currentTier)),
              _buildTabContent(
                child: _buildComingSoon('분야별 티어', Icons.category, colorScheme),
              ),
              _buildTabContent(
                child: _buildComingSoon(
                  '내 영상',
                  Icons.video_library,
                  colorScheme,
                ),
              ),
            ],
          ),
        ),
      ),
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
          currentIndex: 4,
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
            if (idx == 3) {
              // 지도 탭을 눌렀을 때 - 애니메이션 없이 이동
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MapPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
            // 다른 페이지 전환 로직 추가해야함
          },
        ),
      ),
    );
  }

  // 탭바에서 선택할 수 있는 텍스트
  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(text),
    );
  }

  // 내용이 들어있는 탭바 위젯
  Widget _buildTabContent({required Widget child}) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: child,
      ),
    );
  }

  // 출시 예정 탭바
  Widget _buildComingSoon(
    String title,
    IconData icon,
    TierColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: colorScheme.gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFFFFFFFF), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '곧 출시 예정입니다',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
