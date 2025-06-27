import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/auth_service.dart';
import '../screens/login_page.dart';
import '../screens/main_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    developer.log('토큰 상태 확인 중...', name: 'AuthWrapper');

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final token = await AuthService.getToken();

      developer.log('로그인 상태: $isLoggedIn', name: 'AuthWrapper');
      if (token != null) {
        developer.log(
          '저장된 토큰 발견: $token...',
          name: 'AuthWrapper',
        ); // 되면 토큰 출력 (나중에 제거)
      } else {
        developer.log('저장된 토큰 없음', name: 'AuthWrapper');
      }

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }

      if (isLoggedIn) {
        developer.log('자동 로그인 성공 - MainPage로 이동', name: 'AuthWrapper');
      } else {
        developer.log('로그인 필요 - LoginPage 표시', name: 'AuthWrapper');
      }
    } catch (e) {
      developer.log('토큰 확인 실패: $e', name: 'AuthWrapper');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 로딩 중일 때 스플래시 화면
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Text(
                'ClimbX',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),

              SizedBox(height: 32),

              // 로딩 인디케이터
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                strokeWidth: 3,
              ),

              SizedBox(height: 16),

              // 로딩 텍스트
              Text(
                '로그인 상태 확인 중...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 로딩 완료 후 적절한 페이지로 이동
    return _isLoggedIn ? const MainPage() : const LoginPage();
  }
}
