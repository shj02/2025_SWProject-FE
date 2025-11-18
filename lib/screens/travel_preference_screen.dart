import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';      // ✅ baseUrl 정의된 파일
import '../services/user_service.dart';  // ✅ 로그인 때 저장한 토큰 / 유저정보

class TravelPreferenceScreen extends StatefulWidget {
  const TravelPreferenceScreen({super.key});

  @override
  State<TravelPreferenceScreen> createState() =>
      _TravelPreferenceScreenState();
}

class _TravelPreferenceScreenState extends State<TravelPreferenceScreen> {
  /// 선택된 여행 스타일 라벨들 (예: '액티비티', '힐링·휴양' 등)
  final Set<String> _selectedPreferences = {};

  /// 선택지 목록 (이모지 + 라벨)
  final List<PreferenceOption> _preferences = const [
    PreferenceOption('🎢', '액티비티'),
    PreferenceOption('🌴', '힐링·휴양'),
    PreferenceOption('🏛️', '문화 탐방'),
    PreferenceOption('🍜', '맛집 탐방'),
    PreferenceOption('🛍️', '쇼핑'),
    PreferenceOption('🏞️', '자연·풍경'),
    PreferenceOption('🌆', '도시 중심형'),
    PreferenceOption('🏘️', '로컬 중심형'),
    PreferenceOption('💎', '럭셔리'),
    PreferenceOption('💸', '실속·가성비'),
    PreferenceOption('🎒', '모험·백팩커'),
  ];

  void _togglePreference(String label) {
    setState(() {
      if (_selectedPreferences.contains(label)) {
        _selectedPreferences.remove(label);
      } else {
        _selectedPreferences.add(label);
      }
    });
  }

  /// 🔥 "여행 계획 시작!" 버튼 눌렀을 때
  /// 1. 최소 1개 선택했는지 체크
  /// 2. 백엔드에 /api/users/me/styles/complete 로 전달
  /// 3. 성공 시 메인 화면으로 이동 (다음 로그인부터는 registered=true가 되도록 백엔드에서 처리)
  Future<void> _onStartPressed() async {
    debugPrint('버튼이 눌렸습니다!');
    debugPrint('선택된 선호도: $_selectedPreferences');

    if (_selectedPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '최소 하나의 여행 스타일을 선택해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFFF8282),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.only(
            bottom: 140,
            right: 20,
            left: 20,
          ),
          duration: const Duration(seconds: 2),
          elevation: 6.0,
        ),
      );
      return;
    }

    final userService = UserService();
    final token = userService.authToken;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 정보가 없어요. 다시 로그인해 주세요.'),
          backgroundColor: Color(0xFFFF8282),
        ),
      );
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/api/users/me/styles/complete');

      final body = {
        'travelStyles': _selectedPreferences.toList(), // 백엔드 StyleUpdateRequest.travelStyles
      };

      debugPrint('➡️ 여행 스타일 저장 요청: POST $url');
      debugPrint('   body: $body');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ JWT 추가
        },
        body: jsonEncode(body),
      );

      debugPrint('⬇️ 스타일 완료 응답 코드: ${response.statusCode}');
      debugPrint('⬇️ 스타일 완료 응답 바디: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        // ✅ 성공 → 메인으로 이동
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '여행 스타일 저장에 실패했어요. (code: ${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('❌ 여행 스타일 저장 중 오류: $e');
      debugPrint('stackTrace: $st');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('네트워크 오류가 발생했어요. 다시 시도해 주세요.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                '당신의 여행 스타일을\n알려주세요',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A0802),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '선호하는 여행 타입을 골라주시면\n더 정확한 플랜을 추천해 드릴게요.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5D6470),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _preferences.length,
                  itemBuilder: (context, index) {
                    final option = _preferences[index];
                    final isSelected =
                    _selectedPreferences.contains(option.label);

                    return GestureDetector(
                      onTap: () => _togglePreference(option.label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFE1E1)
                              : const Color(0x33FDDFCC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8282)
                                : const Color(0x331A0802),
                            width: 1.2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              const BoxShadow(
                                color: Color(0x22000000),
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                option.label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A0802),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 326,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8282),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _onStartPressed,
                    child: const Text(
                      '여행 계획 시작!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ 여행 스타일 카드에 사용되는 간단한 모델 클래스
class PreferenceOption {
  final String emoji;
  final String label;

  const PreferenceOption(this.emoji, this.label);
}
