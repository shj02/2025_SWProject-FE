import 'package:flutter/material.dart';
import 'dart:ui';

class TravelPreferenceScreen extends StatefulWidget {
  const TravelPreferenceScreen({super.key});

  @override
  State<TravelPreferenceScreen> createState() => _TravelPreferenceScreenState();
}

class _TravelPreferenceScreenState extends State<TravelPreferenceScreen> {
  final Set<String> _selectedPreferences = {};

  final List<PreferenceOption> _preferences = [
    PreferenceOption('🎢', '액티비티'),
    PreferenceOption('🧘', '힐링·휴양'),
    PreferenceOption('🖼️', '문화 탐방'),
    PreferenceOption('🍕', '맛집 탐방'),
    PreferenceOption('🛍️', '쇼핑'),
    PreferenceOption('🌲', '자연·풍경'),
    PreferenceOption('🏙️', '도시 중심형'),
    PreferenceOption('🏡', '로컬 중심형'),
    PreferenceOption('💎', '럭셔리'),
    PreferenceOption('💸', '실속·가성비'),
    PreferenceOption('🎒', '모험·백팩커'),
  ];

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
  }

  void _onStartPressed() {
    print('버튼이 눌렸습니다!'); // 디버깅용 로그
    print('선택된 선호도: $_selectedPreferences'); // 디버깅용 로그
    
    if (_selectedPreferences.isNotEmpty) {
      print('메인 메뉴로 이동합니다.'); // 디버깅용 로그
      // 메인 메뉴 화면으로 이동
      Navigator.pushNamed(context, '/main');
    } else {
      print('선호도를 선택해주세요.'); // 디버깅용 로그
      // ScaffoldMessenger를 사용하여 스낵바를 표시합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '최소 하나의 여행 스타일을 선택해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFFF8282), // 기존과 동일한 배경색

          // --- 여기부터 스타일 변경 ---
          behavior: SnackBarBehavior.floating, // 1. 플로팅 형태로 변경
          shape: RoundedRectangleBorder( // 2. 모서리를 둥글게
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.only( // 3. 화면 상단에 위치시키기
            // 화면 상단에서 100만큼 떨어진 위치에 스낵바를 표시
            bottom: 140,
            right: 20,
            left: 20,
          ),
          duration: const Duration(seconds: 2), // 2초 동안 보여짐
          elevation: 6.0, // 그림자 효과
          // --- 여기까지 스타일 변경 ---
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0; // Figma 기준 폭
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC), // #fffcfc
      body: SafeArea(
        child: Stack(
          children: [
            // 장식용 이미지 (피그마 좌표 기준)
            Positioned(
              left: 148 * scale,
              top: 57 * scale,
              child: Image.asset(
                'assets/icons/ellipse1.png', // 이미지 경로
                width: 200 * scale,
                height: 200 * scale,
              ),
            ),
            Positioned(
              left: 254 * scale,
              top: 142 * scale,
              child: Image.asset(
                'assets/icons/ellipse2.png', // 이미지 경로
                width: 130 * scale,
                height: 130 * scale,
              ),
            ),
            // 메인 콘텐츠
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 33.0 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 154.0 * scale), // 상단 여백 (807-653 = 154)

                  // 제목
                  _TitleSection(scale: scale),

                  SizedBox(height: 44.0 * scale), // 제목과 선택지 사이 여백

                  // 선택지 그리드
                  Expanded(
                    child: _PreferenceGrid(
                      preferences: _preferences,
                      selectedPreferences: _selectedPreferences,
                      onToggle: _togglePreference,
                      scale: scale,
                    ),
                  ),

                  SizedBox(height: 60.0 * scale), // 그리드와 버튼 사이 여백

                  // 시작하기 버튼
                  _StartButton(
                    onPressed: _onStartPressed,
                    scale: scale,
                  ),

                  SizedBox(height: 60.0 * scale), // 하단 여백
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      '어떤 여행 스타일을\n좋아하세요?',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 32 * scale,
        color: const Color(0xFF1A0802),
        height: 40 / 32, // lineHeightPx / fontSize
        letterSpacing: 0,
        shadows: [
          Shadow(
            color: const Color(0x40000000), // 25% 투명도의 검은색
            offset: Offset(4, 2 * scale),
            blurRadius: 4 * scale,
          ),
        ],
      ),
    );
  }
}

class _PreferenceGrid extends StatelessWidget {
  const _PreferenceGrid({
    required this.preferences,
    required this.selectedPreferences,
    required this.onToggle,
    required this.scale,
  });

  final List<PreferenceOption> preferences;
  final Set<String> selectedPreferences;
  final Function(String) onToggle;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 336 * scale,
      height: 335 * scale,
      child: Wrap(
        spacing: 6 * scale, // 버튼 간 가로 간격
        runSpacing: 13 * scale, // 버튼 간 세로 간격
        children: preferences.map((preference) {
          final isSelected = selectedPreferences.contains(preference.label);
          return _PreferenceChip(
            preference: preference,
            isSelected: isSelected,
            onTap: () => onToggle(preference.label),
            scale: scale,
          );
        }).toList(),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.preference,
    required this.isSelected,
    required this.onTap,
    required this.scale,
  });

  final PreferenceOption preference;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 108 * scale,
        height: 31 * scale,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFA0A0) // 선택된 상태: #fc5858 50% opacity
              : const Color(0xFFFFFBF4), // 기본 상태: #fffbf4
          borderRadius: BorderRadius.circular(50 * scale),
          border: isSelected
              ? null
              : Border.all(
            color: const Color(0xFFE3E3E3), // #e3e3e3
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000), // 25% 투명도의 검은색
              offset: Offset(4, 4 * scale),
              blurRadius: 4 * scale,
              spreadRadius: 0,
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${preference.emoji}   ${preference.label}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
              color: const Color(0xFF1A0802),
              letterSpacing: -0.25,
              height: 24 / 14, // lineHeightPx / fontSize
            ),
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.onPressed,
    required this.scale,
  });

  final VoidCallback onPressed;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 326 * scale,
        height: 64 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFFFF8282), // #ff8282
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000), // 25% 투명도의 검은색
              offset: Offset(4, 4 * scale), // 아래쪽으로만 그림자
              blurRadius: 4 * scale, // 더 부드러운 그림자
              spreadRadius: 0,
              blurStyle: BlurStyle.inner,
            ),
            BoxShadow(
              color: const Color(0x1A000000), // 10% 투명도의 검은색 (추가 그림자)
              offset: Offset(0, 2 * scale),
              blurRadius: 4 * scale,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '여행 계획 시작!',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24 * scale,
              color: const Color(0xFFFFFFFF),
              letterSpacing: 0,
              height: 30 / 24, // lineHeightPx / fontSize
            ),
          ),
        ),
      ),
    );
  }
}

class PreferenceOption {
  final String emoji;
  final String label;

  PreferenceOption(this.emoji, this.label);
}
