import 'package:flutter/material.dart';
import '../utils/tier_colors.dart';
import '../utils/color_schemes.dart';
import '../utils/tier_provider.dart';
import '../models/user_profile.dart';

class TierWidget extends StatelessWidget {
  final UserProfile userProfile;

  const TierWidget({
    super.key, 
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final TierColorScheme colorScheme = TierProvider.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: screenWidth - 32, // 좌우 여백 고려
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColorSchemes.defaultGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: colorScheme.gradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'USER RATING',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColorSchemes.backgroundPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // TODO: 백엔드에서 전체 유저 수와 랭킹 %를 API로 제공하면 주석 해제
                // const SizedBox(width: 8),
                // Flexible(
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 6,
                //     ),
                //     decoration: BoxDecoration(
                //       color: AppColorSchemes.backgroundTertiary,
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           '#${userProfile.ranking}',
                //           style: TextStyle(
                //             fontSize: 14,
                //             fontWeight: FontWeight.w700,
                //             color: colorScheme.primary,
                //           ),
                //         ),
                //         const SizedBox(width: 6),
                //         Flexible(
                //           child: Text(
                //             '상위 0.1%',
                //             style: TextStyle(
                //               fontSize: 12,
                //               color: AppColorSchemes.textSecondary,
                //               fontWeight: FontWeight.w500,
                //             ),
                //             overflow: TextOverflow.ellipsis,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),

            SizedBox(height: screenWidth * 0.05),

            // 메인 티어 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          userProfile.displayTier,
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 20 : 24,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${userProfile.rating.totalRating}',
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 28 : 32,
                            fontWeight: FontWeight.w900,
                            color: AppColorSchemes.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 티어 아이콘 자리 (나중에 이미지로 교체)
                Container(
                  width: screenWidth * 0.14,
                  height: screenWidth * 0.14,
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 50,
                    maxWidth: 70,
                    maxHeight: 70,
                  ),
                  decoration: BoxDecoration(
                    gradient: colorScheme.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    TierColors.getTierIcon(userProfile.tierType),
                    color: AppColorSchemes.backgroundPrimary,
                    size: screenWidth * 0.07,
                  ),
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.04),

            // 상세 정보
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColorSchemes.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorSchemes.borderPrimary, width: 1),
              ),
              child: Builder(builder: (context) {
                final ratingItems = [
                  (icon: Icons.trending_up, label: '상위 50문제 난이도 합', value: userProfile.rating.topProblemRating),
                  (icon: Icons.check_circle_outline, label: '해결한 문제 수', value: userProfile.rating.solvedRating),
                  (icon: Icons.outbox, label: '제출한 문제 수', value: userProfile.rating.submissionRating),
                  (icon: Icons.volunteer_activism, label: '기여한 문제 수', value: userProfile.rating.contributionRating),
                ];

                Widget buildRatingRow({required IconData icon, required String label, required int value}) {
                  return Row(
                    children: [
                      Icon(icon, color: colorScheme.primary, size: 20),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 12 : 13,
                            color: AppColorSchemes.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '+$value',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < ratingItems.length; i++) ...[
                      buildRatingRow(
                        icon: ratingItems[i].icon,
                        label: ratingItems[i].label,
                        value: ratingItems[i].value,
                      ),
                      if (i < ratingItems.length - 1) SizedBox(height: screenWidth * 0.02),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
