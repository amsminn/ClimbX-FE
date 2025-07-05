import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// 에러 인터셉터 - 로깅만 담당, 에러 처리는 핸들러에서
class ErrorInterceptor {
  /// 에러 인터셉터 생성
  static InterceptorsWrapper createInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        _logError(error);
        
        // 원본 에러를 그대로 전달 (처리는 핸들러에서)
        handler.next(error);
      },
    );
  }

  /// 에러 로깅만 담당
  static void _logError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final requestUri = error.requestOptions.uri.toString();
    final method = error.requestOptions.method;
    
    developer.log(
      'API Error: [$method] [$statusCode] $requestUri - ${error.type.name}',
      name: 'ErrorInterceptor',
      error: error.message,
    );
  }
} 