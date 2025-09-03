import 'package:flutter/material.dart';

// 가능한 티어의 종류들
enum TierType { bronze, silver, gold, platinum, diamond, master }

// 각 티어에 해당하는 색깔들
class TierColors {
  static const Map<TierType, TierColorScheme> _tierColors = {
    TierType.bronze: TierColorScheme(
      gradientStart: Color(0xFFD2691E),
      gradientEnd: Color(0xFFCD853F),
      primary: Color(0xFFD2691E),
      light: Color(0xFFFFF8DC),
      shadow: Color(0x33D2691E),
      streakColor: Color(0xFFB8860B),
    ),
    TierType.silver: TierColorScheme(
      gradientStart: Color(0xFF708090),
      gradientEnd: Color(0xFFC0C0C0),
      primary: Color(0xFF708090),
      light: Color(0xFFF8F8FF),
      shadow: Color(0x33708090),
      streakColor: Color(0xFF708090),
    ),
    TierType.gold: TierColorScheme(
      gradientStart: Color(0xFFFFA500),
      gradientEnd: Color(0xFFFFD700),
      primary: Color(0xFFFFA500),
      light: Color(0xFFFFFAF0),
      shadow: Color(0x33FFA500),
      streakColor: Color(0xFFFF8C00),
    ),
    TierType.platinum: TierColorScheme(
      gradientStart: Color(0xFF27CCCA),
      gradientEnd: Color(0xFF6EEAC0),
      primary: Color(0xFF3ED8C9),
      light: Color(0xFFF0FDFA),
      shadow: Color(0x3340E0D0),
      streakColor: Color(0xFF2DD4CF),
    ),
    TierType.diamond: TierColorScheme(
      gradientStart: Color(0xFF1E90FF),
      gradientEnd: Color(0xFF00BFFF),
      primary: Color(0xFF00BFFF),
      light: Color(0xFFF0F8FF),
      shadow: Color(0x3300BFFF),
      streakColor: Color(0xFF1E90FF),
    ),
    TierType.master: TierColorScheme(
      gradientStart: Color(0xFF805AD5),
      gradientEnd: Color(0xFFD53F8C),
      primary: Color(0xFF805AD5),
      light: Color(0xFFFDF2F8),
      shadow: Color(0x33805AD5),
      streakColor: Color(0xFF6B46C1),
    ),
  };

  // 색상 반환해주는 메서드
  static TierColorScheme getColorScheme(TierType tier) {
    return _tierColors[tier]!;
  }

  // 티어 타입 알려주는 함수
  static TierType getTierFromString(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'bronze':
      case 'bronze i':
      case 'bronze ii':
      case 'bronze iii':
        return TierType.bronze;
      case 'silver':
      case 'silver i':
      case 'silver ii':
      case 'silver iii':
        return TierType.silver;
      case 'gold':
      case 'gold i':
      case 'gold ii':
      case 'gold iii':
        return TierType.gold;
      case 'platinum':
      case 'platinum i':
      case 'platinum ii':
      case 'platinum iii':
        return TierType.platinum;
      case 'diamond':
      case 'diamond i':
      case 'diamond ii':
      case 'diamond iii':
        return TierType.diamond;
      case 'master':
        return TierType.master;
      default:
        return TierType.bronze; // 기본값
    }
  }

  // 티어의 이름
  static String getTierDisplayName(TierType tier) {
    switch (tier) {
      case TierType.bronze:
        return 'Bronze';
      case TierType.silver:
        return 'Silver';
      case TierType.gold:
        return 'Gold';
      case TierType.platinum:
        return 'Platinum';
      case TierType.diamond:
        return 'Diamond';
      case TierType.master:
        return 'Master';
    }
  }

  /// 상세 티어 단계 경계(start 포함, end 미포함) 목록 정의
  /// 마지막 Master 단계는 상한이 없으므로 end를 null로 표기
  static const List<(int start, int? end)> _stepBounds = <(int, int?)>[
    (0, 150),
    (150, 300),
    (300, 450),
    (450, 600),
    (600, 750),
    (750, 900),
    (900, 1050),
    (1050, 1200),
    (1200, 1350),
    (1350, 1500),
    (1500, 1650),
    (1650, 1800),
    (1800, 1950),
    (1950, 2100),
    (2100, 2250),
    (2250, null), // Master
  ];

  /// 단계별 표시 문자열 (경계와 동일한 인덱스)
  static const List<String> _stepDisplayNames = <String>[
    'Bronze III', // 0
    'Bronze II',  // 1
    'Bronze I',   // 2
    'Silver III', // 3
    'Silver II',  // 4
    'Silver I',   // 5
    'Gold III',   // 6
    'Gold II',    // 7
    'Gold I',     // 8
    'Platinum III', // 9
    'Platinum II',  // 10
    'Platinum I',   // 11
    'Diamond III',  // 12
    'Diamond II',   // 13
    'Diamond I',    // 14
    'Master',       // 15
  ];

  /// 단계별 대분류 타입 (경계와 동일한 인덱스)
  static const List<TierType> _stepTierTypes = <TierType>[
    TierType.bronze, // 0
    TierType.bronze, // 1
    TierType.bronze, // 2
    TierType.silver, // 3
    TierType.silver, // 4
    TierType.silver, // 5
    TierType.gold,   // 6
    TierType.gold,   // 7
    TierType.gold,   // 8
    TierType.platinum, // 9
    TierType.platinum, // 10
    TierType.platinum, // 11
    TierType.diamond,  // 12
    TierType.diamond,  // 13
    TierType.diamond,  // 14
    TierType.master,   // 15
  ];

  /// 주어진 레이팅이 속한 단계 인덱스 반환
  static int _findStepIndex(int rating) {
    for (int i = 0; i < _stepBounds.length; i++) {
      final record = _stepBounds[i];
      final int start = record.$1;
      final int? end = record.$2;
      if (end == null) {
        if (rating >= start) return i; // Master 포함
      } else {
        if (rating >= start && rating < end) return i;
      }
    }
    return 0; // fallback
  }

  /// 현재 레이팅이 속한 단계의 시작값 반환
  static int getCurrentStepStart(int rating) {
    for (final (start, end) in _stepBounds) {
      if (end == null) {
        if (rating >= start) return start;
      } else {
        if (rating >= start && rating < end) return start;
      }
    }
    return 0; // fallback
  }

  /// 현재 레이팅에서 다음 단계의 시작값 반환 (Master면 null)
  static int? getNextStepStart(int rating) {
    for (final (start, end) in _stepBounds) {
      if (end == null) {
        if (rating >= start) return null; // Master
      } else {
        if (rating >= start && rating < end) return end;
      }
    }
    return _stepBounds.first.$1; // fallback (0)
  }

  /// Rating 점수를 TierType으로 변환
  static TierType getTierTypeFromRating(int rating) {
    final int idx = _findStepIndex(rating);
    return _stepTierTypes[idx];
  }

  /// Rating 점수를 상세 티어 문자열로 변환
  static String getTierStringFromRating(int rating) {
    final int idx = _findStepIndex(rating);
    return _stepDisplayNames[idx];
  }

  // 아이콘 (추후 티어 모양으로 변환예정)
  static IconData getTierIcon(TierType tier) {
    switch (tier) {
      case TierType.bronze:
        return Icons.workspace_premium;
      case TierType.silver:
        return Icons.military_tech;
      case TierType.gold:
        return Icons.emoji_events;
      case TierType.platinum:
        return Icons.star;
      case TierType.diamond:
        return Icons.diamond;
      case TierType.master:
        return Icons.stars;
    }
  }
}

class TierColorScheme {
  final Color gradientStart;
  final Color gradientEnd;
  final Color primary;
  final Color light;
  final Color shadow;
  final Color streakColor; // 스트릭 전용 색상 추가

  const TierColorScheme({
    required this.gradientStart,
    required this.gradientEnd,
    required this.primary,
    required this.light,
    required this.shadow,
    required this.streakColor,
  });

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}
