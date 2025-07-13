import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widgets/profile_body.dart';
import '../utils/tier_test_helper.dart';
import '../utils/tier_colors.dart';
import '../utils/color_schemes.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 티어를 저장 (임시로 디버깅용으로 이렇게 해두었음, 수정 예정)
    final currentTier = useState([
      'Bronze I',
      'Silver I',
      'Gold I',
      'Platinum I',
      'Diamond I',
      'Master',
    ][3]);

    // 현재 티어 색상 정보 가져옴
    final TierType tierType = TierColors.getTierFromString(currentTier.value);
    final TierColorScheme colorScheme = TierColors.getColorScheme(tierType);

    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppColorSchemes.backgroundPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'ClimbX',
          style: TextStyle(
            color: AppColorSchemes.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // 팔레트
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.palette_outlined,
                color: AppColorSchemes.textSecondary,
                size: 22,
              ),
              onPressed: () {
                TierTestHelper.showTierSelector(context, (String selectedTier) {
                  currentTier.value = selectedTier;
                });
              },
            ),
          ),
          // 알림
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColorSchemes.textSecondary,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
          // 메뉴
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColorSchemes.textSecondary,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ProfileBody(
        currentTier: currentTier.value,
        colorScheme: colorScheme,
      ),
    );
  }
}
