import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../api/auth.dart';
import '../utils/navigation_helper.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // fquery mutation 사용
    final signInMutation = useMutation(
      (void _) => AuthApi.signInWithGoogle(),
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
              '로그인 테스트',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 64),

            // 토큰 발급 버튼
            Container(
              width: 280,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
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
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
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
                'Mock API를 사용한 테스트 환경입니다.\n버튼을 눌러 JWT 토큰을 발급받으세요.',
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
