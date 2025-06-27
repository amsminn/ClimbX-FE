import 'package:flutter/material.dart';
import 'profile_header.dart';
import 'tier_widget.dart';
import 'history_widget.dart';
import 'streak_widget.dart';
import '../utils/tier_colors.dart';
import '../services/user_service.dart';
import '../utils/api_error_handler.dart';

class ProfileBody extends StatefulWidget {
  final String currentTier;
  final TierColorScheme colorScheme;

  const ProfileBody({
    super.key,
    required this.currentTier,
    required this.colorScheme,
  });

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  // API 데이터
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    debugPrint('[ProfileBody] initState 호출됨');
    super.initState();
    _loadUserProfile();
  }

  /// 사용자 프로필 데이터 로드
  Future<void> _loadUserProfile() async {
    debugPrint('[ProfileBody] 프로필 로드 시작');
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final userProfile = await ApiErrorHandler.handleApiCall<UserProfile>(
      context,
      UserService.getAliceProfile(),
      showLoading: false, // 자체 로딩 상태가 있으므로 false
      showErrorSnackBar: true,
      onSuccess: () {
        debugPrint('[ProfileBody] API 호출 성공');
      },
      onError: () {
        debugPrint('[ProfileBody] API 호출 실패');
      },
      onRetry: () {
        debugPrint('[ProfileBody] 재시도 중...');
        _loadUserProfile();
      },
    );

    if (!mounted) return;
    
    setState(() {
      _userProfile = userProfile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return DefaultTabController(
      length: 5,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: ProfileHeader(
                userProfile: _userProfile,
                tierName: widget.currentTier,
              ),
            ),
            SliverPersistentHeader(
              delegate: _StickyTabBarDelegate(
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: const Color(0xFFFFFFFF),
                  unselectedLabelColor: const Color(0xFF64748B),
                                      indicator: BoxDecoration(
                      gradient: widget.colorScheme.gradient,
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
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildTabContent(child: TierWidget(
              tierName: widget.currentTier,
              userProfile: _userProfile,
            )),
            _buildTabContent(child: HistoryWidget(tierName: widget.currentTier)),
            _buildTabContent(child: StreakWidget(
              tierName: widget.currentTier,
              userProfile: _userProfile,
            )),
            _buildTabContent(
              child: _buildComingSoon('분야별 티어', Icons.category, widget.colorScheme),
            ),
            _buildTabContent(
              child: _buildComingSoon('내 영상', Icons.video_library, widget.colorScheme),
            ),
          ],
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
