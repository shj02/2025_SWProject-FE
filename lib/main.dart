import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/travel_preference_screen.dart';
import 'screens/main_menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'YeongdeokSea', // 적용되어 있으면 YeongdeokSea 폰트 사용
        useMaterial3: true,
      ),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/preference': (context) => const TravelPreferenceScreen(),
        '/main': (context) => const MainMenuScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
