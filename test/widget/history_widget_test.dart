import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/src/widgets/history_widget.dart';

void main() {
  group('History Widget Tests', () {
    testWidgets('HistoryWidget이 렌더링된다', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryWidget(tierName: 'Bronze'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 크래시 없이 로딩 완료
      expect(find.byType(HistoryWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('다양한 티어에서 HistoryWidget이 렌더링된다', (WidgetTester tester) async {
      final tiers = ['Bronze', 'Silver', 'Gold'];
      
      for (final tier in tiers) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryWidget(tierName: tier),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 크래시 없이 렌더링
        expect(find.byType(HistoryWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
} 