import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../api/auth.dart';
import '../utils/navigation_helper.dart';
import '../utils/color_schemes.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // fquery mutation 사용
    final signInMutation = useMutation(
      (void _) => AuthApi.signInWithKakao(),
      onSuccess: (token, _, __) {
        // 토큰 발급 성공 - MainPage로 이동
        NavigationHelper.navigateToMainAfterLogin(context);
      },
      onError: (error, _, __) {
        // 토큰 발급 실패 - 스낵바로 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundSecondary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            const Text(
              'ClimbX',
              style: TextStyle(
                color: AppColorSchemes.textPrimary,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 16),

            // 서브 타이틀
            const Text(
              '카카오로 로그인',
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
                  onTap: signInMutation.isPending ? null : () => signInMutation.mutate(null),
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

            const SizedBox(height: 24),

            // 설명 텍스트
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '카카오 계정으로 간편하게 로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColorSchemes.textTertiary,
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
