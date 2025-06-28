import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API 응답 결과를 담는 클래스
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
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

/// API 클라이언트 공통 클래스
class ApiClient {
  static final String _baseUrl = dotenv.env['BASE_URL'];
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  /// 공통 헤더 생성
  static Future<Map<String, String>> _getHeaders({
    bool needsAuth = false,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// HTTP 응답 처리 공통 로직
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final int statusCode = response.statusCode;

    developer.log(
      'API Response - Status: $statusCode, Body: ${response.body}',
      name: 'ApiClient',
    );

    // 200번대 성공 응답
    if (statusCode >= 200 && statusCode < 300) {
      try {
        if (response.body.isEmpty) {
          return ApiResponse.success(null as T, statusCode);
        }

        final Map<String, dynamic> data = json.decode(response.body);

        if (fromJson != null) {
          return ApiResponse.success(fromJson(data), statusCode);
        } else {
          return ApiResponse.success(data as T, statusCode);
        }
      } catch (e) {
        developer.log('JSON 파싱 오류: $e', name: 'ApiClient');
        return ApiResponse.failure('응답 데이터 파싱 오류', statusCode);
      }
    }

    // 400번대 클라이언트 오류
    if (statusCode >= 400 && statusCode < 500) {
      String errorMessage = _getErrorMessage(statusCode, response.body);

      // 401 Unauthorized - 토큰 만료 또는 무효
      if (statusCode == 401) {
        _clearStoredToken();
        errorMessage = '인증이 만료되었습니다. 다시 로그인해주세요.';
      }
      // 403 Forbidden - 권한 없음
      else if (statusCode == 403) {
        errorMessage = '접근 권한이 없습니다.';
      }
      // 404 Not Found
      else if (statusCode == 404) {
        errorMessage = '요청한 리소스를 찾을 수 없습니다.';
      }
      // 422 Unprocessable Entity - 유효성 검사 오류
      else if (statusCode == 422) {
        errorMessage = '입력 데이터가 올바르지 않습니다.';
      }

      developer.log('클라이언트 오류 - $statusCode: $errorMessage', name: 'ApiClient');
      return ApiResponse.failure(errorMessage, statusCode);
    }

    // 500번대 서버 오류
    if (statusCode >= 500) {
      developer.log('서버 오류 - $statusCode: ${response.body}', name: 'ApiClient');
      return ApiResponse.failure(
        '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
        statusCode,
      );
    }

    // 기타 오류
    return ApiResponse.failure('알 수 없는 오류가 발생했습니다.', statusCode);
  }

  /// 에러 메시지 추출
  static String _getErrorMessage(int statusCode, String responseBody) {
    try {
      final Map<String, dynamic> data = json.decode(responseBody);

      // 서버에서 제공하는 에러 메시지 우선 사용
      if (data.containsKey('message')) {
        return data['message'];
      } else if (data.containsKey('error')) {
        return data['error'];
      }
    } catch (e) {
      developer.log('에러 메시지 파싱 실패: $e', name: 'ApiClient');
    }

    return '요청 처리 중 오류가 발생했습니다. (코드: $statusCode)';
  }

  /// 저장된 토큰 삭제
  static Future<void> _clearStoredToken() async {
    await _storage.delete(key: _tokenKey);
    developer.log('만료된 토큰이 삭제되었습니다.', name: 'ApiClient');
  }

  /// GET 요청
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool needsAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final finalUri = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final headers = await _getHeaders(needsAuth: needsAuth);

      developer.log('GET 요청: $endpoint', name: 'ApiClient');

      final response = await http.get(finalUri, headers: headers);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('GET 요청 실패: $e', name: 'ApiClient');
      return ApiResponse.failure('네트워크 연결을 확인해주세요.', 0);
    }
  }

  /// POST 요청
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    bool needsAuth = false,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      developer.log(
        'POST 요청: $endpoint, Body: $body',
        name: 'ApiClient',
      );

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('POST 요청 실패: $e', name: 'ApiClient');
      return ApiResponse.failure('네트워크 연결을 확인해주세요.', 0);
    }
  }

  /// PUT 요청
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    bool needsAuth = false,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      developer.log(
        'PUT 요청: $endpoint, Body: $body',
        name: 'ApiClient',
      );

      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('PUT 요청 실패: $e', name: 'ApiClient');
      return ApiResponse.failure('네트워크 연결을 확인해주세요.', 0);
    }
  }

  /// DELETE 요청
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool needsAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      developer.log('DELETE 요청: $endpoint', name: 'ApiClient');

      final response = await http.delete(uri, headers: headers);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('DELETE 요청 실패: $e', name: 'ApiClient');
      return ApiResponse.failure('네트워크 연결을 확인해주세요.', 0);
    }
  }

  /// 기본 URL 반환
  static String? get baseUrl => _baseUrl;
}
