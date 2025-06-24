import 'package:flutter/material.dart';
import '../utils/tier_test_helper.dart';

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
} 