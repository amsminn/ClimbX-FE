import 'package:flutter/material.dart';

class TierStats extends StatelessWidget {
  final String label;
  final String value;

  const TierStats({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 15,
      top: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontFamily: 'Noto Sans KR',
              fontWeight: FontWeight.w400,
              height: 1.67,
            ),
          ),
          const SizedBox(width: 195), // 간격 조정
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontFamily: 'Noto Sans KR',
              fontWeight: FontWeight.w400,
              height: 1.67,
            ),
          ),
        ],
      ),
    );
  }
}
