
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
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0; // Figma 기준 폭
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 여백
            SizedBox(height: 24.0 * scale),

            // 중앙 로고
            Expanded(
              child: Center(
                child: _CenteredLogo(scale: scale),
              ),
            ),

            // 로그인 버튼 두 개 (네이버 / 카카오)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0 * scale),
              child: Column(
                children: [
                  _NaverLoginButton(
                    width: 349 * scale,
                    height: 70 * scale,
                    scale: scale,
                    onPressed: _loginWithNaver,
                  ),
                  SizedBox(height: 17 * scale),
                  _KakaoLoginButton(
                    width: 349 * scale,
                    height: 70 * scale,
                    scale: scale,
                    isLoading: _isLoading,
                    onPressed: _loginWithKakao,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.0 * scale),
          ],
        ),
      ),
    );
  }
}

class _CenteredLogo extends StatelessWidget {
  const _CenteredLogo({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    // Figma의 Group 16 크기를 근사치로 배치
    final double maxLogoWidth = 361.35 * scale;
    final double maxLogoHeight = 321.35 * scale;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxLogoWidth,
        maxHeight: maxLogoHeight,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * scale),
          child: Image.asset(
            'assets/logos/MongleTrip_Logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _NaverLoginButton extends StatelessWidget {
  const _NaverLoginButton({
    required this.width,
    required this.height,
    required this.scale,
    this.onPressed,
  });

  final double width;
  final double height;
  final double scale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF27D34B), // 네이버 초록색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 네이버 로고
            Container(
              width: 25 * scale,
              height: 25 * scale,
              margin: EdgeInsets.only(right: 8 * scale),
              child: Image.asset(
                'assets/logos/naver.png',
                fit: BoxFit.contain,
              ),
            ),
            Text(
              '네이버로 로그인',
              style: TextStyle(
                fontSize: 24 * scale,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({
    required this.width,
    required this.height,
    required this.scale,
    required this.isLoading,
    this.onPressed,
  });

  final double width;
  final double height;
  final double scale;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFDDC3F), // 카카오 노란색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 카카오 로고
            Container(
              width: 25 * scale,
              height: 25 * scale,
              margin: EdgeInsets.only(right: 8 * scale),
              child: Image.asset(
                'assets/logos/kakao.png',
                fit: BoxFit.contain,
              ),
            ),
            Text(
              '카카오로 로그인',
              style: TextStyle(
                fontSize: 24 * scale,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
