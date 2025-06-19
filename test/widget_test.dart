import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/main.dart';

void main() {
  group('ClimbX Profile App Tests', () {
    testWidgets('앱이 정상적으로 로딩되고 기본 구조가 존재한다', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // 완전히 로딩될때까지 기다리기
      await tester.pumpAndSettle();

      // 전체 프로필 페이지
      expect(find.byType(Scaffold), findsOneWidget);

      // 상단 ClimbX와 알림 옵션 바
      expect(find.byType(AppBar), findsWidgets);

      // 탭 컨트롤러 (개요, 히스토리 ...)
      expect(find.byType(DefaultTabController), findsWidgets);

      // 크래시 없이 로딩 완료
      expect(tester.takeException(), isNull);
    });
  });
}
