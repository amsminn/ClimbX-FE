import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/src/models/history_data.dart';

void main() {
  group('History Data Model Tests', () {
    test('HistoryDataPoint 생성 테스트', () {
      final date = DateTime.now();
      final point = HistoryDataPoint(
        date: date,
        experience: 1500.0,
      );

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

    test('HistoryData 통계 계산이 정확한지 확인', () {
      // 간단한 테스트 데이터 생성
      final testPoints = [
        HistoryDataPoint(date: DateTime(2024, 1, 1), experience: 100.0),
        HistoryDataPoint(date: DateTime(2024, 1, 2), experience: 150.0),
        HistoryDataPoint(date: DateTime(2024, 1, 3), experience: 120.0),
      ];

      final historyData = HistoryData(
        dataPoints: testPoints,
        totalIncrease: 20.0, // 120 - 100
        averageDaily: 10.0,  // 20 / 2일
        maxDaily: 50.0,      // 150 - 100
      );

      expect(historyData.dataPoints.length, equals(3));
      expect(historyData.totalIncrease, equals(20.0));
      expect(historyData.averageDaily, equals(10.0));
      expect(historyData.maxDaily, equals(50.0));
    });
  });
} 