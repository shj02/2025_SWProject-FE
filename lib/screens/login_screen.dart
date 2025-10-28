import 'package:flutter/material.dart';

/// 시작 화면을 로그인 화면 이름으로 변경
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0; // Figma 기준 폭
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // #fff5f5
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 여백
            SizedBox(height: 24.0 * scale),

            // 중앙 로고 (Group 16 == MongleTrip_Logo.png)
            Expanded(
              child: Center(
                child: _CenteredLogo(scale: scale),
              ),
            ),

            // 로그인 버튼 두 개
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0 * scale),
              child: _LoginButtons(scale: scale),
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
    final double maxLogoWidth = 361.35 * scale; // 그룹 바운딩 근사
    final double maxLogoHeight = 321.35 * scale;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxLogoWidth,
        maxHeight: maxLogoHeight,
      ),
      child: AspectRatio(
        aspectRatio: 1.0, // 정사각형에 가깝게 보이도록
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

class _LoginButtons extends StatelessWidget {
  const _LoginButtons({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final double width = 349 * scale;
    final double height = 70 * scale;

    return Column(
      children: [
        _NaverLoginButton(
          width: width,
          height: height,
          scale: scale,
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
        ),
        SizedBox(height: 17 * scale),
        _KakaoLoginButton(
          width: width,
          height: height,
          scale: scale,
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
        ),
      ],
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
          backgroundColor: const Color(0xFFFDDC3F), // 카카오 노란색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Row(
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


