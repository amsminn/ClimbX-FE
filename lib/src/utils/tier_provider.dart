import 'package:flutter/material.dart';
import 'tier_colors.dart';

/// 티어 색상 정보를 전역으로 공유하는 InheritedWidget
class TierProvider extends InheritedWidget {
  final TierColorScheme colorScheme;

  const TierProvider({
    super.key,
    required this.colorScheme,
    required super.child,
  });

  /// 현재 컨텍스트에서 TierProvider를 찾아 colorScheme을 반환
  static TierColorScheme of(BuildContext context) {
    final TierProvider? result = context.dependOnInheritedWidgetOfExactType<TierProvider>();
    assert(result != null, 'No TierProvider found in context');
    return result!.colorScheme;
  }

  @override
  bool updateShouldNotify(TierProvider oldWidget) {
    return colorScheme != oldWidget.colorScheme;
  }
} 