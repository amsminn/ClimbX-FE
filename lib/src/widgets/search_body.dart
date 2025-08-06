import 'package:flutter/material.dart';
import '../api/problem.dart';
import '../api/gym.dart';
import '../models/problem.dart';
import '../models/gym.dart';
import '../utils/color_schemes.dart';
import 'problem_grid_item.dart';
import 'search_filter_dropdown.dart';

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
  
  // 드롭다운 상태 관리
  String? _openDropdown; // 현재 열려있는 드롭다운 식별자

  // 문제 리스트 상태
  List<Problem> _problems = [];
  bool _isLoading = false;

  // 사용 가능한 필터 옵션 (수정필요)
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
      // API 호출 실패 시 빈 리스트로 설정
      setState(() {
        _gyms = [];
        _filteredGyms = [];
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
        activeStatus: 'active',
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
            .where(
              (gym) => gym.name.toLowerCase().contains(query.toLowerCase()),
            )
            .take(3) // 상위 3개만 표시
            .toList();
      }
    });
  }

  /// 검색어 초기화
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _selectedGym = null; // 선택된 클라이밍장도 초기화
      _filteredGyms = _gyms;
    });
    _loadProblems(); // 클라이밍장 선택 해제 후 문제 목록 다시 로드
  }

  /// 드롭다운 상태 변경 처리
  void _onDropdownStateChanged(String? openDropdownId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _openDropdown = openDropdownId;
        });
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

  /// 선택된 클라이밍장의 gymId 반환
  int? get selectedGymId => _selectedGym?.gymId;

  /// 난이도 필터 변경 처리
  void _onLocalLevelChanged(String? level) {
    setState(() {
      _selectedLocalLevel = level; // null이면 "모두" 선택
    });
    _loadProblems();
  }
  
  /// 홀드색 필터 변경 처리  
  void _onHoldColorChanged(String? color) {
    setState(() {
      _selectedHoldColor = color; // null이면 "모두" 선택
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

        // 필터와 리스트 사이 간격
        const SizedBox(height: 16),

        // 문제 리스트
        Expanded(child: _buildProblemList()),
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColorSchemes.textSecondary,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 난이도색 필터
          SearchFilterDropdown(
            identifier: 'difficulty',
            title: '난이도색',
            options: localLevelOptions,
            selectedOption: _selectedLocalLevel,
            onOptionSelected: _onLocalLevelChanged,
            onDropdownStateChanged: _onDropdownStateChanged,
            forceClose: _openDropdown != null && _openDropdown != 'difficulty',
          ),

          const SizedBox(width: 8), // 간격 축소
          // 홀드색 필터
          SearchFilterDropdown(
            identifier: 'holdColor',
            title: '홀드색',
            options: holdColorOptions,
            selectedOption: _selectedHoldColor,
            onOptionSelected: _onHoldColorChanged,
            onDropdownStateChanged: _onDropdownStateChanged,
            forceClose: _openDropdown != null && _openDropdown != 'holdColor',
          ),
        ],
      ),
    );
  }

  /// 문제 리스트 위젯
  Widget _buildProblemList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              _selectedGym == null ? '클라이밍장을 선택해주세요' : '조건에 맞는 문제가 없습니다',
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
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2열
          crossAxisSpacing: 12, // 가로 간격
          mainAxisSpacing: 16, // 세로 간격
          childAspectRatio: 0.8, // 아이템 비율 (세로가 더 길게)
        ),
        itemCount: _problems.length,
        itemBuilder: (context, index) {
          return ProblemGridItem(
            problem: _problems[index],
            gymId: selectedGymId,
          );
        },
      ),
    );
  }
}
