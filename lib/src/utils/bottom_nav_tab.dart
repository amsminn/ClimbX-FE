import 'package:flutter/material.dart';

// 이것도 나중에 메타 데이터로 받아올 수 있을듯
enum BottomNavTab {
  profile('홈', Icons.person_outline, Icons.home),
  leaderboard('리더보드', Icons.leaderboard_outlined, Icons.leaderboard),
  search('검색', Icons.search_outlined, Icons.search),
  map('지도', Icons.map_outlined, Icons.map);

  const BottomNavTab(this.label, this.icon, this.activeIcon);
  
  final String label;
  final IconData icon;
  final IconData activeIcon;

  // 인덱스로 탭 찾기
  static BottomNavTab fromIndex(int index) {
    return BottomNavTab.values.firstWhere((tab) => tab.index == index);
  }

  // BottomNavigationBarItem 생성
  BottomNavigationBarItem get navigationBarItem {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }

  // 모든 BottomNavigationBarItem 리스트
  static List<BottomNavigationBarItem> get allItems {
    return BottomNavTab.values.map((tab) => tab.navigationBarItem).toList();
  }
} 