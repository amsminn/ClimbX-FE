import 'package:dio/dio.dart';

/// 에러를 사용자 친화적인 메시지로 변환하는 헬퍼 클래스
class ErrorMessageHelper {
  // 상태 코드별 메시지 매핑
  static const Map<int, String> _statusMessages = {
    409: '이미 제출한 영상입니다',
    400: '잘못된 요청입니다',
    401: '로그인이 필요합니다',
    403: '접근 권한이 없습니다',
    404: '요청한 리소스를 찾을 수 없습니다',
    429: '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해 주세요',
    500: '서버에서 문제가 발생했습니다. 잠시 후 다시 시도해 주세요',
    502: '서버에서 문제가 발생했습니다. 잠시 후 다시 시도해 주세요',
    503: '서버에서 문제가 발생했습니다. 잠시 후 다시 시도해 주세요',
    504: '서버에서 문제가 발생했습니다. 잠시 후 다시 시도해 주세요',
  };

  /// 에러를 사용자 친화적인 메시지로 변환
  static String getUserFriendlyMessage(dynamic error) {
    // 1. DioException 직접 처리
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return _statusMessages[statusCode] ?? '네트워크 오류가 발생했습니다';
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
      return '네트워크 연결을 확인해 주세요';
    }
    
    return '알 수 없는 오류가 발생했습니다';
  }
}