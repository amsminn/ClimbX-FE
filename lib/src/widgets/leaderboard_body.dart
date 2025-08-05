import 'package:flutter/material.dart';
import '../api/leaderboard.dart';
import '../api/util/core/api_client.dart';
import '../models/leaderboard_item.dart';
import '../utils/color_schemes.dart';
import '../utils/leaderboard_type.dart';
import '../utils/tier_colors.dart';

/// 리더보드 메인 위젯
class LeaderboardBody extends StatefulWidget {
  const LeaderboardBody({super.key});

  @override
  State<LeaderboardBody> createState() => _LeaderboardBodyState();
}

class _LeaderboardBodyState extends State<LeaderboardBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardType _selectedType = LeaderboardType.rating;
  
  // API 호출 상태 관리
  final Map<LeaderboardType, Future<List<LeaderboardItem>>?> _leaderboardFutures = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LeaderboardType.values.length,
      vsync: this,
    );
    
    // 탭 변경 리스너 추가
    _tabController.addListener(_onTabChanged);
    
    // 초기 데이터 로드
    _loadLeaderboard(_selectedType);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 리더보드 데이터 로드
  void _loadLeaderboard(LeaderboardType type) {
    setState(() {
      _leaderboardFutures[type] = LeaderboardApi.getRanking(type: type);
    });
  }

  /// 탭 변경 처리
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _selectedType = LeaderboardType.values[_tabController.index];
      
      // 새로운 탭의 데이터가 없으면 로드
      if (_leaderboardFutures[_selectedType] == null) {
        _loadLeaderboard(_selectedType);
      }
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
            tabs: LeaderboardType.values
                .map((type) => _buildTab(type.label))
                .toList(),
          ),
        ),

        // 슬라이드 가능한 리더보드 페이지들
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: LeaderboardType.values.map((type) {
              return _buildLeaderboardPage(type);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 각 탭별 리더보드 페이지 빌드
  Widget _buildLeaderboardPage(LeaderboardType type) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<LeaderboardItem>>(
        future: _leaderboardFutures[type],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColorSchemes.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColorSchemes.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadLeaderboard(type),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Text(
                '리더보드 데이터가 없습니다',
                style: TextStyle(
                  color: AppColorSchemes.textSecondary,
                  fontSize: 14,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _buildLeaderboardItem(users[index]);
            },
          );
        },
      ),
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

  Widget _buildLeaderboardItem(LeaderboardItem user) {
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
              borderRadius: BorderRadius.circular(22.5),
              child: _buildProfileImage(user.profileImageCdnUrl),
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

  /// 프로필 이미지 빌드 (네트워크 이미지 또는 기본 아바타)
  Widget _buildProfileImage(String? profileImageCdnUrl) {
    // 기본 아바타 위젯 
    final Widget defaultAvatar = Container(
      color: AppColorSchemes.backgroundTertiary,
      child: const Icon(
        Icons.person,
        color: AppColorSchemes.textTertiary,
        size: 20,
      ),
    );

    if (profileImageCdnUrl == null || profileImageCdnUrl.isEmpty) {
      return defaultAvatar;
    }

    // 네트워크 이미지인지 로컬 이미지인지 판단
    if (profileImageCdnUrl.startsWith('/images/')) {
      // 백엔드 이미지 경로에 base URL 추가
      final fullUrl = '${ApiClient.baseUrl}$profileImageCdnUrl';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultAvatar,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColorSchemes.backgroundTertiary,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
      );
    }

    // 로컬 asset 이미지
    return Image.asset(
      profileImageCdnUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => defaultAvatar,
    );
  }
}
