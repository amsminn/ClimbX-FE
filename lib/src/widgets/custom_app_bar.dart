import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../utils/navigation_helper.dart';
import '../utils/color_schemes.dart';
import '../api/auth.dart';
import 'package:dio/dio.dart'; // TEMP: debug PATCH
import 'package:flutter/services.dart'; // TEMP: input formatter
import '../api/util/auth/token_storage.dart'; // TEMP: get current nickname
import '../api/util/core/api_client.dart'; // TEMP: BASE_URL 사용
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      title: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(
          'ClimbX',
          style: TextStyle(
            color: AppColorSchemes.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      centerTitle: false, // 왼쪽 정렬

      // 액션들
      actions: [
        // 레이팅 디버깅 버튼 삭제

        // 알림 버튼 (비활성화/주석 처리)
        // Container(
        //   margin: const EdgeInsets.only(right: 8),
        //   decoration: BoxDecoration(
        //     color: AppColorSchemes.backgroundSecondary,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: IconButton(
        //     icon: const Icon(
        //       Icons.notifications_outlined,
        //       color: AppColorSchemes.textSecondary,
        //       size: 22,
        //     ),
        //     onPressed: () {},
        //   ),
        // ),
        // 설정
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppColorSchemes.textSecondary,
              size: 22,
            ),
            onPressed: () {
              NavigationHelper.navigateToSettings(context);
            },
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
