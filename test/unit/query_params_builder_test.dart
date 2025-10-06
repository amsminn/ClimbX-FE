import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/src/api/util/core/query_params_builder.dart';

void main() {
  group('QueryParamsBuilder', () {
    test('add()는 다양한 타입을 String으로 변환한다', () {
      final result = QueryParamsBuilder()
          .add('name', 'John')
          .add('age', 25)
          .add('height', 175.5)
          .add('isActive', true)
          .add('page', 0)
          .build();

      expect(result['name'], 'John');
      expect(result['age'], '25');
      expect(result['height'], '175.5');
      expect(result['isActive'], 'true');
      expect(result['page'], '0');

      // 모든 값이 String 타입인지 확인
      for (final value in result.values) {
        expect(value, isA<String>());
      }
    });

    test('add()는 null 값을 자동으로 필터링한다', () {
      final result = QueryParamsBuilder()
          .add('page', 0)
          .add('cursor', null)
          .add('search', null)
          .build();

      expect(result.keys.length, 1);
      expect(result['page'], '0');
      expect(result.containsKey('cursor'), false);
      expect(result.containsKey('search'), false);
    });

    test('addIfNotEmpty()는 빈 문자열을 필터링한다', () {
      final result = QueryParamsBuilder()
          .addIfNotEmpty('search', 'climbing')
          .addIfNotEmpty('filter', '')
          .addIfNotEmpty('sort', null)
          .build();

      expect(result.keys.length, 1);
      expect(result['search'], 'climbing');
      expect(result.containsKey('filter'), false);
      expect(result.containsKey('sort'), false);
    });

    test('addIfNotEmpty()는 빈 리스트를 필터링한다', () {
      final result = QueryParamsBuilder()
          .addIfNotEmpty('tags', ['climbing', 'bouldering'])
          .addIfNotEmpty('emptyList', [])
          .build();

      expect(result.keys.length, 1);
      expect(result['tags'], '[climbing, bouldering]');
      expect(result.containsKey('emptyList'), false);
    });

    test('addIfNotEmpty()는 빈 Map을 필터링한다', () {
      final result = QueryParamsBuilder()
          .addIfNotEmpty('filters', {'level': 'intermediate'})
          .addIfNotEmpty('emptyMap', {})
          .build();

      expect(result.keys.length, 1);
      expect(result['filters'], '{level: intermediate}');
      expect(result.containsKey('emptyMap'), false);
    });

    test('메서드 체이닝이 정상 동작한다', () {
      final builder = QueryParamsBuilder()
          .add('page', 0)
          .add('size', 20)
          .addIfNotEmpty('search', 'climbing');

      expect(builder, isA<QueryParamsBuilder>());

      final result = builder.build();
      expect(result.keys.length, 3);
    });

    test('build()는 불변 Map을 반환한다', () {
      final result = QueryParamsBuilder()
          .add('page', 0)
          .build();

      expect(() => result['page'] = '1', throwsUnsupportedError);
      expect(() => result['size'] = '20', throwsUnsupportedError);
    });

    test('build()는 Map<String, String> 타입을 반환한다', () {
      final result = QueryParamsBuilder()
          .add('page', 0)
          .build();

      expect(result, isA<Map<String, String>>());
    });

    test('빈 빌더는 빈 Map을 반환한다', () {
      final result = QueryParamsBuilder().build();

      expect(result, isEmpty);
      expect(result, isA<Map<String, String>>());
    });

    test('실제 사용 예시: API 쿼리 파라미터 구성', () {
      const int? cursor = null;
      const String searchText = '';

      final result = QueryParamsBuilder()
          .add('latitude', 37.5665)
          .add('longitude', 126.9780)
          .add('page', 0)
          .add('cursor', cursor)
          .addIfNotEmpty('search', searchText)
          .build();

      expect(result['latitude'], '37.5665');
      expect(result['longitude'], '126.978');
      expect(result['page'], '0');
      expect(result.containsKey('cursor'), false);
      expect(result.containsKey('search'), false);
    });

    test('음수와 특수 문자도 String으로 변환한다', () {
      final result = QueryParamsBuilder()
          .add('offset', -10)
          .add('temperature', -15.5)
          .add('special', '@#\$%')
          .build();

      expect(result['offset'], '-10');
      expect(result['temperature'], '-15.5');
      expect(result['special'], '@#\$%');
    });

    test('복잡한 객체도 toString()으로 변환한다', () {
      final customObject = DateTime(2025, 1, 1);

      final result = QueryParamsBuilder()
          .add('timestamp', customObject)
          .build();

      expect(result['timestamp'], customObject.toString());
      expect(result['timestamp'], isA<String>());
    });
  });
}
