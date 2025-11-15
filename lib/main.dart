// lib/main.dart

import 'package:flutter/material.dart';
// ... (기존 screens 임포트 유지)
import 'package:sw_project_fe/services/api_services.dart'; // <-- O K

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... (Theme 및 routes 유지)
      // 👇 테스트를 위해 home을 LoginTestScreen으로 변경합니다.
      home: const LoginTestScreen(),
    );
  }
}

class LoginTestScreen extends StatelessWidget {
  const LoginTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API 연동 테스트')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 👇 버튼 클릭 시 api_services.dart에 정의된 함수 호출
            ApiService().fetchPostList();
          },
          child: const Text('백엔드 (8080) 접속 시도'),
        ),
      ),
    );
  }
}