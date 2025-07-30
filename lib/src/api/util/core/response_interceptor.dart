import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../error/error_handler.dart';
import '../core/api_client.dart';

/// Response를 ApiResponse로 변환하는 인터셉터
class ResponseInterceptor {
  /// Response 변환 인터셉터 생성
  static InterceptorsWrapper createInterceptor() {
    return InterceptorsWrapper(
      onResponse: (response, handler) {
        // fromJson 함수는 requestOptions.extra에서 가져옴
        final fromJson = response.requestOptions.extra?['fromJson'] as Function(Map<String, dynamic>)?;
        
        try {
          final convertedResponse = _convertResponse(response, fromJson);
          
          // 변환된 ApiResponse를 response.data에 저장
          response.data = convertedResponse;
          
          handler.next(response);
        } catch (e) {
          developer.log('Response 변환 오류: $e', name: 'ResponseInterceptor');
          final errorResponse = ApiResponse.failure(
            '응답 데이터 파싱 오류: $e', 
            response.statusCode ?? 0
          );
          response.data = errorResponse;
          handler.next(response);
        }
      },
      onError: (error, handler) {
        // DioException을 ApiResponse로 변환
        final convertedError = _convertError(error);
        
        // 변환된 ApiResponse를 DioException의 response.data에 저장
        if (error.response != null) {
          error.response!.data = convertedError;
          handler.next(error);
        } else {
          // response가 없는 경우 새로운 DioException 생성
          final newError = DioException(
            requestOptions: error.requestOptions,
            error: error.error,
            type: error.type,
            stackTrace: error.stackTrace,
            message: error.message,
            response: Response<dynamic>(
              requestOptions: error.requestOptions,
              statusCode: 0,
              data: convertedError,
            ),
          );
          handler.next(newError);
        }
      },
    );
  }

  /// Dio Response를 ApiResponse로 변환
  static ApiResponse<T> _convertResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode ?? 0;

    // HTTP 상태 코드 체크
    if (statusCode < 200 || statusCode >= 300) {
      return ApiResponse.failure('HTTP 상태 코드 오류', statusCode);
    }

    final responseData = response.data;
    
    // null 체크
    if (responseData == null) {
      return ApiResponse.failure('응답 데이터가 없습니다', statusCode);
    }

    // API 응답 구조에 따른 데이터 추출
    final actualData = _extractData(responseData);

    // fromJson이 있으면 변환, 없으면 data를 그대로 반환
    if (fromJson != null && actualData is Map<String, dynamic>) {
      return ApiResponse.success(fromJson(actualData), statusCode);
    } else {
      return ApiResponse.success(actualData as T, statusCode);
    }
  }

  /// 응답 데이터에서 실제 데이터 추출
  static dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // body.data 구조 확인
      final bodyData = responseData['body'] as Map<String, dynamic>?;
      if (bodyData != null && bodyData.containsKey('data')) {
        return bodyData['data'];
      }
      
      // data 필드 직접 확인
      if (responseData.containsKey('data')) {
        return responseData['data'];
      }
    }
    
    return responseData;
  }

  /// DioException을 ApiResponse로 변환
  static ApiResponse<T> _convertError<T>(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    
    // 모든 DioException 처리는 error_handler에서 담당
    final errorMessage = ErrorHandler.handleDioException(error);
    
    return ApiResponse.failure(errorMessage, statusCode);
  }
} 