import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/src/models/history_data.dart';
import 'package:climbx_fe/src/widgets/history_widget.dart';
import 'package:climbx_fe/src/widgets/history_chart.dart';
import 'package:climbx_fe/src/widgets/history_period_selector.dart';
import 'package:climbx_fe/src/widgets/history_stats_summary.dart';
import 'package:climbx_fe/src/utils/tier_colors.dart';

void main() {
  group('History Widget Tests', () {
    testWidgets('HistoryWidget이 올바르게 렌더링된다', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryWidget(tierName: 'Bronze'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 기본 위젯들이 존재하는지 확인
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(HistoryPeriodSelector), findsOneWidget);
      expect(find.byType(HistoryChart), findsOneWidget);
      expect(find.byType(HistoryStatsSummary), findsOneWidget);

      // 크래시 없이 로딩 완료
      expect(tester.takeException(), isNull);
    });

    testWidgets('기간 선택기가 올바르게 작동한다', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryWidget(tierName: 'Silver'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 기간 선택기 존재 확인
      expect(find.byType(HistoryPeriodSelector), findsOneWidget);

      // 기본 선택된 기간이 '1개월'인지 확인
      expect(find.text('1개월'), findsWidgets);
    });

    testWidgets('다양한 티어에서 HistoryWidget이 작동한다', (WidgetTester tester) async {
      final tiers = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
      
      for (final tier in tiers) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryWidget(tierName: tier),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 각 티어에서 위젯이 정상적으로 렌더링되는지 확인
        expect(find.byType(HistoryWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('스크롤이 정상적으로 작동한다', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryWidget(tierName: 'Gold'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 스크롤 위젯 확인
      final scrollWidget = find.byType(SingleChildScrollView);
      expect(scrollWidget, findsOneWidget);

      // 스크롤 테스트 (아래로 스크롤)
      await tester.drag(scrollWidget, const Offset(0, -300));
      await tester.pumpAndSettle();

      // 스크롤 후에도 크래시 없이 정상 작동
      expect(tester.takeException(), isNull);
    });
  });

  group('History Chart Tests', () {
    testWidgets('HistoryChart가 데이터와 함께 렌더링된다', (WidgetTester tester) async {
      final historyData = HistoryData.generateMockData();
      final colorScheme = TierColors.getColorScheme(TierType.bronze);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryChart(
              historyData: historyData,
              colorScheme: colorScheme,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 차트 컨테이너와 제목이 존재하는지 확인
      expect(find.text('경험치 변화'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      
      // 크래시 없이 로딩 완료
      expect(tester.takeException(), isNull);
    });

    testWidgets('빈 데이터로도 차트가 안전하게 렌더링된다', (WidgetTester tester) async {
      final emptyHistoryData = HistoryData(
        dataPoints: [],
        totalIncrease: 0.0,
        averageDaily: 0.0,
        maxDaily: 0.0,
      );
      final colorScheme = TierColors.getColorScheme(TierType.silver);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryChart(
              historyData: emptyHistoryData,
              colorScheme: colorScheme,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 빈 데이터여도 크래시 없이 렌더링
      expect(find.text('경험치 변화'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('History Stats Summary Tests', () {
    testWidgets('HistoryStatsSummary가 통계 정보를 표시한다', (WidgetTester tester) async {
      final historyData = HistoryData.generateMockData();
      final colorScheme = TierColors.getColorScheme(TierType.gold);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryStatsSummary(
              historyData: historyData,
              colorScheme: colorScheme,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 통계 정보가 표시되는지 확인
      expect(find.byType(HistoryStatsSummary), findsOneWidget);
      
      // 크래시 없이 로딩 완료
      expect(tester.takeException(), isNull);
    });

    testWidgets('다양한 티어 색상으로 통계가 렌더링된다', (WidgetTester tester) async {
      final historyData = HistoryData.generateMockData();
      final tierTypes = [TierType.bronze, TierType.silver, TierType.gold, TierType.platinum, TierType.diamond];

      for (final tierType in tierTypes) {
        final colorScheme = TierColors.getColorScheme(tierType);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryStatsSummary(
                historyData: historyData,
                colorScheme: colorScheme,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(HistoryStatsSummary), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
} 