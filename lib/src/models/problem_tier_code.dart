import '../utils/tier_colors.dart';

/// 문제 난이도 티어 코드 enum
enum ProblemTierCode {
  // Bronze
  b3,
  b2,
  b1,
  
  // Silver
  s3,
  s2,
  s1,
  
  // Gold
  g3,
  g2,
  g1,
  
  // Platinum
  p3,
  p2,
  p1,
  
  // Diamond
  d3,
  d2,
  d1,
  
  // Master
  master;

  /// 티어 코드 문자열 반환
  String get code => switch (this) {
    ProblemTierCode.b3 => 'B3',
    ProblemTierCode.b2 => 'B2', 
    ProblemTierCode.b1 => 'B1',
    ProblemTierCode.s3 => 'S3',
    ProblemTierCode.s2 => 'S2',
    ProblemTierCode.s1 => 'S1',
    ProblemTierCode.g3 => 'G3',
    ProblemTierCode.g2 => 'G2',
    ProblemTierCode.g1 => 'G1',
    ProblemTierCode.p3 => 'P3',
    ProblemTierCode.p2 => 'P2',
    ProblemTierCode.p1 => 'P1',
    ProblemTierCode.d3 => 'D3',
    ProblemTierCode.d2 => 'D2',
    ProblemTierCode.d1 => 'D1',
    ProblemTierCode.master => 'M',
  };

  /// 표시용 이름 반환
  String get display => switch (this) {
    ProblemTierCode.b3 => 'Bronze III',
    ProblemTierCode.b2 => 'Bronze II',
    ProblemTierCode.b1 => 'Bronze I',
    ProblemTierCode.s3 => 'Silver III',
    ProblemTierCode.s2 => 'Silver II', 
    ProblemTierCode.s1 => 'Silver I',
    ProblemTierCode.g3 => 'Gold III',
    ProblemTierCode.g2 => 'Gold II',
    ProblemTierCode.g1 => 'Gold I',
    ProblemTierCode.p3 => 'Platinum III',
    ProblemTierCode.p2 => 'Platinum II',
    ProblemTierCode.p1 => 'Platinum I',
    ProblemTierCode.d3 => 'Diamond III',
    ProblemTierCode.d2 => 'Diamond II',
    ProblemTierCode.d1 => 'Diamond I',
    ProblemTierCode.master => 'Master',
  };

  /// 티어 타입 반환
  TierType get tierType => switch (this) {
    ProblemTierCode.b3 || ProblemTierCode.b2 || ProblemTierCode.b1 => TierType.bronze,
    ProblemTierCode.s3 || ProblemTierCode.s2 || ProblemTierCode.s1 => TierType.silver,
    ProblemTierCode.g3 || ProblemTierCode.g2 || ProblemTierCode.g1 => TierType.gold,
    ProblemTierCode.p3 || ProblemTierCode.p2 || ProblemTierCode.p1 => TierType.platinum,
    ProblemTierCode.d3 || ProblemTierCode.d2 || ProblemTierCode.d1 => TierType.diamond,
    ProblemTierCode.master => TierType.master,
  };

  /// 문자열로부터 ProblemTierCode 생성
  static ProblemTierCode fromString(String codeStr) {
    return switch (codeStr.toUpperCase()) {
      'B3' => ProblemTierCode.b3,
      'B2' => ProblemTierCode.b2,
      'B1' => ProblemTierCode.b1,
      'S3' => ProblemTierCode.s3,
      'S2' => ProblemTierCode.s2,
      'S1' => ProblemTierCode.s1,
      'G3' => ProblemTierCode.g3,
      'G2' => ProblemTierCode.g2,
      'G1' => ProblemTierCode.g1,
      'P3' => ProblemTierCode.p3,
      'P2' => ProblemTierCode.p2,
      'P1' => ProblemTierCode.p1,
      'D3' => ProblemTierCode.d3,
      'D2' => ProblemTierCode.d2,
      'D1' => ProblemTierCode.d1,
      'M' => ProblemTierCode.master,
      _ => ProblemTierCode.b3, // 기본값
    };
  }

  /// 모든 티어 코드 리스트
  static const List<ProblemTierCode> all = ProblemTierCode.values;
}