import 'package:flutter/material.dart';
import '../utils/problem_tier.dart';
import '../utils/tier_colors.dart';
import '../utils/color_schemes.dart';

class TierPickerSheet extends StatelessWidget {
  final List<String> tiers;
  final String? initial;
  final ValueChanged<String> onSelected;

  const TierPickerSheet({super.key, required this.tiers, this.initial, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: AppColorSchemes.backgroundPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '난이도 티어 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColorSchemes.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tiers.map((code) => _TierPill(
                code: code,
                selected: code == initial,
                onTap: () {
                  onSelected(code);
                  Navigator.of(context).pop();
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _TierPill({required this.code, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mapped = ProblemTierHelper.getDisplayAndTypeFromCode(code);
    final scheme = TierColors.getColorScheme(mapped.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: scheme.gradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))],
          border: selected ? Border.all(color: AppColorSchemes.backgroundPrimary, width: 2) : null,
        ),
        child: Text(
          mapped.display,
          style: const TextStyle(
            color: AppColorSchemes.backgroundPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}


