import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/src/api/util/core/request_body_builder.dart';

void main() {
  group('RequestBodyBuilder', () {
    test('add()는 다양한 타입을 원본 타입으로 유지한다', () {
      final result = RequestBodyBuilder()
          .add('name', 'John')
          .add('age', 25)
          .add('height', 175.5)
          .add('isActive', true)
          .add('tags', ['climbing', 'bouldering'])
          .add('metadata', {'level': 'intermediate'})
          .build();

      expect(result['name'], isA<String>());
      expect(result['name'], 'John');
      expect(result['age'], isA<int>());
      expect(result['age'], 25);
      expect(result['height'], isA<double>());
      expect(result['height'], 175.5);
      expect(result['isActive'], isA<bool>());
      expect(result['isActive'], true);
      expect(result['tags'], isA<List>());
      expect(result['tags'], ['climbing', 'bouldering']);
      expect(result['metadata'], isA<Map>());
      expect(result['metadata'], {'level': 'intermediate'});
    });

    test('add()는 null 값을 자동으로 필터링한다', () {
      final result = RequestBodyBuilder()
          .add('name', 'John')
          .add('age', null)
          .add('email', null)
          .build();

      expect(result.keys.length, 1);
      expect(result.containsKey('name'), true);
      expect(result.containsKey('age'), false);
      expect(result.containsKey('email'), false);
    });

    test('addIfNotEmpty()는 빈 문자열을 필터링한다', () {
      final result = RequestBodyBuilder()
          .addIfNotEmpty('name', 'John')
          .addIfNotEmpty('email', '')
          .addIfNotEmpty('phone', null)
          .build();

      expect(result.keys.length, 1);
      expect(result['name'], 'John');
      expect(result.containsKey('email'), false);
      expect(result.containsKey('phone'), false);
    });

    test('addIfNotEmpty()는 빈 리스트를 필터링한다', () {
      final result = RequestBodyBuilder()
          .addIfNotEmpty('tags', ['climbing'])
          .addIfNotEmpty('emptyTags', [])
          .addIfNotEmpty('nullTags', null)
          .build();

      expect(result.keys.length, 1);
      expect(result['tags'], ['climbing']);
      expect(result.containsKey('emptyTags'), false);
      expect(result.containsKey('nullTags'), false);
    });

    test('addIfNotEmpty()는 빈 Map을 필터링한다', () {
      final result = RequestBodyBuilder()
          .addIfNotEmpty('metadata', {'level': 'intermediate'})
          .addIfNotEmpty('emptyMetadata', {})
          .addIfNotEmpty('nullMetadata', null)
          .build();

      expect(result.keys.length, 1);
      expect(result['metadata'], {'level': 'intermediate'});
      expect(result.containsKey('emptyMetadata'), false);
      expect(result.containsKey('nullMetadata'), false);
    });

    test('메서드 체이닝이 정상 동작한다', () {
      final builder = RequestBodyBuilder()
          .add('name', 'John')
          .add('age', 25)
          .addIfNotEmpty('email', 'john@example.com');

      expect(builder, isA<RequestBodyBuilder>());

      final result = builder.build();
      expect(result.keys.length, 3);
    });

    test('build()는 불변 Map을 반환한다', () {
      final result = RequestBodyBuilder()
          .add('name', 'John')
          .build();

      expect(() => result['name'] = 'Jane', throwsUnsupportedError);
      expect(() => result['age'] = 25, throwsUnsupportedError);
    });

    test('빈 빌더는 빈 Map을 반환한다', () {
      final result = RequestBodyBuilder().build();

      expect(result, isEmpty);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('실제 사용 예시: API 요청 body 구성', () {
      final String? optionalComment = null;
      final List<String> tags = ['V4', 'overhang'];

      final result = RequestBodyBuilder()
          .add('gymId', 123)
          .add('tier', 'intermediate')
          .addIfNotEmpty('tags', tags)
          .addIfNotEmpty('comment', optionalComment)
          .build();

      expect(result['gymId'], 123);
      expect(result['tier'], 'intermediate');
      expect(result['tags'], ['V4', 'overhang']);
      expect(result.containsKey('comment'), false);
    });
  });
}
