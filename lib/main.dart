import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fquery/fquery.dart';
import 'src/widgets/auth_wrapper.dart';
import 'src/api/util/core/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await FlutterNaverMap().init(clientId: dotenv.env['NAVER_MAP_CLIENT_ID']);
  
  // API 클라이언트 초기화 - 싱글톤 인스턴스로 인터셉터 설정
  ApiClient.instance;

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
