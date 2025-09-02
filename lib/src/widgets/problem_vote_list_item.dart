import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../models/problem_vote.dart';
import '../models/user_profile.dart';
import '../api/user.dart';
import '../utils/color_schemes.dart';
import '../utils/tier_colors.dart';
import '../utils/problem_tier.dart';

class ProblemVoteListItem extends HookWidget {
  final ProblemVote vote;

  const ProblemVoteListItem({super.key, required this.vote});

  @override
  Widget build(BuildContext context) {
    // 사용자 티어 조회 (닉네임 기반)
    final userQuery = useQuery<UserProfile, Exception>(
      ['user_profile', vote.nickname],
      () => UserApi.getUserProfileByNickname(vote.nickname),
    );

    final userProfile = userQuery.data;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorSchemes.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorSchemes.borderPrimary, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _avatarWithTierBorder(userProfile?.profileImageCdnUrl, vote.nickname, userProfile?.rating.totalRating),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vote.nickname,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColorSchemes.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (userProfile != null)
                            _UserTierGradientBadge(rating: userProfile.rating.totalRating),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (vote.tier != null && vote.tier!.isNotEmpty)
                _VotedTierRightPill(tierLabel: vote.tier!, userTierDisplay: userProfile != null ? ProblemTierHelper.getDisplayName(userProfile.rating.totalRating) : null),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(vote.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppColorSchemes.textTertiary,
            ),
          ),
          if (vote.comment != null && vote.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text(
              '의견:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColorSchemes.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              vote.comment!,
              style: const TextStyle(
                fontSize: 15,
                color: AppColorSchemes.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarWithTierBorder(String? imageUrl, String nickname, int? rating) {
    const double size = 36;
    ImageProvider provider = const AssetImage('assets/images/avatar.png');
    if (imageUrl != null && imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      provider = NetworkImage(imageUrl);
    }
    // 랭킹 아이템 스타일: 티어 색 테두리 적용
    final tierType = rating != null ? ProblemTierHelper.getType(rating) : TierType.bronze;
    final scheme = TierColors.getColorScheme(tierType);
    final borderColor = scheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image(
          image: provider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return date.toIso8601String().split('T').first;
  }
}

class _VotedTierRightPill extends StatelessWidget {
  final String tierLabel;
  final String? userTierDisplay;
  const _VotedTierRightPill({required this.tierLabel, this.userTierDisplay});

  @override
  Widget build(BuildContext context) {
    final mapped = ProblemTierHelper.getDisplayAndTypeFromCode(tierLabel);
    final display = mapped.display;
    final type = mapped.type;
    final scheme = TierColors.getColorScheme(type);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '투표:',
          style: TextStyle(
            fontSize: 14,
            color: AppColorSchemes.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: scheme.gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Text(
            display,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColorSchemes.backgroundPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  // 코드 변환은 ProblemTierHelper.getDisplayAndTypeFromCode 사용으로 통일
}

class _UserTierBadge extends StatelessWidget {
  final int rating;
  const _UserTierBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final type = ProblemTierHelper.getType(rating);
    final display = ProblemTierHelper.getDisplayName(rating);
    final scheme = TierColors.getColorScheme(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: scheme.gradient,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        display,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColorSchemes.backgroundPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _UserTierGradientBadge extends StatelessWidget {
  final int rating;
  const _UserTierGradientBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return _UserTierBadge(rating: rating);
  }
}


