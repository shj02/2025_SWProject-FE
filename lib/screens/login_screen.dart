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

  /// ✅ 카카오 accessToken을 백엔드로 보내는 함수
  Future<int?> _sendKakaoTokenToBackend(String accessToken) async {
    debugPrint('🛰 백엔드 로그인 요청 보냄');

    try {
      // ⚠️ 여기 URL을 네 백엔드 주소로 바꿔줘!
      // - 에뮬레이터: http://10.0.2.2:8080/auth/kakao
      // - 실제 폰:    http://<내 컴퓨터 IP>:8080/auth/kakao
      final url = Uri.parse('http://192.168.200.107:8080/auth/kakao');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accessToken': accessToken,
        }),
      );

      debugPrint('⬇️ 백엔드 응답 코드: ${response.statusCode}');
      debugPrint('⬇️ 백엔드 응답 바디: ${response.body}');

      return response.statusCode;
    } catch (e, st) {
      debugPrint('❌ 백엔드 통신 에러: $e');
      debugPrint('stackTrace: $st');
      return null;
    }
  }

  /// ✅ 카카오 로그인 전체 플로우 (카카오 SDK → 백엔드 → 화면 이동)
  Future<void> _loginWithKakao() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('로그인 버튼 클릭됨 - KAKAO 로그인 시도');

      OAuthToken token;

      // 카카오톡 앱 설치 여부에 따라 분기
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('✅ 카카오 로그인 성공');
      debugPrint('accessToken: ${token.accessToken}');
      debugPrint('idToken: ${token.idToken}');

      // 🔥 백엔드로 토큰 전송
      final statusCode = await _sendKakaoTokenToBackend(token.accessToken);

      if (!mounted) return;

      if (statusCode == 200) {
        // 👉 백엔드에서 "기존 회원" 이라고 응답했다고 가정
        debugPrint('✅ 백엔드 로그인 성공(기존 회원) → 메인으로 이동');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // 👉 그 외 코드(201/404 등)는 "신규 회원"이라고 가정하고 회원가입 화면으로
        debugPrint('ℹ️ 신규 회원으로 판단 → 회원가입 화면으로 이동');
        Navigator.pushReplacementNamed(context, '/signup');
      }
    } catch (e, st) {
      debugPrint('❌ 카카오 로그인 실패: $e');
      debugPrint('stackTrace: $st');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카카오 로그인에 실패했어요. 다시 시도해 주세요.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ✅ 네이버 로그인 (임시: 아직 미구현 안내만)
  Future<void> _loginWithNaver() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('네이버 로그인 시도 (아직 구현 안됨)');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('네이버 로그인은 아직 준비 중이에요 😅'),
        ),
      );
    } catch (e, st) {
      debugPrint('❌ 네이버 로그인 실패: $e');
      debugPrint('stackTrace: $st');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'MongleTrip',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '간편하게 로그인하고\n몽글몽글한 여행을 시작해요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            // ✅ 카카오 로그인 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithKakao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    '카카오로 로그인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ 네이버 로그인 버튼 (임시)
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
          ],
        ),
      ),
    );
  }
}
