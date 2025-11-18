import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';
import 'package:sw_project_fe/config/api_config.dart';

// (지금은 바로 사용 안 하지만, 나중에 직접 화면 푸시할 때 쓸 수 있어서 놔둬도 됨)
// import 'package:sw_project_fe/screens/signup_screen.dart';

// 카카오 로그인 후 백엔드에서 내려주는 응답 DTO
class LoginResult {
  final String token;
  final int userId;
  final bool registered;

  LoginResult({
    required this.token,
    required this.userId,
    required this.registered,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'] as String,
      userId: json['userId'] as int,
      registered: json['registered'] as bool,
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // 로그인 화면 안에 있는 메서드
  Future<LoginResult?> _sendKakaoTokenToBackend(String accessToken) async {
    debugPrint('🛰 백엔드 로그인 요청 보냄');

    try {
      final url = Uri.parse('$baseUrl/api/auth/kakao');

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResult.fromJson(json);
      } else {
        // 200이 아니면 신규 회원일 수도 있고, 에러일 수도 있으니 null 처리
        return null;
      }
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
      final loginResult =
      await _sendKakaoTokenToBackend(token.accessToken);

      if (!mounted) return;

      if (loginResult == null) {
        // 백엔드에서 200이 아닌 코드 반환하거나, 파싱 실패한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          ),
        );
        return;
      }

      // 🔐 JWT & userId를 전역(UserService) 에 저장
      final userService = UserService();
      userService.setAuthToken(loginResult.token);
      userService.setUserId(loginResult.userId);

      if (loginResult.registered) {
        // 👉 이미 여행 취향까지 선택을 끝낸 기존 회원
        debugPrint('✅ 기존 회원 → 메인으로 이동');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // 👉 회원가입 미완료 사용자 → 추가 정보 입력 화면으로 이동
        debugPrint('ℹ️ 신규 또는 미완료 회원 → 회원가입 화면으로 이동');
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
