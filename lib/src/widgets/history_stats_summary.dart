import 'package:flutter/material.dart';
import '../utils/color_schemes.dart';
import '../models/history_data.dart';
import '../utils/tier_colors.dart';

class HistoryStatsSummary extends StatelessWidget {
  final HistoryData historyData;
  final TierColorScheme colorScheme;

  const HistoryStatsSummary({
    super.key,
    required this.historyData,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
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
            '통계 요약',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColorSchemes.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // 데이터가 없을 때도 통계 표시 (0값으로)
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '총 증가량',
                  '+${historyData.totalIncrease.toInt()}',
                  'EXP',
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '일평균',
                  '+${historyData.averageDaily.toInt()}',
                  'EXP',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '최고 일일',
                  '+${historyData.maxDaily.toInt()}',
                  'EXP',
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: colorScheme.gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColorSchemes.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColorSchemes.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 11,
                color: AppColorSchemes.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 