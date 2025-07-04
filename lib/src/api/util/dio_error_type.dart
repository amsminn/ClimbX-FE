import 'package:dio/dio.dart';

/// DioException 타입별 에러 메시지 관리
enum ApiDioErrorType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  connectionError,
  badResponse,
  cancel,
  badCertificate,
  unknown;

  /// DioExceptionType을 ApiDioErrorType으로 변환
  static ApiDioErrorType fromDioExceptionType(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return ApiDioErrorType.connectionTimeout;
      case DioExceptionType.sendTimeout:
        return ApiDioErrorType.sendTimeout;
      case DioExceptionType.receiveTimeout:
        return ApiDioErrorType.receiveTimeout;
      case DioExceptionType.connectionError:
        return ApiDioErrorType.connectionError;
      case DioExceptionType.badResponse:
        return ApiDioErrorType.badResponse;
      case DioExceptionType.cancel:
        return ApiDioErrorType.cancel;
      case DioExceptionType.badCertificate:
        return ApiDioErrorType.badCertificate;
      case DioExceptionType.unknown:
      default:
        return ApiDioErrorType.unknown;
    }
  }

  /// 에러 타입별 사용자 친화적 메시지 반환
  String get message {
    switch (this) {
      case ApiDioErrorType.connectionTimeout:
        return '연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.';
      case ApiDioErrorType.sendTimeout:
        return '요청 전송 시간이 초과되었습니다. 다시 시도해주세요.';
      case ApiDioErrorType.receiveTimeout:
        return '서버 응답 시간이 초과되었습니다. 다시 시도해주세요.';
      case ApiDioErrorType.connectionError:
        return '네트워크 연결을 확인해주세요.';
      case ApiDioErrorType.badResponse:
        return 'HTTP 응답 오류가 발생했습니다.';
      case ApiDioErrorType.cancel:
        return '요청이 취소되었습니다.';
      case ApiDioErrorType.badCertificate:
        return '보안 인증서에 문제가 있습니다.';
      case ApiDioErrorType.unknown:
        return '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  /// 네트워크 에러인지 확인
  bool get isNetworkError {
    return [
      ApiDioErrorType.connectionTimeout,
      ApiDioErrorType.sendTimeout,
      ApiDioErrorType.receiveTimeout,
      ApiDioErrorType.connectionError,
    ].contains(this);
  }

  /// 재시도 가능한 에러인지 확인
  bool get isRetryable {
    return [
      ApiDioErrorType.connectionTimeout,
      ApiDioErrorType.sendTimeout,
      ApiDioErrorType.receiveTimeout,
      ApiDioErrorType.connectionError,
      ApiDioErrorType.unknown,
    ].contains(this);
  }

  /// 에러 심각도 레벨 (0: 낮음, 1: 보통, 2: 높음)
  int get severityLevel {
    switch (this) {
      case ApiDioErrorType.cancel:
        return 0; // 사용자가 직접 취소한 경우
      case ApiDioErrorType.connectionTimeout:
      case ApiDioErrorType.sendTimeout:
      case ApiDioErrorType.receiveTimeout:
      case ApiDioErrorType.connectionError:
        return 1; // 네트워크 문제 (일시적일 가능성)
      case ApiDioErrorType.badResponse:
      case ApiDioErrorType.badCertificate:
      case ApiDioErrorType.unknown:
        return 2; // 서버/시스템 문제
    }
  }
} 