import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'error_handler.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'response_interceptor.dart';

/// API 응답 결과를 담는 클래스
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, int statusCode) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.failure(String error, int statusCode) {
    return ApiResponse(success: false, error: error, statusCode: statusCode);
  }
}

/// 강화된 Dio 기반 API 클라이언트
class ApiClient {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  late final Dio _dio;
  static ApiClient? _instance;

  // 싱글톤 패턴
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// Dio 인스턴스에 직접 접근
  Dio get dio => _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 인증 토큰 인터셉터 추가
    _dio.interceptors.add(AuthInterceptor.createInterceptor());
    
    // Response 변환 인터셉터 추가
    _dio.interceptors.add(ResponseInterceptor.createInterceptor());
    
    // 에러 처리 인터셉터 추가
    _dio.interceptors.add(ErrorInterceptor.createInterceptor());

    // 로깅 인터셉터 (개발 모드에서만)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => developer.log(obj.toString(), name: 'ApiClient'),
      ));
    }
  }

  /// 인터셉터 콜백 설정
  void setInterceptorCallbacks({
    Function()? onUnauthorized,
  }) {
    // 인증 관련 콜백 설정
    AuthInterceptor.setOnUnauthorized(onUnauthorized);
  }

  /// 기본 URL 반환
  static String? get baseUrl => _baseUrl;

  /// 클라이언트 재설정 (테스트용)
  static void reset() {
    _instance = null;
  }
} 