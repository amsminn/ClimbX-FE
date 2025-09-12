import 'package:flutter/material.dart';
import '../widgets/map_body.dart';
import '../widgets/profile_body.dart';
import '../widgets/leaderboard_body.dart';
import '../widgets/search_body.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../utils/tier_colors.dart';
import '../utils/bottom_nav_tab.dart';
import '../utils/color_schemes.dart';
import '../utils/tier_provider.dart';
import '../api/user.dart';
import '../models/user_profile.dart';
import 'dart:developer' as developer;

class MainPage extends StatefulWidget {
  final BottomNavTab? initialTab;
  final int? initialGymIdForSearch;
  final bool isGuestMode;

  const MainPage({
    super.key,
    this.initialTab,
    this.initialGymIdForSearch,
    this.isGuestMode = false,
  });

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late BottomNavTab _currentTab;
  UserProfile? _userProfile;
  int? _gymIdForSearch;

  @override
  void initState() {
    super.initState();
    // 초기 탭 설정 - 게스트모드면 지도, 로그인모드면 프로필이 기본
    _currentTab = widget.initialTab ?? 
        (widget.isGuestMode ? BottomNavTab.map : BottomNavTab.profile);
    _gymIdForSearch = widget.initialGymIdForSearch;

    // 로그인된 사용자만 프로필 로드
    if (!widget.isGuestMode) {
      _loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앱 전역은 항상 렌더링하고, 프로필은 내부에서 자체 로딩/에러 처리
    // 색상 스킴은 rating 기반으로 계산
    final TierType tierType = _userProfile != null
        ? TierColors.getTierTypeFromRating(_userProfile!.rating.totalRating)
        : TierType.bronze;
    final TierColorScheme colorScheme = TierColors.getColorScheme(tierType);

    return TierProvider(
      colorScheme: colorScheme,
      child: Scaffold(
        backgroundColor: AppColorSchemes.backgroundSecondary,

        // 상단 앱바
        appBar: CustomAppBar(isGuestMode: widget.isGuestMode),
      // Body - Indexed Stack으로 화면 전환
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          // 0: 프로필
          ProfileBody(isGuestMode: widget.isGuestMode),
          // 1: 리더보드
          LeaderboardBody(isGuestMode: widget.isGuestMode),
          // 2: 검색
          SearchBody(
            initialGymId: _gymIdForSearch,
            isGuestMode: widget.isGuestMode,
          ),
          // 3: 지도
          MapBody(isGuestMode: widget.isGuestMode),
        ],
      ),

              // 하단 네비게이션 바
        bottomNavigationBar: CustomBottomNavigationBar(
          currentTab: _currentTab,
          onTap: (tab) {
            // 현재 페이지 내에서 탭 변경
            setState(() {
              _currentTab = tab;
            });
          },
        ),
      ),
    );
  }
  
  /// 유저 프로필 로드
  Future<void> _loadUserProfile() async {
    try {
      developer.log('유저 프로필 로드 시작', name: 'MainPage');
      final userProfile = await UserApi.getCurrentUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = userProfile;
      });
      developer.log('유저 프로필 로드 완료: ${userProfile.tier}', name: 'MainPage');
    } catch (e) {
      developer.log('유저 프로필 로드 실패: $e', name: 'MainPage', error: e);
      // 실패해도 전역 UI를 막지 않음. 기존 _userProfile 유지.
    }
  }

}
