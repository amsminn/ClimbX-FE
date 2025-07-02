import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fquery/fquery.dart';
import 'src/widgets/auth_wrapper.dart';
import 'src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await FlutterNaverMap().init(clientId: dotenv.env['NAVER_MAP_CLIENT_ID']);
  
  // AuthService 초기화 - API 클라이언트의 401 에러 콜백 설정
  AuthService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return QueryClientProvider(
      queryClient: QueryClient(),
      child: MaterialApp(
        title: 'ClimbX',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(),
      ),
    );
  }
}
