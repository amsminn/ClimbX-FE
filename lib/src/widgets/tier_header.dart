// 상단에 나오는 탭의 이름

import 'package:flutter/material.dart';

class TierHeader extends StatelessWidget {
  final String title;
  
  const TierHeader({
    super.key,
    this.title = 'USER RATING',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 15,
      top: 18,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8C9AAE),
          fontSize: 12,
          fontFamily: 'Noto Sans KR',
          fontWeight: FontWeight.w300,
          height: 0.83,
        ),
      ),
    );
  }
} 