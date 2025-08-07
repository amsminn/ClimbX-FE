import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../api/auth.dart';
import '../api/util/error/auth_cancelled_exception.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../utils/navigation_helper.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // fquery mutation 사용
    final signInMutation = useMutation(
      (_) => AuthApi.signInWithKakao(),
      onSuccess: (token, _, __) {
        // 토큰 발급 성공 - MainPage로 이동
        NavigationHelper.navigateToMainAfterLogin(context);
      },
      onError: (error, _, __) {
        if (error is AuthCancelledException) return; // 사용자가 취소한 경우 무시
        final errText = error.toString().toLowerCase();
        if (errText.contains('취소') ||
            errText.contains('canceled') ||
            errText.contains('cancelled')) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // Apple 로그인 mutation
    final signInAppleMutation = useMutation(
      (_) => AuthApi.signInWithApple(),
      onSuccess: (token, _, __) {
        NavigationHelper.navigateToMainAfterLogin(context);
      },
      onError: (error, _, __) {
        if (error is AuthCancelledException) return;
        final errText = error.toString().toLowerCase();
        if (errText.contains('취소') ||
            errText.contains('canceled') ||
            errText.contains('cancelled')) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // Google 로그인 mutation
    final signInGoogleMutation = useMutation(
      (_) => AuthApi.signInWithGoogle(),
      onSuccess: (token, _, __) {
        NavigationHelper.navigateToMainAfterLogin(context);
      },
      onError: (error, _, __) {
        if (error is AuthCancelledException) return;
        final errText = error.toString().toLowerCase();
        if (errText.contains('취소') ||
            errText.contains('canceled') ||
            errText.contains('cancelled') ||
            errText.contains('sign_in_canceled')) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // Apple 로그인 사용 가능 여부 확인 (iOS 13+, Android 웹)
    final appleAvailableSnapshot = useFuture(
      useMemoized(() => SignInWithApple.isAvailable()),
    );
    final showAppleButton =
        Platform.isIOS && appleAvailableSnapshot.data == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            const Text(
              'ClimbX',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 16),

            // 서브 타이틀
            const Text(
              '소셜 계정으로 로그인',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 64),

            // 카카오 로그인 버튼
            Container(
              width: 280,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE500),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFEE500).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: signInMutation.isPending
                      ? null
                      : () => signInMutation.mutate(null),
                  child: Center(
                    child: signInMutation.isPending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3C1E1E),
                              ),
                            ),
                          )
                        : const Text(
                            '카카오 로그인',
                            style: TextStyle(
                              color: Color(0xFF3C1E1E),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Google 로그인 버튼
            Container(
              width: 280,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: signInGoogleMutation.isPending
                      ? null
                      : () => signInGoogleMutation.mutate(null),
                  child: Center(
                    child: signInGoogleMutation.isPending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E293B),
                              ),
                            ),
                          )
                        : const Text(
                            'Google 로그인',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            if (showAppleButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 280,
                height: 56,
                child: SignInWithAppleButton(
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () {
                    if (signInAppleMutation.isPending) return;
                    signInAppleMutation.mutate(null);
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 설명 텍스트
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '소셜 계정으로 로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
