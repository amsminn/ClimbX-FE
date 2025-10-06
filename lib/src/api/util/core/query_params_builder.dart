import 'base_map_builder.dart';

/// URL 쿼리 파라미터를 타입 안전하게 구성하기 위한 빌더 클래스
///
/// null 값은 자동으로 필터링되고, 모든 값은 String으로 변환됩니다.
///
/// 사용 예시:
/// ```dart
/// queryParameters: QueryParamsBuilder()
///   .add('page', 0)           // int → "0"
///   .add('cursor', cursor)    // null이면 제외됨
///   .addIfNotEmpty('search', searchText)  // 빈 문자열도 제외됨
///   .build()  // Map<String, String> 반환
/// ```
class QueryParamsBuilder extends BaseMapBuilder<QueryParamsBuilder, String> {
  /// 값을 String으로 변환
  @override
  String processValue(dynamic value) => value.toString();
}
