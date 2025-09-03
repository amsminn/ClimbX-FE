import 'package:flutter/material.dart';

/// 문제 색상(한글 라벨) <-> 서버 코드 매핑 유틸
enum ProblemColorCode { white, yellow, orange, green, blue, red, purple, gray, brown, black }

class ColorCodes {
  /// 한국어 라벨(흰색 포함 10색) - UI에서 사용
  static const List<String> koreanColorLabels = <String>[
    '흰색', '노랑', '주황', '초록', '파랑',
    '빨강', '보라', '회색', '갈색', '검정',
  ];

  /// 난이도 필터 옵션 (현재는 홀드색과 동일 세트 사용)
  static List<String> get localLevelOptions => koreanColorLabels;

  /// 홀드색 필터 옵션
  static List<String> get holdColorOptions => koreanColorLabels;
  static ProblemColorCode? fromKoreanLabel(String? label) {
    switch (label) {
      case '흰색':
        return ProblemColorCode.white;
      case '노랑':
        return ProblemColorCode.yellow;
      case '주황':
        return ProblemColorCode.orange;
      case '초록':
        return ProblemColorCode.green;
      case '파랑':
        return ProblemColorCode.blue;
      case '빨강':
        return ProblemColorCode.red;
      case '보라':
        return ProblemColorCode.purple;
      case '회색':
        return ProblemColorCode.gray;
      case '갈색':
        return ProblemColorCode.brown;
      case '검정':
        return ProblemColorCode.black;
      default:
        return null;
    }
  }

  static ProblemColorCode? fromServerCode(String? code) {
    switch ((code ?? '').toUpperCase()) {
      case 'WHITE':
        return ProblemColorCode.white;
      case 'YELLOW':
        return ProblemColorCode.yellow;
      case 'ORANGE':
        return ProblemColorCode.orange;
      case 'GREEN':
        return ProblemColorCode.green;
      case 'BLUE':
        return ProblemColorCode.blue;
      case 'RED':
        return ProblemColorCode.red;
      case 'PURPLE':
        return ProblemColorCode.purple;
      case 'GRAY':
        return ProblemColorCode.gray;
      case 'BROWN':
        return ProblemColorCode.brown;
      case 'BLACK':
        return ProblemColorCode.black;
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
      case ProblemColorCode.white:
        return 'WHITE';
      case ProblemColorCode.yellow:
        return 'YELLOW';
      case ProblemColorCode.orange:
        return 'ORANGE';
      case ProblemColorCode.green:
        return 'GREEN';
      case ProblemColorCode.blue:
        return 'BLUE';
      case ProblemColorCode.red:
        return 'RED';
      case ProblemColorCode.purple:
        return 'PURPLE';
      case ProblemColorCode.gray:
        return 'GRAY';
      case ProblemColorCode.brown:
        return 'BROWN';
      case ProblemColorCode.black:
        return 'BLACK';
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
      case ProblemColorCode.white:
        return '흰색';
      case ProblemColorCode.yellow:
        return '노랑';
      case ProblemColorCode.orange:
        return '주황';
      case ProblemColorCode.green:
        return '초록';
      case ProblemColorCode.blue:
        return '파랑';
      case ProblemColorCode.red:
        return '빨강';
      case ProblemColorCode.purple:
        return '보라';
      case ProblemColorCode.gray:
        return '회색';
      case ProblemColorCode.brown:
        return '갈색';
      case ProblemColorCode.black:
        return '검정';
    }
  }

  /// enum -> 표시용 색상값 (배지 컬러)
  static Color toDisplayColor(ProblemColorCode code) {
    switch (code) {
      case ProblemColorCode.white:
        return const Color(0xFFFFFFFF);
      case ProblemColorCode.yellow:
        return const Color(0xFFF59E0B);
      case ProblemColorCode.orange:
        return const Color(0xFFF97316);
      case ProblemColorCode.green:
        return const Color(0xFF10B981);
      case ProblemColorCode.blue:
        return const Color(0xFF3B82F6);
      case ProblemColorCode.red:
        return const Color(0xFFEF4444);
      case ProblemColorCode.purple:
        return const Color(0xFF8B5CF6);
      case ProblemColorCode.gray:
        return const Color(0xFF6B7280);
      case ProblemColorCode.brown:
        return const Color(0xFF92400E);
      case ProblemColorCode.black:
        return const Color(0xFF000000);
    }
  }

  /// 임의 문자열(한글/영문 코드) -> 라벨/색상 묶음 반환
  static (String label, Color color)? labelAndColorFromAny(String? value) {
    final c = fromAny(value);
    if (c == null) return null;
    return (toKoreanLabel(c), toDisplayColor(c));
  }

  /// 임의 문자열(한글/영문 코드) -> 서버 전송용 영문 코드로 변환
  /// 매핑에 실패하면 null 반환
  static String? anyToServerCode(String? value) {
    final c = fromAny(value);
    return c != null ? toServerCode(c) : null;
  }

  /// 임의 문자열(한글/영문 코드) -> 표시용 Color 반환
  /// 매핑 실패 시 기본 블루 계열 반환
  static Color toDisplayColorFromAny(String? value) {
    final c = fromAny(value);
    return c != null ? toDisplayColor(c) : const Color(0xFF3B82F6);
  }

  /// 흰색/회색 등 배경색과 대비를 위해 보더가 필요한지 판단
  static bool needsBorderForLabel(String? value) {
    final c = fromAny(value);
    return c == ProblemColorCode.white || c == ProblemColorCode.gray;
  }
}

