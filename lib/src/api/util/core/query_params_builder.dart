/// URL 쿼리 파라미터를 타입 안전하게 구성하기 위한 빌더 클래스
///
/// null 값은 자동으로 필터링되고, 모든 값은 String으로 변환됩니다.
///
/// 사용 예시:
/// ```dart
/// queryParameters: QueryParamsBuilder()
///   .add('page', 0)           // int → "0"
///   .add('cursor', cursor)    // null이면 제외됨
///   .add('latitude', 37.5665) // double → "37.5665"
///   .build()  // Map<String, String> 반환
/// ```
class QueryParamsBuilder {
  final Map<String, String> _params = {};

  /// 값 추가 (null은 자동으로 무시됨)
  ///
  /// int, double, String을 자동으로 문자열로 변환
  /// null 값은 추가되지 않음
  ///
  /// 예: `add('page', 0)` → page=0
  /// 예: `add('cursor', null)` → 추가 안됨
  QueryParamsBuilder add(String key, dynamic value) {
    if (value != null) {
      _params[key] = value.toString();
    }
    return this;
  }

  /// 최종 Map<String, String> 반환
  ///
  /// ApiClient.get() 등의 queryParameters 인자로 전달 가능
  Map<String, String> build() {
    return Map.unmodifiable(_params);
  }
}
