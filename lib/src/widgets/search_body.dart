import 'package:flutter/material.dart';
import '../api/problem.dart';
import '../api/gym.dart';
import '../models/problem.dart';
import '../models/gym.dart';
import '../utils/color_schemes.dart';
import 'problem_list_item.dart';
import 'search_filter_toggle.dart';

/// 검색 탭 메인 위젯
class SearchBody extends StatefulWidget {
  const SearchBody({super.key});

  @override
  State<SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  // 검색 관련 상태
  final TextEditingController _searchController = TextEditingController();
  List<Gym> _gyms = [];
  List<Gym> _filteredGyms = [];
  Gym? _selectedGym;
  bool _isSearching = false;

  // 필터 관련 상태
  String? _selectedLocalLevel;
  String? _selectedHoldColor;

  // 문제 리스트 상태
  List<Problem> _problems = [];
  bool _isLoading = false;

  // 사용 가능한 필터 옵션
  static const List<String> localLevelOptions = ['빨강', '파랑', '초록', '노랑', '보라'];
  static const List<String> holdColorOptions = ['빨강', '파랑', '초록', '노랑', '보라'];

  @override
  void initState() {
    super.initState();
    _loadGyms();
    _loadProblems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 클라이밍장 목록 로드
  Future<void> _loadGyms() async {
    try {
      final gyms = await GymApi.getAllGyms();
      setState(() {
        _gyms = gyms;
        _filteredGyms = gyms;
      });
    } catch (e) {
      // 에러 처리 (더미 데이터 사용)
      setState(() {
        _gyms = [
          Gym(
            gymId: 1,
            name: '더클라임 클라이밍 B 홍대점',
            latitude: 37.5665,
            longitude: 126.9780,
            address: '서울특별시 마포구 홍대로 123',
            phoneNumber: '02-1234-5678',
            description: '홍대 근처 클라이밍장',
            map2DUrl: 'https://example.com/map1.jpg',
          ),
          Gym(
            gymId: 2,
            name: '더클라임 클라이밍 일산점',
            latitude: 37.6584,
            longitude: 126.7698,
            address: '경기도 고양시 일산동구 456',
            phoneNumber: '031-9876-5432',
            description: '일산 지역 클라이밍장',
            map2DUrl: 'https://example.com/map2.jpg',
          ),
        ];
        _filteredGyms = _gyms;
      });
    }
  }

  /// 문제 목록 로드
  Future<void> _loadProblems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final problems = await ProblemApi.getProblems(
        gymId: _selectedGym?.gymId,
        localLevel: _selectedLocalLevel,
        holdColor: _selectedHoldColor,
      );
      
      setState(() {
        _problems = problems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _problems = [];
        _isLoading = false;
      });
    }
  }

  /// 검색어 변경 처리
  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredGyms = _gyms;
      } else {
        _filteredGyms = _gyms
            .where((gym) => gym.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  /// 클라이밍장 선택 처리
  void _onGymSelected(Gym gym) {
    setState(() {
      _selectedGym = gym;
      _searchController.text = gym.name;
      _isSearching = false;
    });
    _loadProblems();
  }

  /// 필터 변경 처리
  void _onFilterChanged({String? localLevel, String? holdColor}) {
    setState(() {
      if (localLevel != null) {
        _selectedLocalLevel = _selectedLocalLevel == localLevel ? null : localLevel;
      }
      if (holdColor != null) {
        _selectedHoldColor = _selectedHoldColor == holdColor ? null : holdColor;
      }
    });
    _loadProblems();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색바
        _buildSearchBar(),
        
        // 필터 토글
        _buildFilterSection(),
        
        // 문제 리스트
        Expanded(
          child: _buildProblemList(),
        ),
      ],
    );
  }

  /// 검색바 위젯
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색 입력 필드
          Container(
            decoration: BoxDecoration(
              color: AppColorSchemes.backgroundPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColorSchemes.lightShadow,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '클라이밍장을 검색하세요',
                hintStyle: const TextStyle(
                  color: AppColorSchemes.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColorSchemes.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // 검색 결과 드롭다운
          if (_isSearching && _filteredGyms.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColorSchemes.backgroundPrimary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColorSchemes.lightShadow,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredGyms.length,
                itemBuilder: (context, index) {
                  final gym = _filteredGyms[index];
                  return ListTile(
                    title: Text(
                      gym.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColorSchemes.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      gym.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColorSchemes.textSecondary,
                      ),
                    ),
                    onTap: () => _onGymSelected(gym),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 필터 섹션 위젯
  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '필터',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColorSchemes.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // 난이도색 필터
          SearchFilterToggle(
            title: '난이도색',
            options: localLevelOptions,
            selectedOption: _selectedLocalLevel,
            onOptionSelected: (option) => _onFilterChanged(localLevel: option),
          ),
          
          const SizedBox(height: 12),
          
          // 홀드색 필터
          SearchFilterToggle(
            title: '홀드색',
            options: holdColorOptions,
            selectedOption: _selectedHoldColor,
            onOptionSelected: (option) => _onFilterChanged(holdColor: option),
          ),
        ],
      ),
    );
  }

  /// 문제 리스트 위젯
  Widget _buildProblemList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_problems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColorSchemes.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedGym == null 
                ? '클라이밍장을 선택해주세요'
                : '조건에 맞는 문제가 없습니다',
              style: const TextStyle(
                color: AppColorSchemes.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: _problems.length,
        itemBuilder: (context, index) {
          return ProblemListItem(problem: _problems[index]);
        },
      ),
    );
  }
} 