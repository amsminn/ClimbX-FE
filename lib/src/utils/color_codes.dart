/// 문제 색상(한글 라벨) <->서버 코드 매핑 유틸
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
}

