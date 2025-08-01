import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 공통 색상 스키마
/// 
/// 모든 하드코딩된 색상 값을 이 클래스의 상수로 대체하여
/// 색상 관리의 일관성과 유지보수성을 향상시킵니다.
class AppColorSchemes {
  // Private constructor to prevent instantiation
  AppColorSchemes._();

  // ===== 배경색 (Background Colors) =====
  
  /// 주요 배경색 - 흰색
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  
  /// 보조 배경색 - 연한 회색
  static const Color backgroundSecondary = Color(0xFFF8FAFC);
  
  /// 3차 배경색 - 더 연한 회색
  static const Color backgroundTertiary = Color(0xFFF1F5F9);

  // ===== 텍스트색 (Text Colors) =====
  
  /// 주요 텍스트색 - 어두운 회색
  static const Color textPrimary = Color(0xFF1E293B);
  
  /// 보조 텍스트색 - 중간 회색
  static const Color textSecondary = Color(0xFF64748B);
  
  /// 3차 텍스트색 - 연한 회색 (비활성 상태)
  static const Color textTertiary = Color(0xFF94A3B8);
  
  /// 특수 텍스트색 - 매우 어두운 회색
  static const Color textSpecial = Color(0xFF2B2D30);

  // ===== 테두리색 (Border Colors) =====
  
  /// 주요 테두리색 - 연한 회색
  static const Color borderPrimary = Color(0xFFE2E8F0);

  // ===== 그림자색 (Shadow Colors) =====
  
  /// 연한 그림자색
  static const Color shadowLight = Color(0x08000000);
  
  /// 중간 그림자색
  static const Color shadowMedium = Color(0x12000000);

  // ===== 특수 색상 (Accent Colors) =====
  
  /// 파란색 액센트 - 버튼, 링크 등
  static const Color accentBlue = Color(0xFF3B82F6);
  
  /// 주황색 액센트 - 지도 마커 등
  static const Color accentOrange = Color(0xFFFF6B35);
  
  /// 초록색 액센트 - 성공 상태 등
  static const Color accentGreen = Color(0xFF059669);
  
  /// 빨간색 액센트 - 오류, 경고 등
  static const Color accentRed = Color(0xFFEF4444);

  // ===== 그라디언트 색상 (Gradient Colors) =====
  
  /// 기본 그라디언트 시작색
  static const Color gradientStart = Color(0xFFFFFFFF);
  
  /// 기본 그라디언트 끝색
  static const Color gradientEnd = Color(0xFFF8FAFC);

  // ===== 유틸리티 메서드 =====
  
  /// 기본 그라디언트 반환
  static LinearGradient get defaultGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
  
  /// 기본 그림자 스타일 반환
  static List<BoxShadow> get defaultShadow => const [
    BoxShadow(
      color: shadowLight,
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: shadowMedium,
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
  
  /// 연한 그림자 스타일 반환
  static List<BoxShadow> get lightShadow => const [
    BoxShadow(
      color: shadowLight,
      blurRadius: 12,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
} 