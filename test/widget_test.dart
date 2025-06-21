import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/main.dart';
import 'package:climbx_fe/src/models/history_data.dart';
import 'package:climbx_fe/src/widgets/history_widget.dart';
import 'package:climbx_fe/src/widgets/history_chart.dart';
import 'package:climbx_fe/src/widgets/history_period_selector.dart';
import 'package:climbx_fe/src/widgets/history_stats_summary.dart';
import 'package:climbx_fe/src/utils/tier_colors.dart';

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

  group('History Data Model Tests', () {
    test('HistoryDataPoint 생성 테스트', () {
      final date = DateTime.now();
      final point = HistoryDataPoint(date: date, experience: 1500.0);

      expect(point.date, equals(date));
      expect(point.experience, equals(1500.0));
    });

    test('HistoryData Mock 데이터 생성 테스트', () {
      final historyData = HistoryData.generateMockData();

      // 데이터 포인트가 30개 있는지 확인
      expect(historyData.dataPoints.length, equals(30));

      // 각 데이터 포인트가 유효한지 확인
      for (final point in historyData.dataPoints) {
        expect(point.experience, isPositive);
        expect(point.date, isNotNull);
      }

      // 계산된 통계값들이 유효한지 확인
      expect(historyData.totalIncrease, isPositive);
      expect(historyData.averageDaily, isPositive);
      expect(historyData.maxDaily, isPositive);
    });

    test('HistoryData 데이터가 시간순으로 정렬되어 있는지 확인', () {
      final historyData = HistoryData.generateMockData();

      for (int i = 0; i < historyData.dataPoints.length - 1; i++) {
        final currentDate = historyData.dataPoints[i].date;
        final nextDate = historyData.dataPoints[i + 1].date;
        expect(currentDate.isBefore(nextDate), isTrue);
      }
    });
  });

  group('History Widget Tests', () {
    testWidgets('HistoryWidget이 올바르게 렌더링된다', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HistoryWidget(tierName: 'Bronze')),
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
          home: Scaffold(body: HistoryWidget(tierName: 'Silver')),
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
            home: Scaffold(body: HistoryWidget(tierName: tier)),
          ),
        );

        await tester.pumpAndSettle();

        // 각 티어에서 위젯이 정상적으로 렌더링되는지 확인
        expect(find.byType(HistoryWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
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
  });

  group('History Stats Summary Tests', () {
    testWidgets('HistoryStatsSummary가 통계 정보를 표시한다', (
      WidgetTester tester,
    ) async {
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

      // 통계 정보가 표시되는지 확인 (구체적인 텍스트는 구현에 따라 달라질 수 있음)
      expect(find.byType(HistoryStatsSummary), findsOneWidget);

      // 크래시 없이 로딩 완료
      expect(tester.takeException(), isNull);
    });
  });

  group('Integration Tests - History Page', () {
    testWidgets('히스토리 페이지 전체 통합 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HistoryWidget(tierName: 'Platinum')),
        ),
      );

      await tester.pumpAndSettle();

      // 모든 주요 컴포넌트가 함께 정상적으로 작동하는지 확인
      expect(find.byType(HistoryPeriodSelector), findsOneWidget);
      expect(find.byType(HistoryChart), findsOneWidget);
      expect(find.byType(HistoryStatsSummary), findsOneWidget);

      // 스크롤 가능한지 확인
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // 크래시 없이 전체 페이지가 로딩되는지 확인
      expect(tester.takeException(), isNull);
    });
  });
}
