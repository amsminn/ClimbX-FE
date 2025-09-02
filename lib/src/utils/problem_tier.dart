import 'tier_colors.dart';
import '../models/problem_tier_code.dart';

/// 문제 전용 티어 매핑 유틸
/// 경계는 [inclusive, exclusive)
class ProblemTierHelper {
  static const List<({int start, int end, ProblemTierCode tierCode})> _bounds = [
    (start: 0, end: 2, tierCode: ProblemTierCode.b3),
    (start: 2, end: 4, tierCode: ProblemTierCode.b2),
    (start: 4, end: 6, tierCode: ProblemTierCode.b1),
    (start: 6, end: 8, tierCode: ProblemTierCode.s3),
    (start: 8, end: 10, tierCode: ProblemTierCode.s2),
    (start: 10, end: 12, tierCode: ProblemTierCode.s1),
    (start: 12, end: 14, tierCode: ProblemTierCode.g3),
    (start: 14, end: 16, tierCode: ProblemTierCode.g2),
    (start: 16, end: 18, tierCode: ProblemTierCode.g1),
    (start: 18, end: 20, tierCode: ProblemTierCode.p3),
    (start: 20, end: 22, tierCode: ProblemTierCode.p2),
    (start: 22, end: 24, tierCode: ProblemTierCode.p1),
    (start: 24, end: 26, tierCode: ProblemTierCode.d3),
    (start: 26, end: 28, tierCode: ProblemTierCode.d2),
    (start: 28, end: 30, tierCode: ProblemTierCode.d1),
    (start: 30, end: 31, tierCode: ProblemTierCode.master),
  ];

  static ProblemTierCode getTierCode(int rating) {
    // 상위 티어부터 확인하여 상한 없는 티어(Master 등)도 정확히 매핑
    for (final b in _bounds.reversed) {
      if (rating >= b.start) {
        return b.tierCode;
      }
    }
    // 안전망
    return _bounds.first.tierCode;
  }

  static ({String code, String display, TierType type}) getTier(int rating) {
    final tierCode = getTierCode(rating);
    return (code: tierCode.code, display: tierCode.display, type: tierCode.tierType);
  }

  static String getDisplayName(int rating) => getTierCode(rating).display;
  static String getCode(int rating) => getTierCode(rating).code;
  static TierType getType(int rating) => getTierCode(rating).tierType;

  /// 코드(B3, S2, G1, P3, D2, M)를 보여줄 이름/타입으로 변환
  static ({String display, TierType type}) getDisplayAndTypeFromCode(String code) {
    if (code.isEmpty) return (display: '', type: TierType.bronze);
    
    final tierCode = ProblemTierCode.fromString(code);
    return (display: tierCode.display, type: tierCode.tierType);
  }

  /// ProblemTierCode enum으로부터 정보 가져오기 (enum 우선 사용)
  static ({String display, TierType type}) getDisplayAndTypeFromTierCode(ProblemTierCode tierCode) {
    return (display: tierCode.display, type: tierCode.tierType);
  }
}

