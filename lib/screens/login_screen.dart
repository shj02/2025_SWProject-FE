import 'package:flutter/material.dart';

/// 시작 화면: 배경색, 중앙 로고, 로그인 버튼 구성
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0; // Figma 기준 폭
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // #fff5f5
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 여백

            SizedBox(height: 24.0 * scale),

            // 중앙 로고 (MongleTrip_Logo.png)
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
        _RoundedButton(
          width: width,
          height: height,
          background: const Color(0xFFEEC3A7).withOpacity(0.3),
          label: '네이버로 로그인',
          textColor: const Color(0xFF1A0802),
          onPressed: () {
            // TODO: 네이버 로그인 연동
          },
        ),
        SizedBox(height: 15 * scale),
        _RoundedButton(
          width: width,
          height: height,
          background: const Color(0xFFEEC3A7).withOpacity(0.3),
          label: '카카오로 로그인',
          textColor: const Color(0xFF1A0802),
          onPressed: () {
            // TODO: 카카오 로그인 연동
          },
        ),
      ],
    );
  }
}

class _RoundedButton extends StatelessWidget {
  const _RoundedButton({
    required this.width,
    required this.height,
    required this.background,
    required this.label,
    required this.textColor,
    this.onPressed,
  });

  final double width;
  final double height;
  final Color background;
  final String label;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20 * (width / (349 * (MediaQuery.of(context).size.width / 402.0))),
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}