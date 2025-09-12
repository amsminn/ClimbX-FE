import 'package:flutter/material.dart';
import '../utils/navigation_helper.dart';
import '../utils/color_schemes.dart';
import '../screens/login_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isGuestMode;
  
  const CustomAppBar({
    super.key,
    this.isGuestMode = false,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: AppColorSchemes.backgroundPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

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
      titleSpacing: 24.0,
      centerTitle: false, // 왼쪽 정렬

      // 액션들
      actions: [
        if (isGuestMode)
          // 게스트 모드: 로그인 버튼
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(
                Icons.login,
                color: AppColorSchemes.accentBlue,
                size: 20,
              ),
              label: const Text(
                '로그인',
                style: TextStyle(
                  color: AppColorSchemes.accentBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColorSchemes.backgroundSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          // 로그인 모드: 설정 버튼
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppColorSchemes.textSecondary,
                size: 22,
              ),
              onPressed: () {
                NavigationHelper.navigateToSettings(context);
              },
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
