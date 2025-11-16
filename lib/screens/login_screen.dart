import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _loginWithKakao() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('로그인 버튼 클릭됨 - KAKAO 로그인 시도');

      OAuthToken token;

      // 카카오톡 앱 설치 여부에 따라 로그인 방식 선택
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('✅ 카카오 로그인 성공');
      debugPrint('accessToken: ${token.accessToken}');
      debugPrint('idToken: ${token.idToken}');

      // ─────────────────────────────────────────
      // TODO: 나중에 백엔드 연동할 때 여기서 호출
      // final response = await http.post(
      //   Uri.parse('http://백엔드주소/api/auth/kakao'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'accessToken': token.accessToken}),
      // );
      //
      // debugPrint('백엔드 응답: ${response.statusCode} ${response.body}');
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final bool isRegistered = data['isRegistered'] ?? false;
      //
      //   if (isRegistered) {
      //     // 이미 회원 → 메인으로
      //     if (!mounted) return;
      //     Navigator.pushReplacementNamed(context, '/main');
      //   } else {
      //     // 첫 로그인 → 회원가입 화면
      //     if (!mounted) return;
      //     Navigator.pushReplacementNamed(context, '/signup');
      //   }
      // } else {
      //   throw Exception('백엔드 로그인 실패: ${response.statusCode}');
      // }
      // ─────────────────────────────────────────

      // ★ 지금은 백엔드 연동 전이니까
      //    "카카오 로그인 성공하면 항상 회원가입 화면으로 보내기"
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signup');
    } catch (e, st) {
      debugPrint('❌ 카카오 로그인 실패: $e');
      debugPrint(st.toString());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 중 오류가 발생했어요.\n$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loginWithNaver() {
    // TODO: 네이버 로그인 연동 예정
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('네이버 로그인은 아직 준비 중이에요.')),
    );
  }

  void _goToEmailSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'MongleTrip',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // 카카오 로그인 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginWithKakao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          '카카오톡으로 로그인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 네이버 로그인 버튼 (임시)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginWithNaver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03C75A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          '네이버로 로그인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 이메일 회원가입
                  TextButton(
                    onPressed: _isLoading ? null : _goToEmailSignup,
                    child: const Text(
                      '이메일로 회원가입',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 로딩 인디케이터
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
