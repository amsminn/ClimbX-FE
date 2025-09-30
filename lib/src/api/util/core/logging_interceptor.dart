import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:developer' as developer;

/// Development logging interceptor with sensitive data redaction.
/// - Avoids logging full response bodies for auth endpoints
/// - Redacts common token fields in JSON
class LoggingInterceptor {
  static InterceptorsWrapper create() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          final uri = options.uri;
          final isAuth = _isAuthPath(uri.path);
          final reqSummary = '[REQ] ${options.method} ${uri.toString()}';

          if (isAuth) {
            // Do not log auth request bodies
            developer.log(reqSummary, name: 'ApiClient');
          } else {
            dynamic bodyLog;
            if (options.data != null) {
              bodyLog = _redactIfJson(options.data);
            }
            developer.log(
              bodyLog != null ? '$reqSummary body=${jsonEncode(bodyLog)}' : reqSummary,
              name: 'ApiClient',
            );
          }
        } catch (_) {}
        handler.next(options);
      },
      onResponse: (response, handler) {
        try {
          final uri = response.requestOptions.uri;
          final isAuth = _isAuthPath(uri.path);
          final resSummary = '[RES] ${response.statusCode} ${uri.toString()}';

          if (isAuth) {
            // Never log auth responses (may contain tokens)
            developer.log(resSummary, name: 'ApiClient');
          } else {
            dynamic dataLog = response.data;
            dataLog = _redactIfJson(dataLog);
            final logStr = dataLog != null ? '$resSummary body=${_safeEncode(dataLog)}' : resSummary;
            developer.log(logStr, name: 'ApiClient');
          }
        } catch (_) {}
        handler.next(response);
      },
      onError: (error, handler) {
        try {
          final uri = error.requestOptions.uri;
          final code = error.response?.statusCode;
          final isAuth = _isAuthPath(uri.path);
          final errSummary = '[ERR] ${error.requestOptions.method} [$code] ${uri.toString()} - ${error.type.name}';

          if (isAuth) {
            developer.log(errSummary, name: 'ApiClient', error: error.message);
          } else {
            dynamic dataLog = error.response?.data;
            dataLog = _redactIfJson(dataLog);
            final logStr = dataLog != null ? '$errSummary body=${_safeEncode(dataLog)}' : errSummary;
            developer.log(logStr, name: 'ApiClient', error: error.message);
          }
        } catch (_) {}
        handler.next(error);
      },
    );
  }

  static bool _isAuthPath(String path) {
    // Treat all auth paths as sensitive
    return path.startsWith('/api/auth');
  }

  static dynamic _redactIfJson(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return _redactMap(Map<String, dynamic>.from(data));
      }
      if (data is List) {
        return data.map(_redactIfJson).toList();
      }
      return data;
    } catch (_) {
      return data;
    }
  }

  static Map<String, dynamic> _redactMap(Map<String, dynamic> map) {
    const sensitiveKeys = {
      'accessToken',
      'refreshToken',
      'idToken',
      'token',
      'authorization',
      'Authorization',
      'password',
      'secret',
      'clientSecret',
    };

    map.updateAll((key, value) {
      if (sensitiveKeys.contains(key)) {
        return _mask(value);
      }
      if (value is Map<String, dynamic>) {
        return _redactMap(Map<String, dynamic>.from(value));
      }
      if (value is List) {
        return value.map((e) => e is Map<String, dynamic> ? _redactMap(Map<String, dynamic>.from(e)) : e).toList();
      }
      return value;
    });
    return map;
  }

  static String _mask(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.isEmpty) return '';
    // Keep short tail for debugging, mask the rest
    final tail = str.length > 6 ? str.substring(str.length - 6) : str;
    return '***REDACTED***:$tail';
  }

  static String _safeEncode(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}

