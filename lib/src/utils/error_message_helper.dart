import 'package:dio/dio.dart';

/// 에러를 사용자 친화적인 메시지로 변환하는 헬퍼 클래스
class ErrorMessageHelper {
  ErrorMessageHelper._();
  // 상태 코드별 메시지 매핑
  static const Map<int, String> _statusMessages = {
    409: '이미 제출한 영상이에요',
    400: '다시 시도해주세요',
    401: '로그인 후 다시 시도해주세요',
    403: '권한이 없어요',
    404: '찾을 수 없어요',
    429: '잠시 후 다시 시도해주세요',
    500: '잠시 후 다시 시도해주세요',
    502: '잠시 후 다시 시도해주세요',
    503: '잠시 후 다시 시도해주세요',
    504: '잠시 후 다시 시도해주세요',
  };

  /// 에러를 사용자 친화적인 메시지로 변환
  static String getUserFriendlyMessage(dynamic error) {
    // 1. DioException 직접 처리
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return _statusMessages[statusCode] ?? '네트워크 연결을 확인해주세요';
    }

    // 2. Exception 문자열에서 상태 코드 추출
    final errorString = error.toString();

    // 상태 코드 추출 (정규식 사용)
    final statusCodeMatch = RegExp(r'status code of (\d+)').firstMatch(errorString);
    if (statusCodeMatch != null) {
      final statusCode = int.tryParse(statusCodeMatch.group(1)!);
      if (statusCode != null && _statusMessages.containsKey(statusCode)) {
        return _statusMessages[statusCode]!;
      }
    }

    // 3. 특별한 에러 패턴 처리
    if (errorString.contains('SocketException') || errorString.contains('TimeoutException')) {
      return '네트워크 연결을 확인해주세요';
    }

    return '다시 시도해주세요';
  }
}