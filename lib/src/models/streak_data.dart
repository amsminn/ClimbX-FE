import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_data.freezed.dart';
part 'streak_data.g.dart';

/// 개별 스트릭 항목 (API 응답 구조)
@freezed
abstract class StreakItem with _$StreakItem {
  const factory StreakItem({
    required DateTime date,
    @Default(0) int value,
  }) = _StreakItem;

  /// 서버 응답에서 생성
  factory StreakItem.fromJson(Map<String, dynamic> json) => _$StreakItemFromJson(json);
}

/// 스트릭 통계 데이터
class StreakStats {
  final int currentStreak;   // 현재 연속 주간 스트릭
  final int longestStreak;   // 최장 연속 주간 스트릭
  final int totalDays;       // 총 방문 일수

  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
  });

  /// 기본값 생성
  factory StreakStats.empty() {
    return const StreakStats(
      currentStreak: 0,
      longestStreak: 0,
      totalDays: 0,
    );
  }

  @override
  String toString() {
    return 'StreakStats(currentStreak: $currentStreak, longestStreak: $longestStreak, totalDays: $totalDays)';
  }
}

/// 스트릭 데이터 (2차원 배열 형태로 변환)
class StreakData {
  final List<StreakItem> items;
  final List<List<int>> weeklyData; // 24주 x 7일 형태 (위젯에서 바로 사용)
  final int currentStreak;
  final int longestStreak;
  final int totalDays;

  StreakData({
    required this.items,
    required this.weeklyData,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
  });

  /// 서버 응답 데이터에서 생성 (2차원 배열 변환 포함)
  factory StreakData.fromJson(List<dynamic> jsonList) {
    final items = jsonList
        .map((json) => StreakItem.fromJson(json as Map<String, dynamic>))
        .toList();

    // 2차원 배열 변환 (24주 x 7일)
    final weeklyData = _convertToWeeklyGrid(items);

    // 통계 계산
    final stats = _calculateStats(items);

    return StreakData(
      items: items,
      weeklyData: weeklyData,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      totalDays: stats.totalDays,
    );
  }

  /// 1차원 스트릭 데이터를 24주 x 7일 2차원 배열로 변환
  static List<List<int>> _convertToWeeklyGrid(List<StreakItem> items) {
    const int WEEKS = 24;
    const int DAYS_PER_WEEK = 7;

    // 현재 날짜에서 정확히 24주 전의 월요일을 찾기 (GitHub 스타일)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘이 속한 주의 월요일 찾기
    final currentWeekday = today.weekday; // 1 = 월요일, 7 = 일요일
    final thisWeekMonday = today.subtract(Duration(days: currentWeekday - 1));

    // 24주 전의 월요일 (그리드의 시작점)
    final startDate = thisWeekMonday.subtract(
      const Duration(days: (WEEKS - 1) * DAYS_PER_WEEK),
    );

    // 24주 x 7일 배열 생성 및 데이터 채우기
    return List.generate(
      WEEKS,
      (weekIndex) => List.generate(DAYS_PER_WEEK, (dayIndex) {
        final targetDate = startDate.add(
          Duration(days: weekIndex * DAYS_PER_WEEK + dayIndex),
        );
        
        // 해당 날짜에 맞는 item 찾기
        final item = items.firstWhere(
          (item) => item.date.year == targetDate.year &&
                    item.date.month == targetDate.month &&
                    item.date.day == targetDate.day,
          orElse: () => StreakItem(date: targetDate, value: 0),
        );
        
        return item.value;
      }),
    );
  }

  /// 스트릭 통계 계산
  static StreakStats _calculateStats(List<StreakItem> items) {
    // 데이터가 없는 경우 기본값 반환
    if (items.isEmpty) {
      return StreakStats.empty();
    }

    // 주별 기록 여부 맵 생성 (key: 주의 시작일(일요일), value: 기록 여부)
    final weekMap = <DateTime, bool>{};
    for (final item in items) {
      if (item.value <= 0) continue;
      
      // 해당 날짜가 속한 주의 시작일(일요일) 계산
      final weekStart = _calcWeekStart(item.date);
      weekMap[weekStart] = true;
    }

    // 주별 기록을 날짜순으로 정렬
    final weekDates = weekMap.keys.toList()..sort();

    // 각각의 통계 계산
    final longestStreak = _calculateLongestStreak(weekDates);
    final currentStreak = _calculateCurrentStreak(weekMap);
    final totalDays = _calculateTotalDays(items);

    return StreakStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalDays: totalDays,
    );
  }

  /// 최장 연속 주간 스트릭 계산
  static int _calculateLongestStreak(List<DateTime> weekDates) {
    if (weekDates.isEmpty) return 0;

    // 스트릭 카운트 변수들
    int longestStreak = 0;  // 가장 길었던 연속 주간 스트릭
    int tempStreak = 0;     // 현재까지의 연속 주간 스트릭
    DateTime? lastWeek;     // 마지막으로 기록된 주

    // 주별 기록을 순회하며 연속 스트릭 계산
    for (final weekStart in weekDates) {
      if (lastWeek == null) {
        tempStreak = 1;
        lastWeek = weekStart;
        continue;
      }

      // 이전 주와의 차이 계산 (7일이면 연속된 주)
      final weekDiff = weekStart.difference(lastWeek).inDays;
      if (weekDiff == 7) {
        // 연속된 주간 기록
        tempStreak++;
      } else {
        // 연속이 끊긴 경우 최장 기록 업데이트 후 새로운 스트릭 시작
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
      lastWeek = weekStart;
    }

    // 마지막 스트릭이 최장 기록인지 확인
    return tempStreak > longestStreak ? tempStreak : longestStreak;
  }

  /// 현재 진행 중인 스트릭 계산
  static int _calculateCurrentStreak(Map<DateTime, bool> weekMap) {
    if (weekMap.isEmpty) return 0;

    final today = DateTime.now();
    final currentWeekStart = _calcWeekStart(today);
    final lastWeekStart = _calcWeekStart(today.subtract(const Duration(days: 7)));

    // 이번 주에 방문 기록이 있으면 스트릭 유지
    if (weekMap.containsKey(currentWeekStart)) {
      return _getStreakLength(weekMap, currentWeekStart);
    }

    // 지난 주에 방문했으면 스트릭 유지 (이번 주는 아직 기회 있음)
    if (weekMap.containsKey(lastWeekStart)) {
      return _getStreakLength(weekMap, lastWeekStart);
    }

    // 지난 주에도 안 갔으면 스트릭 끊김
    return 0;
  }

  /// 특정 주차부터의 연속 스트릭 길이 계산
  static int _getStreakLength(Map<DateTime, bool> weekMap, DateTime weekStart) {
    int streak = 0;
    var currentWeek = weekStart;

    // 과거로 거슬러 올라가며 연속된 주 계산
    while (weekMap.containsKey(currentWeek)) {
      streak++;
      currentWeek = currentWeek.subtract(const Duration(days: 7));
    }

    return streak;
  }

  /// 총 방문 일수 계산
  static int _calculateTotalDays(List<StreakItem> items) {
    return items.where((item) => item.value > 0).length;
  }

  /// 주의 시작일(일요일) 계산
  static DateTime _calcWeekStart(DateTime date) {
    final weekday = date.weekday % 7;  // 0: 일요일, 1-6: 월-토
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday));
  }

  @override
  String toString() {
    return 'StreakData(items: ${items.length}, currentStreak: $currentStreak, longestStreak: $longestStreak, totalDays: $totalDays)';
  }
}
