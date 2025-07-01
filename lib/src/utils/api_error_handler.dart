import 'package:flutter/material.dart';
import '../services/api_client.dart';

/// API 에러 처리 유틸리티
class ApiErrorHandler {
  /// 에러 메시지를 스낵바로 표시
  static void showSnackBar(BuildContext context, ApiResponse response) {
    // 성공하거나 에러 메시지가 없으면 바로 리턴
    if (response.success || response.error == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.error!),
        backgroundColor: _getErrorColor(response.statusCode),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 에러 다이얼로그 표시
  static Future<void> showErrorDialog(
    BuildContext context,
    ApiResponse response, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    // 성공하거나 에러 메시지가 없으면 바로 리턴
    if (response.success || response.error == null) return;
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? '오류'),
          content: Text(response.error!),
          actions: [
            if (onRetry != null && _shouldShowRetry(response.statusCode))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('다시 시도'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 상태 코드에 따른 에러 색상 반환
  static Color _getErrorColor(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange; // 클라이언트 오류
    } else if (statusCode >= 500) {
      return Colors.red; // 서버 오류
    } else {
      return Colors.grey; // 기타 오류
    }
  }

  /// 재시도 버튼을 표시할지 결정
  static bool _shouldShowRetry(int statusCode) {
    // 서버 오류나 네트워크 오류일 때만 재시도 버튼 표시
    return statusCode >= 500 || statusCode == 0;
  }

  /// 인증 오류 처리 (로그인 페이지로 이동)
  static void handleAuthError(BuildContext context, ApiResponse response) {
    // 401 에러가 아니면 바로 리턴
    if (response.statusCode != 401) return;
    
    // 토큰 만료 또는 인증 실패
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('인증 만료'),
          content: const Text('로그인이 만료되었습니다. 다시 로그인해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 로그인 페이지로 이동 (라우팅 구조에 따라 수정 필요)
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('로그인'),
            ),
          ],
        );
      },
    );
  }
}
