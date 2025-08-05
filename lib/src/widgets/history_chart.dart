import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/color_schemes.dart';
import '../models/history_data.dart';
import '../utils/tier_colors.dart';
import 'history_widget.dart';
import 'dart:math';

class HistoryChart extends StatefulWidget {
  final HistoryData historyData;
  final TierColorScheme colorScheme;
  final HistoryPeriod period;

  const HistoryChart({
    super.key,
    required this.historyData,
    required this.colorScheme,
    required this.period,
  });

  @override
  State<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    // 첫 번째 로드 시에만 애니메이션 실행
    _controller.forward();
  }

  @override
  void didUpdateWidget(HistoryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 데이터가 변경될 때만 애니메이션 실행 (기간 변경 시에는 애니메이션 없음)
    if (oldWidget.historyData != widget.historyData) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 자동 최적화 함수 추가
  double getNiceInterval(double min, double max, int targetTicks) {
    final rawInterval = (max - min) / targetTicks;
    if (rawInterval == 0) return 1;
    final magnitude = pow(10, (log(rawInterval) / ln10).floor()).toDouble();
    final residual = rawInterval / magnitude;
    double niceInterval;
    if (residual > 5) {
      niceInterval = 10 * magnitude;
    } else if (residual > 2) {
      niceInterval = 5 * magnitude;
    } else if (residual > 1) {
      niceInterval = 2 * magnitude;
    } else {
      niceInterval = magnitude;
    }
    return niceInterval;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildChart();
      },
    );
  }

  Widget _buildChart() {
    // 데이터가 없을 때도 빈 그래프 표시
    final dataPoints = widget.historyData.dataPoints;
    final isEmpty = dataPoints.isEmpty;

    final minY = _getMinY();
    final maxY = _getMaxY();
    final yInterval = getNiceInterval(minY, maxY, 6); // 6개 눈금 기준
    final dataCount = widget.historyData.dataPoints.length;
    // labelIndexes 계산 (0, 중간들, 마지막)
    final labelIndexes = getLabelIndexes(dataCount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '경험치 변화',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColorSchemes.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppColorSchemes.backgroundTertiary,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) =>
                          _getBottomTitles(value, meta, labelIndexes),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: yInterval,
                      getTitlesWidget: _getLeftTitles,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (widget.historyData.dataPoints.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: isEmpty ? [] : [
                  LineChartBarData(
                    spots: _getAnimatedSpots(),
                    isCurved: _shouldUseCurve(),
                    gradient: widget.colorScheme.gradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        AppColorSchemes.textPrimary,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final dataPoint =
                            widget.historyData.dataPoints[barSpot.x.toInt()];
                        return LineTooltipItem(
                          '${dataPoint.date.month}/${dataPoint.date.day}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${dataPoint.experience.toInt()} EXP',
                              style: TextStyle(
                                color: widget.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 애니메이션된 점 데이터 가져오기
  List<FlSpot> _getAnimatedSpots() {
    // 기간이 변경된 경우 애니메이션 없이 모든 점 표시
    if (widget.period != HistoryPeriod.all) {
      return widget.historyData.dataPoints
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final dataPoint = entry.value;
            return FlSpot(index.toDouble(), dataPoint.experience);
          })
          .toList();
    }

    // 전체 기간일 때만 애니메이션 적용
    final maxVisibleIndex =
        (widget.historyData.dataPoints.length * _animation.value).floor();

    return widget.historyData.dataPoints
        .asMap()
        .entries
        .take(maxVisibleIndex + 1) // 애니메이션 진행도에 따라 점 개수 제한
        .map((entry) {
          final index = entry.key;
          final dataPoint = entry.value;
          return FlSpot(index.toDouble(), dataPoint.experience);
        })
        .toList();
  }

  double _getMinY() {
    if (widget.historyData.dataPoints.isEmpty) {
      return 0.0;
    }
    final minExp = widget.historyData.dataPoints
        .map((e) => e.experience)
        .reduce((a, b) => a < b ? a : b);
    return (minExp - 50).floorToDouble();
  }

  double _getMaxY() {
    if (widget.historyData.dataPoints.isEmpty) {
      return 100.0;
    }
    final maxExp = widget.historyData.dataPoints
        .map((e) => e.experience)
        .reduce((a, b) => a > b ? a : b);
    return (maxExp + 50).ceilToDouble();
  }

  // 하단 타이틀 가져오기
  Widget _getBottomTitles(
    double value,
    TitleMeta meta,
    List<int> labelIndexes,
  ) {
    final index = value.toInt();
    final dataCount = widget.historyData.dataPoints.length;
    if (index >= dataCount) return Container();
    if (!labelIndexes.contains(index)) return Container();
    final dataPoint = widget.historyData.dataPoints[index];
    return Text(
      '${dataPoint.date.month}/${dataPoint.date.day}',
      style: const TextStyle(
        color: AppColorSchemes.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    final minY = _getMinY();
    final maxY = _getMaxY();

    // 최상단과 최하단 값은 겹칠 수 있으므로 숨김
    if (value >= maxY || value <= minY) {
      return Container();
    }

    return Text(
      '${value.toInt()}',
      style: const TextStyle(
        color: AppColorSchemes.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<int> getLabelIndexes(int dataLength) {
    if (dataLength <= 1) return [0];
    if (dataLength == 2) return [0, 1];
    if (dataLength == 3) return [0, 1, 2];
    // 4개 이상일 때: 0, 중간1, 중간2, 마지막 (최대 4~5개)
    final last = dataLength - 1;
    final mid1 = (last / 3).round();
    final mid2 = (last * 2 / 3).round();
    final set = <int>{0, mid1, mid2, last};
    final sorted = set.toList()..sort();
    return sorted;
  }

  bool _shouldUseCurve() {
    // 1개월, 1주 선택 시에는 직선 그래프 사용
    return widget.period != HistoryPeriod.oneMonth && 
           widget.period != HistoryPeriod.oneWeek;
  }
}
