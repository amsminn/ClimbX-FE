import 'package:flutter/material.dart';

/// 문제 색상(한글 라벨) <-> 서버 코드 매핑 유틸
enum ProblemColorCode { red, blue, green, yellow, purple }

class ColorCodes {
  static ProblemColorCode? fromKoreanLabel(String? label) {
    switch (label) {
      case '빨강':
        return ProblemColorCode.red;
      case '파랑':
        return ProblemColorCode.blue;
      case '초록':
        return ProblemColorCode.green;
      case '노랑':
        return ProblemColorCode.yellow;
      case '보라':
        return ProblemColorCode.purple;
      default:
        return null;
    }
  }

  static ProblemColorCode? fromServerCode(String? code) {
    switch ((code ?? '').toUpperCase()) {
      case 'RED':
        return ProblemColorCode.red;
      case 'BLUE':
        return ProblemColorCode.blue;
      case 'GREEN':
        return ProblemColorCode.green;
      case 'YELLOW':
        return ProblemColorCode.yellow;
      case 'PURPLE':
        return ProblemColorCode.purple;
      default:
        return null;
    }
  }

  /// 한글/서버코드 어떤 값이 와도 enum으로 정규화
  static ProblemColorCode? fromAny(String? value) {
    return fromKoreanLabel(value) ?? fromServerCode(value);
  }

  static String toServerCode(ProblemColorCode code) {
    switch (code) {
      case ProblemColorCode.red:
        return 'RED';
      case ProblemColorCode.blue:
        return 'BLUE';
      case ProblemColorCode.green:
        return 'GREEN';
      case ProblemColorCode.yellow:
        return 'YELLOW';
      case ProblemColorCode.purple:
        return 'PURPLE';
    }
  }

  /// 한글 라벨을 서버 코드 문자열로 변환 (없으면 임시로 'UNKNOWN' 반환)
  static String koreanLabelToServerCode(String? label) {
    final c = fromKoreanLabel(label);
    return c != null ? toServerCode(c) : 'UNKNOWN';
  }

  /// enum -> 한글 라벨
  static String toKoreanLabel(ProblemColorCode code) {
    switch (code) {
      case ProblemColorCode.red:
        return '빨강';
      case ProblemColorCode.blue:
        return '파랑';
      case ProblemColorCode.green:
        return '초록';
      case ProblemColorCode.yellow:
        return '노랑';
      case ProblemColorCode.purple:
        return '보라';
    }
  }

  /// enum -> 표시용 색상값 (배지 컬러)
  static Color toDisplayColor(ProblemColorCode code) {
    switch (code) {
      case ProblemColorCode.red:
        return const Color(0xFFEF4444);
      case ProblemColorCode.blue:
        return const Color(0xFF3B82F6);
      case ProblemColorCode.green:
        return const Color(0xFF10B981);
      case ProblemColorCode.yellow:
        return const Color(0xFFF59E0B);
      case ProblemColorCode.purple:
        return const Color(0xFF8B5CF6);
    }
  }

  /// 임의 문자열(한글/영문 코드) -> 라벨/색상 묶음 반환
  static (String label, Color color)? labelAndColorFromAny(String? value) {
    final c = fromAny(value);
    if (c == null) return null;
    return (toKoreanLabel(c), toDisplayColor(c));
  }
}

