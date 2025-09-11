import 'package:flutter/material.dart';
import '../utils/color_schemes.dart';
import '../screens/login_page.dart';

/// 로그인 프롬프트 다이얼로그를 표시하는 공통 유틸리티
class LoginPromptHelper {
  /// 로그인 프롬프트 다이얼로그 표시
  static void showLoginPrompt(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: AppColorSchemes.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColorSchemes.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.login,
                  color: AppColorSchemes.accentBlue,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 제목
              const Text(
                '로그인 필요',
                style: TextStyle(
                  color: AppColorSchemes.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 메시지
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColorSchemes.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 버튼들
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColorSchemes.backgroundSecondary,
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: AppColorSchemes.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 로그인 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorSchemes.accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}