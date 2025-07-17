import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dio_error_type.dart';
import 'http_error_code.dart';

/// API 에러 처리를 담당하는 유틸리티 클래스
class ErrorHandler {
  /// DioException을 사용자 친화적인 에러 메시지로 변환
  static String handleDioException(DioException error) {
    final dioErrorType = ApiDioErrorType.fromDioExceptionType(error.type);
    
    // badResponse의 경우 서버 메시지 우선 확인
    if (dioErrorType == ApiDioErrorType.badResponse) {
      final serverMessage = _extractServerMessage(error.response?.data);
      if (serverMessage != null) return serverMessage;
      
      // 서버 메시지가 없으면 HTTP 상태 코드 메시지 사용
      final statusCode = error.response?.statusCode ?? 0;
      return ApiHttpErrorCode.fromCode(statusCode).message;
    }
    
    // unknown의 경우 원본 메시지가 있으면 우선 사용
    if (dioErrorType == ApiDioErrorType.unknown && error.message?.isNotEmpty == true) {
      return error.message!;
    }
    
    return dioErrorType.message;
  }

  /// 서버 응답에서 에러 메시지 추출
  static String? _extractServerMessage(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return null;
    
    try {
      // 메시지 필드들 확인
      for (final field in ['statusMessage', 'message', 'error', 'detail']) {
        final message = responseData[field];
        if (message is String && message.isNotEmpty) return message;
      }

      // body 내부 확인
      final bodyData = responseData['body'] as Map<String, dynamic>?;
      if (bodyData != null) {
        for (final field in ['statusMessage', 'message', 'error', 'detail']) {
          final message = bodyData[field];
          if (message is String && message.isNotEmpty) return message;
        }
      }

      // errors 배열 확인
      final errors = responseData['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is String) return firstError;
        if (firstError is Map<String, dynamic>) {
          return firstError['message'] ?? '유효성 검증 오류가 발생했습니다.';
        }
      }
    } catch (e) {
      developer.log('서버 메시지 추출 실패: $e', name: 'ErrorHandler');
    }
    
    return null;
  }

  /// API 에러를 사용자에게 표시
  static Future<void> handleApiError(
    BuildContext context, 
    DioException error, {
    bool showDialog = false,
    VoidCallback? onRetry,
  }) async {
    final statusCode = error.response?.statusCode ?? 0;
    final errorMessage = handleDioException(error);
    
    developer.log(
      'API Error: [$statusCode] ${error.requestOptions.uri} - $errorMessage',
      name: 'ErrorHandler',
    );

    // 인증 오류 특별 처리
    if (statusCode == 401) {
      await _showAuthErrorDialog(context);
      return;
    }

    // 에러 표시 방식 선택
    if (showDialog) {
      await _showErrorDialog(context, errorMessage, statusCode: statusCode, onRetry: onRetry);
    } else {
      _showSnackBar(context, errorMessage, statusCode: statusCode);
    }
  }

  /// 에러 메시지를 스낵바로 표시
  static void _showSnackBar(BuildContext context, String errorMessage, {int? statusCode}) {
    if (errorMessage.isEmpty) return;
    
    final httpErrorCode = ApiHttpErrorCode.fromCode(statusCode ?? 0);
    Color backgroundColor = Colors.grey;
    if (httpErrorCode.isClientError) {
      backgroundColor = Colors.orange;
    } else if (httpErrorCode.isServerError) {
      backgroundColor = Colors.red;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// 에러 다이얼로그 표시
  static Future<void> _showErrorDialog(
    BuildContext context,
    String errorMessage, {
    String? title,
    int? statusCode,
    VoidCallback? onRetry,
  }) async {
    if (errorMessage.isEmpty) return;
    
    final canRetry = statusCode != null && ApiHttpErrorCode.fromCode(statusCode).isRetryable;
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? '오류'),
        content: Text(errorMessage),
        actions: [
          if (onRetry != null && canRetry)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('다시 시도'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 인증 오류 다이얼로그 표시
  static Future<void> _showAuthErrorDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('인증 만료'),
        content: const Text('로그인이 만료되었습니다. 다시 로그인해주세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 라우팅 구조에 맞게 수정 필요
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  // === 유틸리티 메서드들 ===

  /// 네트워크 에러 여부 확인
  static bool isNetworkError(DioException error) {
    return ApiDioErrorType.fromDioExceptionType(error.type).isNetworkError;
  }

  /// 재시도 가능한 에러인지 확인
  static bool isRetryableError(DioException error) {
    final dioErrorType = ApiDioErrorType.fromDioExceptionType(error.type);
    if (dioErrorType.isRetryable) return true;
    
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return ApiHttpErrorCode.fromCode(statusCode).isRetryable;
    }
    
    return false;
  }

  /// 에러 로깅
  static void logError(DioException error, {String? context}) {
    final statusCode = error.response?.statusCode ?? 0;
    final message = handleDioException(error);
    final contextStr = context != null ? '[$context] ' : '';
    
    developer.log(
      '${contextStr}API Error: $statusCode - $message',
      name: 'ErrorHandler',
      error: error,
    );
  }
} 