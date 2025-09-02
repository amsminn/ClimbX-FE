import 'package:flutter_test/flutter_test.dart';
import 'package:climbx_fe/src/models/history_data.dart';

void main() {
  group('HistoryData 최소 파싱 테스트', () {
    test('HistoryDataPoint.fromJson이 date/value를 매핑한다', () {
      final json = {'date': '2025-01-01', 'value': 1500};
      final dp = HistoryDataPoint.fromJson(json);

      expect(dp.date, DateTime.parse('2025-01-01'));
      expect(dp.value, 1500.0);
    });

    test('HistoryData.fromJson이 리스트를 파싱한다(빈 리스트 포함)', () {
      final data = HistoryData.fromJson([
        {'date': '2025-01-01', 'value': 1000},
        {'date': '2025-01-02', 'value': 1050},
      ]);
      expect(data.dataPoints.length, 2);

      final empty = HistoryData.fromJson([]);
      expect(empty.dataPoints, isEmpty);
    });
  });
}
