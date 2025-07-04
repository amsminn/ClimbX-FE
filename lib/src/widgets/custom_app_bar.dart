import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../utils/tier_test_helper.dart';
import '../utils/navigation_helper.dart';
import '../api/auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentTier;
  final Function(String) onTierChanged;

  const CustomAppBar({
    super.key,
    required this.currentTier,
    required this.onTierChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

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

      // 액션들
      actions: [
        // 로그아웃 버튼 (임시, 나중에 제거 예정)
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF64748B), size: 22),
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ),
        // 팔레트 (임시, 나중에 제거 예정)
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
              TierTestHelper.showTierSelector(context, onTierChanged);
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // 로그아웃 처리
  static void _handleLogout(BuildContext context) {
    developer.log('로그아웃 요청', name: 'CustomAppBar');

    AuthHelpers.clearToken()
        .then((_) {
          developer.log('토큰 삭제 완료', name: 'CustomAppBar');
          
          // LoginPage로 이동
          if (context.mounted) {
            NavigationHelper.navigateToLoginAfterLogout(context);
            developer.log('LoginPage로 이동 완료', name: 'CustomAppBar');
          }
        })
        .catchError((error) {
          developer.log('로그아웃 실패: $error', name: 'CustomAppBar');
        });
  }
}
