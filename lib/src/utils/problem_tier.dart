import 'tier_colors.dart';

/// 문제 전용 티어 매핑 유틸
/// 경계는 [inclusive, exclusive)
class ProblemTierHelper {
  static const List<({int start, int end, String code, String display, TierType type})> _bounds = [
    (start: 0, end: 2, code: 'B3', display: 'Bronze III', type: TierType.bronze),
    (start: 2, end: 4, code: 'B2', display: 'Bronze II', type: TierType.bronze),
    (start: 4, end: 6, code: 'B1', display: 'Bronze I', type: TierType.bronze),
    (start: 6, end: 8, code: 'S3', display: 'Silver III', type: TierType.silver),
    (start: 8, end: 10, code: 'S2', display: 'Silver II', type: TierType.silver),
    (start: 10, end: 12, code: 'S1', display: 'Silver I', type: TierType.silver),
    (start: 12, end: 14, code: 'G3', display: 'Gold III', type: TierType.gold),
    (start: 14, end: 16, code: 'G2', display: 'Gold II', type: TierType.gold),
    (start: 16, end: 18, code: 'G1', display: 'Gold I', type: TierType.gold),
    (start: 18, end: 20, code: 'P3', display: 'Platinum III', type: TierType.platinum),
    (start: 20, end: 22, code: 'P2', display: 'Platinum II', type: TierType.platinum),
    (start: 22, end: 24, code: 'P1', display: 'Platinum I', type: TierType.platinum),
    (start: 24, end: 26, code: 'D3', display: 'Diamond III', type: TierType.diamond),
    (start: 26, end: 28, code: 'D2', display: 'Diamond II', type: TierType.diamond),
    (start: 28, end: 30, code: 'D1', display: 'Diamond I', type: TierType.diamond),
    (start: 30, end: 31, code: 'M', display: 'Master', type: TierType.master),
  ];

  static ({String code, String display, TierType type}) getTier(int rating) {
    // 상위 티어부터 확인하여 상한 없는 티어(Master 등)도 정확히 매핑
    for (final b in _bounds.reversed) {
      if (rating >= b.start) {
        return (code: b.code, display: b.display, type: b.type);
      }
    }
    // 안전망
    final b = _bounds.first;
    return (code: b.code, display: b.display, type: b.type);
  }

  static String getDisplayName(int rating) => getTier(rating).display;
  static String getCode(int rating) => getTier(rating).code;
  static TierType getType(int rating) => getTier(rating).type;

  /// 코드(B3, S2, G1, P3, D2, M)를 보여줄 이름/타입으로 변환
  static ({String display, TierType type}) getDisplayAndTypeFromCode(String code) {
    if (code.isEmpty) return (display: '', type: TierType.bronze);
    final c = code.toUpperCase();

    final bound = _bounds.firstWhere(
      (b) => b.code.toUpperCase() == c,
      orElse: () => _bounds.first,
    );

    return (display: bound.display, type: bound.type);
  }
}

