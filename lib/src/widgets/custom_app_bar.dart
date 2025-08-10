import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../utils/navigation_helper.dart';
import '../utils/color_schemes.dart';
import '../api/auth.dart';
import 'package:dio/dio.dart'; // TEMP: debug PATCH
import 'package:flutter/services.dart'; // TEMP: input formatter
import '../api/util/auth/token_storage.dart'; // TEMP: get current nickname
import '../api/util/core/api_client.dart'; // TEMP: BASE_URL 사용

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColorSchemes.backgroundPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

      // 로고
      title: const Text(
        'ClimbX',
        style: TextStyle(
          color: AppColorSchemes.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      // 액션들
      actions: [
        // 로그아웃 버튼 (임시, 나중에 제거 예정)
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColorSchemes.textSecondary,
              size: 22,
            ),
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ),

        // TEMP: 디버그 - 현재 닉네임의 레이팅 PATCH 후 즉시 로그아웃
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.bug_report_outlined,
              color: AppColorSchemes.textSecondary,
              size: 22,
            ),
            onPressed: () async {
              try {
                final nickname = await TokenStorage.getUserNickname() ?? 'alice';
                if (!context.mounted) return;
                final controller = TextEditingController();
                final rating = await showDialog<int>(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('레이팅 입력'),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: '정수값을 입력하세요',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (controller.text.isEmpty) {
                              Navigator.of(ctx).pop();
                              return;
                            }
                            final value = int.tryParse(controller.text);
                            Navigator.of(ctx).pop(value);
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    );
                  },
                );
                if (rating == null) return;

                final baseUrl = ApiClient.baseUrl ?? '';
                final dio = Dio(
                  BaseOptions(
                    baseUrl: baseUrl,
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ),
                );

                await dio.patch('/api/users/$nickname/rating', data: rating);
                if (!context.mounted) return;
                _handleLogout(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('레이팅 갱신 실패: $e')),
                );
                return;
              }
            },
          ),
        ),

        // 알림
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColorSchemes.textSecondary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ),
        // 메뉴
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColorSchemes.textSecondary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // 로그아웃 처리
  static void _handleLogout(BuildContext context) {
    developer.log('로그아웃 요청', name: 'CustomAppBar');

    AuthHelpers.clearToken()
      .then((_) {
        developer.log('토큰 삭제 완료', name: 'CustomAppBar');

        // LoginPage로 이동
        if (context.mounted) {
          NavigationHelper.navigateToLoginAfterLogout(context);
          developer.log('LoginPage로 이동 완료', name: 'CustomAppBar');
        }
      })
      .catchError((error) {
        developer.log('로그아웃 실패: $error', name: 'CustomAppBar');
      });
  }
}
