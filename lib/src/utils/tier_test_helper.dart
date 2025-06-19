import 'package:flutter/material.dart';
import 'tier_colors.dart';

class TierTestHelper {
  static List<String> getAllTiers() {
    return [
      'Bronze I',
      'Silver I',
      'Gold I',
      'Platinum I',
      'Diamond I',
      'Master',
    ];
  }

  static void showTierSelector(
    BuildContext context,
    Function(String) onTierSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '티어 선택',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...getAllTiers().map((tier) {
                final TierType tierType = TierColors.getTierFromString(tier);
                final TierColorScheme colorScheme = TierColors.getColorScheme(
                  tierType,
                );

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: colorScheme.gradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      TierColors.getTierIcon(tierType),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(tier),
                  onTap: () {
                    Navigator.pop(context);
                    onTierSelected(tier);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
