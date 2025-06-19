import 'package:flutter/material.dart';

enum TierType { bronze, silver, gold, platinum, diamond, master }

class TierColors {
  static const Map<TierType, TierColorScheme> _tierColors = {
    TierType.bronze: TierColorScheme(
      gradientStart: Color(0xFFD2691E),
      gradientEnd: Color(0xFFCD853F),
      primary: Color(0xFFD2691E),
      light: Color(0xFFFFF8DC),
      shadow: Color(0x33D2691E),
    ),
    TierType.silver: TierColorScheme(
      gradientStart: Color(0xFF708090),
      gradientEnd: Color(0xFFC0C0C0),
      primary: Color(0xFFC0C0C0),
      light: Color(0xFFF8F8FF),
      shadow: Color(0x33C0C0C0),
    ),
    TierType.gold: TierColorScheme(
      gradientStart: Color(0xFFFFA500),
      gradientEnd: Color(0xFFFFD700),
      primary: Color(0xFFFFD700),
      light: Color(0xFFFFFAF0),
      shadow: Color(0x33FFD700),
    ),
    TierType.platinum: TierColorScheme(
      gradientStart: Color(0xFF38B2AC),
      gradientEnd: Color(0xFF4FD1C7),
      primary: Color(0xFF38B2AC),
      light: Color(0xFFF0FDFA),
      shadow: Color(0x3338B2AC),
    ),
    TierType.diamond: TierColorScheme(
      gradientStart: Color(0xFF1E90FF),
      gradientEnd: Color(0xFF00BFFF),
      primary: Color(0xFF00BFFF),
      light: Color(0xFFF0F8FF),
      shadow: Color(0x3300BFFF),
    ),
    TierType.master: TierColorScheme(
      gradientStart: Color(0xFF805AD5),
      gradientEnd: Color(0xFFD53F8C),
      primary: Color(0xFF805AD5),
      light: Color(0xFFFDF2F8),
      shadow: Color(0x33805AD5),
    ),
  };

  static TierColorScheme getColorScheme(TierType tier) {
    return _tierColors[tier]!;
  }

  static TierType getTierFromString(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'bronze':
      case 'bronze i':
      case 'bronze ii':
      case 'bronze iii':
      case 'bronze iv':
      case 'bronze v':
        return TierType.bronze;
      case 'silver':
      case 'silver i':
      case 'silver ii':
      case 'silver iii':
      case 'silver iv':
      case 'silver v':
        return TierType.silver;
      case 'gold':
      case 'gold i':
      case 'gold ii':
      case 'gold iii':
      case 'gold iv':
      case 'gold v':
        return TierType.gold;
      case 'platinum':
      case 'platinum i':
      case 'platinum ii':
      case 'platinum iii':
      case 'platinum iv':
      case 'platinum v':
        return TierType.platinum;
      case 'diamond':
      case 'diamond i':
      case 'diamond ii':
      case 'diamond iii':
      case 'diamond iv':
      case 'diamond v':
        return TierType.diamond;
      case 'master':
        return TierType.master;
      default:
        return TierType.bronze; // 기본값
    }
  }

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

  const TierColorScheme({
    required this.gradientStart,
    required this.gradientEnd,
    required this.primary,
    required this.light,
    required this.shadow,
  });

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}
