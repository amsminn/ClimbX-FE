import 'package:flutter/material.dart';
import '../utils/leaderboard_type.dart';
import '../utils/tier_colors.dart';
import '../utils/color_schemes.dart';
import '../models/leaderboard_user.dart';

class LeaderboardBody extends StatefulWidget {
  const LeaderboardBody({super.key});

  @override
  State<LeaderboardBody> createState() => _LeaderboardBodyState();
}

class _LeaderboardBodyState extends State<LeaderboardBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardType _selectedType = LeaderboardType.rating;

  // 임시 더미 데이터 (나중에 API로 교체)
  final List<LeaderboardUser> _ratingUsers = [
    const LeaderboardUser(
      rank: 1,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '대 승 규',
      value: '2847',
      tier: 'Master',
    ),
    const LeaderboardUser(
      rank: 2,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '바위정복자',
      value: '2743',
      tier: 'Diamond I',
    ),
    const LeaderboardUser(
      rank: 3,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '홀드마스터',
      value: '2698',
      tier: 'Diamond I',
    ),
    const LeaderboardUser(
      rank: 4,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '등반러버',
      value: '2521',
      tier: 'Platinum I',
    ),
    const LeaderboardUser(
      rank: 5,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '크랙전문가',
      value: '2456',
      tier: 'Platinum I',
    ),
    const LeaderboardUser(
      rank: 6,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '볼더링퀸',
      value: '2289',
      tier: 'Gold I',
    ),
    const LeaderboardUser(
      rank: 7,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '루트파인더',
      value: '2167',
      tier: 'Gold I',
    ),
    const LeaderboardUser(
      rank: 8,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '멀티피치',
      value: '1998',
      tier: 'Silver I',
    ),
    const LeaderboardUser(
      rank: 9,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '앵커마스터',
      value: '1876',
      tier: 'Silver I',
    ),
    const LeaderboardUser(
      rank: 10,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '비긴너클라이머',
      value: '1654',
      tier: 'Bronze I',
    ),
  ];

  final List<LeaderboardUser> _contributionUsers = [
    const LeaderboardUser(
      rank: 1,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '정보제공자',
      value: '247',
      tier: 'Gold I',
    ),
    const LeaderboardUser(
      rank: 2,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '리뷰어',
      value: '189',
      tier: 'Master',
    ),
    const LeaderboardUser(
      rank: 3,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '길잡이',
      value: '156',
      tier: 'Platinum I',
    ),
    const LeaderboardUser(
      rank: 4,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '헬퍼',
      value: '134',
      tier: 'Diamond I',
    ),
    const LeaderboardUser(
      rank: 5,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '가이드',
      value: '98',
      tier: 'Silver I',
    ),
  ];

  final List<LeaderboardUser> _solvedUsers = [
    const LeaderboardUser(
      rank: 1,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '문제해결사',
      value: '1,247',
      tier: 'Master',
    ),
    const LeaderboardUser(
      rank: 2,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '도전자',
      value: '1,189',
      tier: 'Diamond I',
    ),
    const LeaderboardUser(
      rank: 3,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '완주자',
      value: '967',
      tier: 'Platinum I',
    ),
    const LeaderboardUser(
      rank: 4,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '지속자',
      value: '834',
      tier: 'Gold I',
    ),
    const LeaderboardUser(
      rank: 5,
      profileImageUrl: 'assets/images/avatar.png',
      nickname: '열정가',
      value: '712',
      tier: 'Silver I',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LeaderboardType.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<LeaderboardUser> get _currentUsers {
    switch (_selectedType) {
      case LeaderboardType.rating:
        return _ratingUsers;
      case LeaderboardType.contribution:
        return _contributionUsers;
      case LeaderboardType.solvedProblems:
        return _solvedUsers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 탭바
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundPrimary,
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
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColorSchemes.backgroundPrimary,
            unselectedLabelColor: AppColorSchemes.textSecondary,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColorSchemes.textSecondary,
                  AppColorSchemes.textSpecial,
                ],
              ),
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
            onTap: (index) {
              setState(() {
                _selectedType = LeaderboardType.values[index];
              });
            },
            tabs: LeaderboardType.values
                .map((type) => _buildTab(type.label))
                .toList(),
          ),
        ),

        // 리더보드 리스트
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: _currentUsers.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardItem(_currentUsers[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Transform.translate(
        offset: const Offset(0, 2),
        child: Text(text, style: const TextStyle(height: 1.0)),
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user) {
    final TierType tierType = TierColors.getTierFromString(user.tier);
    final TierColorScheme tierColorScheme = TierColors.getColorScheme(tierType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorSchemes.backgroundPrimary,
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
      child: Row(
        children: [
          // 등수
          Text(
            '${user.rank}',
            style: const TextStyle(
              color: AppColorSchemes.textSpecial,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),

          const SizedBox(width: 32),

          // 프로필 사진
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tierColorScheme.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                user.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColorSchemes.backgroundTertiary,
                    child: const Icon(
                      Icons.person,
                      color: AppColorSchemes.textTertiary,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 닉네임과 티어
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColorSchemes.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: tierColorScheme.gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.tier,
                    style: const TextStyle(
                      color: AppColorSchemes.backgroundPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 값 (티어 그라디언트 적용)
          ShaderMask(
            shaderCallback: (bounds) => tierColorScheme.gradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              user.value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white, // ShaderMask를 위해 흰색으로 설정
              ),
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
