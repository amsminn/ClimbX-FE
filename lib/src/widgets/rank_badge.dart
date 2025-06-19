import 'package:flutter/material.dart';

class RankBadge extends StatelessWidget {
  final String rank;
  final String percentage;

  const RankBadge({super.key, required this.rank, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 274,
      top: 19,
      child: Container(
        width: 84,
        height: 39.09,
        decoration: ShapeDecoration(
          color: const Color(0xFFD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rank,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 11,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              percentage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 10,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
