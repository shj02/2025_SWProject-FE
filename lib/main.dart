import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ 풀스크린 위해 추가
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/travel_preference_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/tripplan_date_screen.dart';
import 'screens/community_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/new_write_screen.dart';
import 'screens/newplan_screen.dart';

Future<void> main() async {
  // 비동기 초기화 전에 플러터 바인딩
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 전체 앱 풀스크린 모드
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ✅ 카카오 SDK 초기화 (네이티브 앱 키로)
  KakaoSdk.init(
    nativeAppKey: '65d236de77aaf5df53ef3101daec3880', // Kakao Developers에서 가져온 네이티브 앱 키
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'YeongdeokSea',
        useMaterial3: true,
      ),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/preference': (context) => const TravelPreferenceScreen(),
        '/main': (context) => const MainMenuScreen(),
        '/date': (context) => const TripPlanDateScreen(),
        '/community': (context) => const CommunityScreen(),
        '/profile': (context) => const MypageScreen(),
        '/newplan': (context) => const NewPlanScreen(),
        '/newwrite': (context) => const NewWriteScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
