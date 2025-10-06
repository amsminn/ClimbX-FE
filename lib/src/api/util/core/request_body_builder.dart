import 'base_map_builder.dart';

/// HTTP 요청 body를 타입 안전하게 구성하기 위한 빌더 클래스
///
/// null 값은 자동으로 필터링되고, 모든 값은 원본 타입을 유지합니다.
///
/// 사용 예시:
/// ```dart
/// data: RequestBodyBuilder()
///   .add('tier', tier)           // String 유지
///   .addIfNotEmpty('tags', tags) // List가 비어있으면 제외
///   .addIfNotEmpty('comment', comment)  // null과 빈 문자열 제외
///   .build()  // Map<String, dynamic> 반환
/// ```
class RequestBodyBuilder extends BaseMapBuilder<RequestBodyBuilder, dynamic> {
  /// 값을 원본 타입 그대로 유지
  @override
  dynamic processValue(dynamic value) => value;
}
