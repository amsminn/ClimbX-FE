import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_data.freezed.dart';
part 'history_data.g.dart';

// 하루 경험치 데이터 1개 -> 점 1개
@freezed
abstract class HistoryDataPoint with _$HistoryDataPoint {
  const factory HistoryDataPoint({
    required DateTime date,
    @Default(0.0) double experience,
  }) = _HistoryDataPoint;

  /// 표준 JSON 역직렬화 (freezed/json_serializable 생성 코드 사용)
  factory HistoryDataPoint.fromJson(Map<String, dynamic> json) =>
      _$HistoryDataPointFromJson(json);

  /// API 응답에서 value 키를 experience로 정규화하는 헬퍼
  factory HistoryDataPoint.withValueAsExperience(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      'date': json['date'],
      'experience': (json['value'] is num)
          ? (json['value'] as num).toDouble()
          : 0.0,
    };
    return _$HistoryDataPointFromJson(normalized);
  }
}

// 히스토리 정보
class HistoryData {
  final List<HistoryDataPoint> dataPoints;

  // 밋밋해서 최종 증가량, 하루 평균, 하루 최대량 같은거 넣어봄 (제거 가능)
  final double totalIncrease;
  final double averageDaily;
  final double maxDaily;

  HistoryData({
    required this.dataPoints,
    required this.totalIncrease,
    required this.averageDaily,
    required this.maxDaily,
  });

  /// 서버 응답 데이터에서 생성 (통계는 자동 계산)
  factory HistoryData.fromJson(List<dynamic> jsonList) {
    final dataPoints = jsonList
        .map((json) => HistoryDataPoint.withValueAsExperience(json as Map<String, dynamic>))
        .toList();

    // 통계 자동 계산
    if (dataPoints.isEmpty) {
      return HistoryData(
        dataPoints: dataPoints,
        totalIncrease: 0.0,
        averageDaily: 0.0,
        maxDaily: 0.0,
      );
    }

    final firstValue = dataPoints.first.experience;
    final lastValue = dataPoints.last.experience;
    final totalIncrease = lastValue - firstValue;

    double maxDaily = 0.0;
    for (int i = 1; i < dataPoints.length; i++) {
      final dailyChange = (dataPoints[i].experience - dataPoints[i - 1].experience).abs();
      if (dailyChange > maxDaily) {
        maxDaily = dailyChange;
      }
    }

    final averageDaily = dataPoints.length > 1 
        ? totalIncrease / (dataPoints.length - 1)
        : 0.0;

    return HistoryData(
      dataPoints: dataPoints,
      totalIncrease: totalIncrease,
      averageDaily: averageDaily,
      maxDaily: maxDaily,
    );
  }

} 
