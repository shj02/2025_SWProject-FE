import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/travel_preference_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/tripplan_date_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/new_write_screen.dart';
import 'screens/newplan_screen.dart';

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
        '/date': (context) => const TripPlanDateScreen(),
        '/community': (context) => const CommunityScreen(),
        '/profile': (context) => const ProfileEditScreen(),
        '/newplan': (context) => const NewPlanScreen(),
        '/newwrite': (context) => const NewWriteScreen(),
        // '/post/:id' - PostDetailScreen은 매개변수가 필요하므로 직접 Navigator.push 사용
      },
      home: const LoginScreen(),
    );
  }
}
