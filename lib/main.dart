import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fquery/fquery.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'src/widgets/auth_wrapper.dart';
import 'src/api/util/core/api_client.dart';
import 'src/api/util/auth/auth_interceptor.dart';
import 'src/utils/color_schemes.dart';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';

// 전역 네비게이터 키 (팝업용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    developer.log('Firebase 초기화 실패: $e', name: 'Firebase');
    // Firebase 실패해도 앱은 계속 실행
  }
  // 네이버 맵 클라이언트 ID 검증
  const naverMapClientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
  if (naverMapClientId.isEmpty) {
    throw Exception('NAVER_MAP_CLIENT_ID가 설정되지 않았습니다.');
  }
  
  await FlutterNaverMap().init(
    clientId: naverMapClientId,
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          developer.log('사용량 초과 (message: $message)', name: 'FlutterNaverMap');
          break;
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAnotherAuthFailedException():
          developer.log('인증 실패: $ex', name: 'FlutterNaverMap');
          break;
      }
    },
  );

  // 카카오 SDK 초기화
  const kakaoNativeAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  if (kakaoNativeAppKey.isEmpty) {
    throw Exception('KAKAO_NATIVE_APP_KEY가 설정되지 않았습니다.');
  }
  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

  // API 클라이언트 초기화
  ApiClient.instance;

  // AuthInterceptor 콜백 설정 - 토큰 만료 시 처리
  AuthInterceptor.setOnUnauthorized(() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // 토큰 만료 팝업 표시
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  color: AppColorSchemes.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColorSchemes.accentOrange,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 제목
              const Text(
                '로그아웃',
                style: TextStyle(
                  color: AppColorSchemes.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 메시지
              const Text(
                '다시 로그인해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColorSchemes.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // AuthWrapper가 자동으로 로그인 상태를 확인하고 게스트 모드로 이동
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 딥링크 상수
  static const _deepLinkScheme = 'climbx';
  static const _deepLinkHost = 'open';

  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  /// 딥링크 초기화 및 처리
  Future<void> _initDeepLinks() async {
    // 앱이 종료된 상태에서 딥링크로 실행된 경우 처리
    try {
      final initialLink = await getInitialLink();
      // await 이후 위젯이 unmount되었는지 확인
      if (!mounted) return;

      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      developer.log('Initial deep link error: $e', name: 'DeepLink');
    }

    // 앱이 백그라운드에 있을 때 딥링크 처리
    _deepLinkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      developer.log('Deep link stream error: $err', name: 'DeepLink');
    });
  }

  /// 딥링크 URL 처리
  void _handleDeepLink(String link) {
    developer.log('Deep link received: $link', name: 'DeepLink');

    final uri = Uri.parse(link);

    // climbx://open 처리
    if (uri.scheme == _deepLinkScheme && uri.host == _deepLinkHost) {
      developer.log('ClimbX app opened via deep link', name: 'DeepLink');
      // 홈 화면으로 이동하거나 특정 동작 수행
      // 현재는 앱이 열리는 것만으로도 충분하므로 추가 동작 없음
    }
  }

  @override
  Widget build(BuildContext context) {
    return QueryClientProvider(
      queryClient: QueryClient(),
      child: MaterialApp(
        title: 'ClimbX',
        theme: ThemeData(primarySwatch: Colors.blue),
        navigatorKey: navigatorKey, // 전역 네비게이터 키 설정
        home: const AuthWrapper(),
      ),
    );
  }
}
