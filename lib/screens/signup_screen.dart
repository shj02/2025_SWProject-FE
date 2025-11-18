// lib/screens/signup_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../services/user_service.dart';
import 'package:sw_project_fe/config/api_config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _nationController = TextEditingController();

  String _gender = '남자';
  bool _isSubmitting = false; // 가입 버튼 중복 클릭 방지 & 로딩 상태

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _nationController.dispose();
    super.dispose();
  }

  /// 🔥 회원가입 API 호출 + 화면 이동
  Future<void> _submit() async {
    if (_isSubmitting) return;

    // 폼 검증
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userService = UserService();

      // ✅ 로그인 때 저장해둔 JWT 꺼내기
      final jwt = userService.authToken;
      if (jwt == null) {
        debugPrint('❌ JWT 토큰이 없음. 먼저 로그인해야 합니다.');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 정보가 없습니다. 다시 로그인해 주세요.'),
          ),
        );
        return;
      }

      // --- 폼 값 정리 ---
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final birth = _birthController.text.trim();
      final nation = _nationController.text.trim();

      // ✅ 프론트 전용 UserService에도 함께 저장
      //   → 나중에 마이페이지에서 그대로 꺼내서 보여줌
      userService.setUserName(name);
      userService.setPhoneNumber(phone);
      userService.setBirthdate(birth);
      userService.setNationality(nation);

      // ✅ 아이디/이메일은 카카오에서 안 가져옴 → 기본값은 공백(null)
      userService.setAccountId(null);
      userService.setEmail(null);

      // ✅ 백엔드 "초기 프로필 입력" API 호출
      // UserController 기준: POST /api/users/me/profile/initial
      final url = Uri.parse('$baseUrl/api/users/me/profile/initial');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt', // 중요!!
        },
        body: jsonEncode({
          // ⚠️ ProfileUpdateRequest 자바 DTO의 필드명과 맞춰야 함
          'name': name,
          'phoneNumber': phone,
          'gender': _gender,
          'birthdate': birth,
          'nationality': nation,
        }),
      );

      debugPrint('⬇️ 회원가입 응답 코드: ${response.statusCode}');
      debugPrint('⬇️ 회원가입 응답 바디: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        // ✅ 초기 프로필 입력 성공 → 다음 단계(취향 선택)로 이동
        Navigator.pushReplacementNamed(context, '/preference');
      } else {
        // ❌ 백엔드에서 에러 코드 응답한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '회원가입에 실패했어요. 잠시 후 다시 시도해 주세요. (code: ${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('❌ 회원가입 통신 에러: $e');
      debugPrint('stackTrace: $st');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('네트워크 오류가 발생했어요. 다시 시도해 주세요.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _Header(),
                  const SizedBox(height: 24),
                  _LabeledField(
                    label: '이름',
                    child: TextFormField(
                      controller: _nameController,
                      autofocus: false,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        // 숫자 입력 방지
                        FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                      ],
                      decoration: _figmaInputDecoration('이름을 입력하세요.'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름은 필수입니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '전화번호',
                    child: TextFormField(
                      controller: _phoneController,
                      autofocus: false,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        PhoneNumberFormatter(),
                      ],
                      decoration:
                      _figmaInputDecoration("'-' 제외 숫자 11자리를 입력하세요."),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '전화번호는 필수입니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '성별',
                    child: Row(
                      children: [
                        Expanded(
                          child: _GenderButton(
                            label: '남자',
                            selected: _gender == '남자',
                            onTap: () => setState(() => _gender = '남자'),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _GenderButton(
                            label: '여자',
                            selected: _gender == '여자',
                            onTap: () => setState(() => _gender = '여자'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '생년월일',
                    child: TextFormField(
                      controller: _birthController,
                      autofocus: false,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        BirthDateFormatter(),
                      ],
                      decoration: _figmaInputDecoration("'-' 제외 생년월일 8자를 입력하세요."),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '생년월일은 필수입니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '국적',
                    child: TextFormField(
                      controller: _nationController,
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                      ],
                      decoration: _figmaInputDecoration('국적을 입력하세요.'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '국적은 필수입니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 326,
                      height: 64,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 51, vertical: 17),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8282),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(4, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSubmitting ? null : _submit,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: _isSubmitting
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              '가입하기',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 24,
                                color: Color(0xFFFFFFFF),
                                letterSpacing: 0,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text(
                      '다른 계정이 있으신가요? 로그인',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFC5858),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Join us',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 64,
          letterSpacing: 3.2,
          color: Color(0xFF1A0802),
          shadows: [
            Shadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Color(0xFF1A0802),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        height: 66,
        decoration: BoxDecoration(
          color:
          selected ? const Color(0x33FC5858) : const Color(0x33FDDFCC),
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: const Color(0xFF1A0802).withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Color(0xFF1A0802),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _figmaInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF5D6470),
      fontSize: 18,
    ),
    filled: true,
    fillColor: const Color(0x33FDDFCC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      BorderSide(color: const Color(0xFF000000).withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      BorderSide(color: const Color(0xFF000000).withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      BorderSide(color: const Color(0xFF1A0802).withOpacity(0.8)),
    ),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  );
}

// 전화번호 포맷터 (000-0000-0000)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final oldText = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 백스페이스로 삭제하는 경우
    if (newText.length < oldText.length) {
      return _formatPhoneNumber(newText);
    }

    // 최대 11자리까지만 허용
    if (newText.length > 11) {
      return oldValue;
    }

    return _formatPhoneNumber(newText);
  }

  TextEditingValue _formatPhoneNumber(String text) {
    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String formatted = text;
    int cursorPosition = text.length;

    if (text.length > 3) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
      cursorPosition++;
    }

    if (text.length > 7) {
      formatted =
      '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}';
      cursorPosition++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

// 생년월일 포맷터 (0000-00-00)
class BirthDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final oldText = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 백스페이스로 삭제하는 경우
    if (newText.length < oldText.length) {
      return _formatBirthDate(newText);
    }

    // 최대 8자리까지만 허용
    if (newText.length > 8) {
      return oldValue;
    }

    return _formatBirthDate(newText);
  }

  TextEditingValue _formatBirthDate(String text) {
    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String formatted = text;
    int cursorPosition = text.length;

    if (text.length > 4) {
      formatted = '${text.substring(0, 4)}-${text.substring(4)}';
      cursorPosition++;
    }

    if (text.length > 6) {
      formatted =
      '${text.substring(0, 4)}-${text.substring(4, 6)}-${text.substring(6)}';
      cursorPosition++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
