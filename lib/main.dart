import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sw_project_fe/services/auth_api.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/travel_preference_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/community_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/new_write_screen.dart';
import 'screens/newplan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '65d236de77aaf5df53ef3101daec3880',
  );

  // 앱 시작 시 모든 로그인 정보 초기화
  await _forceInitialLogout();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

/// 앱 시작 시점에 실행되는 강제 로그아웃 함수
Future<void> _forceInitialLogout() async {
  // 1. 서버에 로그아웃 요청 및 클라이언트 토큰 삭제
  await AuthService().clearSession();

  // 2. 카카오 SDK에 남아있는 토큰 삭제 (선택적이지만 안전함)
  try {
    await UserApi.instance.logout();
  } catch (e) {
    // 이미 로그아웃된 경우 등 오류 무시
  }
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
        // TODO: TripId를 필요로 하는 화면들은 라우팅 방식을 수정해야 함
        // '/date': (context) => const TripPlanDateScreen(), 
        '/community': (context) => const CommunityScreen(),
        '/profile': (context) => const MypageScreen(),
        '/newplan': (context) => const NewPlanScreen(),
        '/newwrite': (context) => const NewWriteScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
