/// Map 기반 빌더의 공통 로직을 제공하는 추상 베이스 클래스
///
/// 타입 파라미터:
/// - T: 빌더 자신의 타입 (메서드 체이닝용)
/// - V: Map의 값 타입 (String, dynamic 등)
///
/// 하위 클래스는 [_processValue]만 구현하면 됨
abstract class BaseMapBuilder<T, V> {
  final Map<String, V> _data = {};

  /// 값 변환 방식 정의 (하위 클래스에서 구현)
  ///
  /// QueryParamsBuilder: value.toString() → String
  /// RequestBodyBuilder: value → dynamic (그대로)
  V _processValue(dynamic value);

  /// 값 추가 (null은 자동으로 무시됨)
  ///
  /// null 값은 추가되지 않음
  /// 메서드 체이닝 가능
  T add(String key, dynamic value) {
    if (value != null) {
      _data[key] = _processValue(value);
    }
    return this as T;
  }

  /// 값 추가 (null과 empty 모두 무시됨)
  ///
  /// String, List, Map 등 isEmpty를 지원하는 타입에 사용
  /// null 또는 isEmpty가 true인 경우 추가되지 않음
  /// 메서드 체이닝 가능
  T addIfNotEmpty(String key, dynamic value) {
    if (value == null) return this as T;

    // String, List, Map 등 isEmpty를 가진 타입 체크
    if (value is String && value.isEmpty) return this as T;
    if (value is List && value.isEmpty) return this as T;
    if (value is Map && value.isEmpty) return this as T;

    _data[key] = _processValue(value);
    return this as T;
  }

  /// 최종 Map 반환 (불변)
  Map<String, V> build() {
    return Map.unmodifiable(_data);
  }
}
