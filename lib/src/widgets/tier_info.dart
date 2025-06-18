import 'package:flutter/material.dart';

class TierInfo extends StatelessWidget {
  final String tierName;
  final int points;
  final Color textColor;
  
  const TierInfo({
    super.key,
    required this.tierName,
    required this.points,
    this.textColor = const Color(0xFF00B4FC),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 15,
      top: 38,
      child: SizedBox(
        width: 150,
        child: Text(
          '$tierName  $points',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontFamily: 'Noto Sans KR',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ),
    );
  }
} 