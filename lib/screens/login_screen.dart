import 'package:flutter/material.dart';
import 'package:sw_project_fe/services/kakao_login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();

  /// ✅ 카카오 로그인 전체 플로우 (UI -> 서비스 호출)
  Future<void> _loginWithKakao() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 서비스 레이어에 로그인 요청
      final loginResponse = await _kakaoLoginService.login();

      if (!mounted) return;

      // 신규/기존 회원 분기
      if (loginResponse.isRegistered) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다. (${e.toString()})')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ✅ 네이버 로그인 (임시)
  void _loginWithNaver() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('네이버 로그인은 아직 준비 중이에요 😅'),
      ),
    );
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
            // 카카오 로그인 버튼
            _buildLoginButton(
              onPressed: _loginWithKakao,
              backgroundColor: const Color(0xFFFEE500),
              foregroundColor: Colors.black87,
              text: '카카오로 로그인',
            ),
            const SizedBox(height: 12),
            // 네이버 로그인 버튼
            _buildLoginButton(
              onPressed: _loginWithNaver,
              backgroundColor: const Color(0xFF03C75A),
              foregroundColor: Colors.white,
              text: '네이버로 로그인',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
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
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
