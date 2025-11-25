import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sw_project_fe/services/auth_api.dart';

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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _nationController.dispose();
    super.dispose();
  }

  /// 회원가입 버튼 클릭 시 실행되는 함수
  Future<void> _submit() async {
    // 폼 검증
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // API로 보낼 데이터 맵 생성
      final profileData = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'gender': _gender,
        'birthdate': _birthController.text.trim(),
        'nationality': _nationController.text.trim(),
      };

      // AuthService를 통해 회원가입 요청
      await AuthService().signUp(profileData);

      if (!mounted) return;

      // 성공 시 다음 화면으로 이동
      Navigator.pushReplacementNamed(context, '/preference');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입에 실패했습니다: ${e.toString()}')),
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
                  const _Header(),
                  const SizedBox(height: 24),
                  _LabeledField(
                    label: '이름',
                    child: TextFormField(
                      controller: _nameController,
                      validator: (value) => (value?.trim().isEmpty ?? true) ? '이름은 필수입니다' : null,
                      decoration: _figmaInputDecoration('이름을 입력하세요.'),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '전화번호',
                    child: TextFormField(
                      controller: _phoneController,
                      validator: (value) => (value?.trim().isEmpty ?? true) ? '전화번호는 필수입니다' : null,
                      decoration: _figmaInputDecoration("'-' 제외 숫자 11자리를 입력하세요."),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '성별',
                    child: Row(
                      children: [
                        Expanded(child: _GenderButton(label: '남자', selected: _gender == '남자', onTap: () => setState(() => _gender = '남자'))),
                        const SizedBox(width: 9),
                        Expanded(child: _GenderButton(label: '여자', selected: _gender == '여자', onTap: () => setState(() => _gender = '여자'))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '생년월일',
                    child: TextFormField(
                      controller: _birthController,
                      validator: (value) => (value?.trim().isEmpty ?? true) ? '생년월일은 필수입니다' : null,
                      decoration: _figmaInputDecoration("'-' 제외 생년월일 8자를 입력하세요."),
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [BirthDateFormatter()],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: '국적',
                    child: TextFormField(
                      controller: _nationController,
                      validator: (value) => (value?.trim().isEmpty ?? true) ? '국적은 필수입니다' : null,
                      decoration: _figmaInputDecoration('국적을 입력하세요.'),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SubmitButton(onTap: _submit, isSubmitting: _isSubmitting),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                    child: const Text('다른 계정이 있으신가요? 로그인', style: TextStyle(fontSize: 16, color: Color(0xFFFC5858))),
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

// 나머지 위젯들은 이전과 동일 (Header, LabeledField, GenderButton, etc.)

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Join us', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 64, letterSpacing: 3.2, color: Color(0xFF1A0802), shadows: [Shadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)])),
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
        Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20, color: Color(0xFF1A0802)))),
        child,
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({required this.label, required this.selected, required this.onTap});
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
        decoration: BoxDecoration(color: selected ? const Color(0x33FC5858) : const Color(0x33FDDFCC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.5))),
        child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20, color: Color(0xFF1A0802)))),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onTap, required this.isSubmitting});
  final VoidCallback onTap;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF8282),
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: InkWell(
        onTap: isSubmitting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 326,
          height: 64,
          alignment: Alignment.center,
          child: isSubmitting
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('가입하기', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24, color: Colors.white)),
        ),
      ),
    );
  }
}

InputDecoration _figmaInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF5D6470), fontSize: 18),
    filled: true,
    fillColor: const Color(0x33FDDFCC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF1A0802).withOpacity(0.8))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  );
}

// 전화번호 포맷터
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 11) return oldValue;
    String formatted = newText;
    if (newText.length > 7) {
      formatted = '${newText.substring(0, 3)}-${newText.substring(3, 7)}-${newText.substring(7)}';
    } else if (newText.length > 3) {
      formatted = '${newText.substring(0, 3)}-${newText.substring(3)}';
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

// 생년월일 포맷터
class BirthDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 8) return oldValue;
    String formatted = newText;
    if (newText.length > 6) {
      formatted = '${newText.substring(0, 4)}-${newText.substring(4, 6)}-${newText.substring(6)}';
    } else if (newText.length > 4) {
      formatted = '${newText.substring(0, 4)}-${newText.substring(4)}';
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
