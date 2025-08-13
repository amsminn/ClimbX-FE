import 'package:flutter/material.dart';
import '../screens/main_page.dart';
import '../screens/login_page.dart';
import '../utils/bottom_nav_tab.dart';
import '../screens/settings_page.dart';
import '../screens/markdown_viewer_page.dart';
import '../screens/email_compose_page.dart';

/// 공통 네비게이션 처리 헬퍼
class NavigationHelper {
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

  /// 지도에서 검색 탭으로 이동하며 특정 지점을 프리필
  static void navigateToSearchWithGym(BuildContext context, int gymId) {
    // 현재 트리에서 MainPageState를 찾아 탭만 전환
    final mainState = context.findAncestorStateOfType<MainPageState>();
    if (mainState != null) {
      mainState.switchToSearchWithGym(gymId);
      return;
    }

    // 예외적 상황(컨텍스트에 MainPage가 없을 때)만 대체 내비게이션 수행
    Navigator.pushReplacement(
      context,
      _createPageRoute(
        MainPage(
          initialTab: BottomNavTab.search,
          initialGymIdForSearch: gymId,
        ),
      ),
    );
  }

  /// 설정 페이지로 이동
  static void navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      _createPageRoute(const SettingsPage()),
    );
  }

  /// 마크다운 문서 뷰어로 이동
  static void navigateToMarkdown(
    BuildContext context, {
    required String title,
    required String assetPath,
  }) {
    Navigator.push(
      context,
      _createPageRoute(
        MarkdownViewerPage(title: title, assetPath: assetPath),
      ),
    );
  }

  /// 이메일 작성 화면으로 이동
  static void navigateToEmailCompose(
    BuildContext context, {
    required String title,
    required String toEmail,
    required String subject,
    String? hint,
    String? contentId,
  }) {
    Navigator.push(
      context,
      _createPageRoute(
        EmailComposePage(
          title: title,
          toEmail: toEmail,
          defaultSubject: subject,
          hint: hint,
          contentId: contentId,
        ),
      ),
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
} 