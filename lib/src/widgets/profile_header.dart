import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(color: Color(0xFFF7F7F7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 프로필 섹션
          Row(
            children: [
              // 프로필 이미지 - 화면 크기에 따라 조정
              Container(
                width: screenWidth * 0.15, // 화면 너비의 15%
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00B4FC), width: 2),
                ),
                child: CircleAvatar(
                  radius: screenWidth * 0.075 - 2,
                  backgroundImage: const AssetImage('assets/images/avatar.png'),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '김채완',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '클라이밍해다오',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Color(0xFF64748B),
                  size: 24,
                ),
                onPressed: () {
                  // 설정 페이지로 이동
                },
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          const Row(
            children: [
              Text(
                'Diamond I  2714',
                style: TextStyle(
                  color: Color(0xFF00B4FC),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Spacer(),
              Text(
                'Master까지 86점',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.02),

          // 진행바
          Row(
            children: [
              Expanded(
                child: Container(
                  height: screenWidth * 0.05, // 화면 너비의 5%
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 56 / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xA5C89AFF), Color(0xFF901DE2)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          // 지역 정보
          Text(
            '서울 은평구',
            style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
          ),

          SizedBox(height: screenWidth * 0.04),

          // 통계 정보
          Row(
            children: [
              // 1. 문제 해결
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '1520',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '문제 해결',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 간격
              SizedBox(width: screenWidth * 0.04),

              // 2. 문제 기여
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '274',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '문제 기여',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 간격
              SizedBox(width: screenWidth * 0.04),

              // 3. 라이벌
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '331',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '명의 라이벌',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
