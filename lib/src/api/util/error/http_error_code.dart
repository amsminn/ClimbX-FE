/// HTTP 상태 코드별 에러 메시지 관리
enum ApiHttpErrorCode {
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  notAcceptable(406),
  requestTimeout(408),
  conflict(409),
  unprocessableEntity(422),
  tooManyRequests(429),
  internalServerError(500),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504),
  unknown(0);

  const ApiHttpErrorCode(this.code);
  
  final int code;

  /// HTTP 상태 코드로부터 ApiHttpErrorCode 찾기
  static ApiHttpErrorCode fromCode(int statusCode) {
    for (final errorCode in ApiHttpErrorCode.values) {
      if (errorCode.code == statusCode) {
        return errorCode;
      }
    }
    return ApiHttpErrorCode.unknown;
  }

  /// 에러 코드별 사용자 친화적 메시지 반환
  String get message {
    switch (this) {
      case ApiHttpErrorCode.badRequest:
        return '잘못된 요청입니다.';
      case ApiHttpErrorCode.unauthorized:
        return '인증이 만료되었습니다. 다시 로그인해주세요.';
      case ApiHttpErrorCode.forbidden:
        return '접근 권한이 없습니다.';
      case ApiHttpErrorCode.notFound:
        return '요청한 리소스를 찾을 수 없습니다.';
      case ApiHttpErrorCode.methodNotAllowed:
        return '허용되지 않은 요청 방식입니다.';
      case ApiHttpErrorCode.notAcceptable:
        return '요청을 처리할 수 없습니다.';
      case ApiHttpErrorCode.requestTimeout:
        return '요청 시간이 초과되었습니다.';
      case ApiHttpErrorCode.conflict:
        return '이미 존재하는 데이터입니다.';
      case ApiHttpErrorCode.unprocessableEntity:
        return '입력 데이터가 올바르지 않습니다.';
      case ApiHttpErrorCode.tooManyRequests:
        return '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.';
      case ApiHttpErrorCode.internalServerError:
        return '서버에 일시적인 문제가 발생했습니다.';
      case ApiHttpErrorCode.badGateway:
        return '서버가 일시적으로 사용할 수 없습니다.';
      case ApiHttpErrorCode.serviceUnavailable:
        return '서비스를 일시적으로 사용할 수 없습니다.';
      case ApiHttpErrorCode.gatewayTimeout:
        return '서버 응답 시간이 초과되었습니다.';
      case ApiHttpErrorCode.unknown:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  /// 클라이언트 에러인지 확인 (4xx)
  bool get isClientError {
    return code >= 400 && code < 500;
  }

  /// 서버 에러인지 확인 (5xx)
  bool get isServerError {
    return code >= 500 && code < 600;
  }

  /// 인증 관련 에러인지 확인
  bool get isAuthError {
    return this == ApiHttpErrorCode.unauthorized;
  }

  /// 권한 관련 에러인지 확인
  bool get isPermissionError {
    return this == ApiHttpErrorCode.forbidden;
  }

  /// 유효성 검증 에러인지 확인
  bool get isValidationError {
    return [
      ApiHttpErrorCode.badRequest,
      ApiHttpErrorCode.unprocessableEntity,
    ].contains(this);
  }

  /// 재시도 가능한 에러인지 확인
  bool get isRetryable {
    return [
      ApiHttpErrorCode.requestTimeout,
      ApiHttpErrorCode.tooManyRequests,
      ApiHttpErrorCode.internalServerError,
      ApiHttpErrorCode.badGateway,
      ApiHttpErrorCode.serviceUnavailable,
      ApiHttpErrorCode.gatewayTimeout,
      ApiHttpErrorCode.unknown,
    ].contains(this);
  }

  /// 에러 심각도 레벨 (0: 낮음, 1: 보통, 2: 높음)
  int get severityLevel {
    if (isValidationError) {
      return 0; // 사용자 입력 문제
    } else if (isClientError) {
      return 1; // 클라이언트 요청 문제
    } else if (isServerError) {
      return 2; // 서버 문제
    } else {
      return 1; // 기타
    }
  }

  /// HTTP 상태 코드에 따른 로그 레벨
  String get logLevel {
    if (isValidationError) {
      return 'INFO';
    } else if (isClientError) {
      return 'WARNING';
    } else if (isServerError) {
      return 'ERROR';
    } else {
      return 'DEBUG';
    }
  }
} 