import 'package:flutter/material.dart';
import 'tier_header.dart';
import 'tier_info.dart';
import 'rank_badge.dart';
import 'tier_stats.dart';

class TierWidget extends StatelessWidget {
  const TierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 370,
          height: 363,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              // 배경 컨테이너
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 370,
                  height: 363,
                  decoration: ShapeDecoration(
                    color: const Color(0x38D9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              // 컴포넌트들
              const TierHeader(),
              const TierInfo(
                tierName: 'Diamond I',
                points: 2714,
              ),
              const RankBadge(
                rank: '#1',
                percentage: '상위 0.1%',
              ),
              const TierStats(
                label: '상위 50문제 난이도 합',
                value: '+2714',
              ),
              // TODO: 티어 이미지 컴포넌트 추가할 공간
              // const TierImage(), - 나중에 추가
            ],
          ),
        ),
      ],
    );
  }
}
