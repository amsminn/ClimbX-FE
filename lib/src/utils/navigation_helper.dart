import 'package:flutter/material.dart';
import 'bottom_nav_tab.dart';
import '../screens/main_page.dart';
import '../screens/map_page.dart';
import '../screens/login_page.dart';

/// 공통 네비게이션 처리 헬퍼
class NavigationHelper {
  /// 탭 변경에 따른 페이지 이동 처리
  /// 
  /// [context]: BuildContext
  /// [currentTab]: 현재 탭
  /// [targetTab]: 이동할 탭
  /// [onDispose]: 현재 페이지에서 정리할 리소스가 있다면 실행할 콜백
  static void handleTabChange(
    BuildContext context,
    BottomNavTab currentTab,
    BottomNavTab targetTab, {
    VoidCallback? onDispose,
  }) {
    // 같은 탭이면 아무것도 하지 않음
    if (currentTab == targetTab) return;

    // 리소스 정리 (dispose 콜백 실행)
    onDispose?.call();

    // 탭에 따른 페이지 이동
    switch (targetTab) {
      case BottomNavTab.home:
      case BottomNavTab.leaderboard:
      case BottomNavTab.analysis:
      case BottomNavTab.profile:
        // MainPage로 이동 (선택된 탭으로)
        _navigateToMainPage(context, targetTab);
        break;
      case BottomNavTab.map:
        // MapPage로 이동 (독립 페이지)
        _navigateToMapPage(context);
        break;
    }
  }

  /// 로그인 성공 후 MainPage로 이동
  static void navigateToMainAfterLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      _createPageRoute(const MainPage()),
    );
  }

  /// 로그아웃 후 LoginPage로 이동 (모든 페이지 스택 제거)
  static void navigateToLoginAfterLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _createPageRoute(const LoginPage()),
      (route) => false, // 모든 이전 페이지 제거
    );
  }

  /// MainPage로 이동
  static void _navigateToMainPage(BuildContext context, BottomNavTab initialTab) {
    Navigator.pushReplacement(
      context,
      _createPageRoute(MainPage(initialTab: initialTab)),
    );
  }

  /// MapPage로 이동
  static void _navigateToMapPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      _createPageRoute(const MapPage()),
    );
  }

  /// 공통 페이지 라우트 생성 (애니메이션 없음)
  static PageRouteBuilder<T> _createPageRoute<T extends Widget>(T page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  /// 특정 탭이 현재 페이지에서 처리되는지 확인
  /// 
  /// 예: MainPage에서는 map 탭만 다른 페이지로 이동
  static bool shouldNavigateToOtherPage(BottomNavTab currentPageType, BottomNavTab targetTab) {
    switch (currentPageType) {
      case BottomNavTab.map:
        // MapPage에서는 map 탭만 현재 페이지에서 처리
        return targetTab != BottomNavTab.map;
      case BottomNavTab.home:
      case BottomNavTab.leaderboard:
      case BottomNavTab.analysis:
      case BottomNavTab.profile:
        // MainPage에서는 map 탭만 다른 페이지로 이동
        return targetTab == BottomNavTab.map;
    }
  }
} 