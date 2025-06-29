import 'package:flutter/material.dart';
import '../utils/tier_colors.dart';
import '../utils/bottom_nav_tab.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final BottomNavTab currentTab;
  final Function(BottomNavTab) onTap;
  final TierColorScheme colorScheme;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentTab,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentTab.index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: BottomNavTab.allItems,
        onTap: (index) => onTap(BottomNavTab.fromIndex(index)),
      ),
    );
  }
} 