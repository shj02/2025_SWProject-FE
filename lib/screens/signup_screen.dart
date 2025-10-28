import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _nationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // 회원가입 성공 후 여행 취향 선택 화면으로 이동
      Navigator.pushNamed(context, '/preference');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                       FilteringTextInputFormatter.deny(RegExp(r'[0-9]')), // 숫자만 제외
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
                     decoration: _figmaInputDecoration("'-' 제외 숫자 11자리를 입력하세요."),
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
                       FilteringTextInputFormatter.deny(RegExp(r'[0-9]')), // 숫자만 제외
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
                    padding: const EdgeInsets.symmetric(horizontal: 51, vertical: 17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8282),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000), // 25% 투명도의 검은색
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
                        onTap: _submit,
                        borderRadius: BorderRadius.circular(12),
                        child: const Center(
                          child: Text(
                            '가입하기',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              color: Color(0xFFFFFFFF),
                              letterSpacing: 0,
                              height: 1.25, // lineHeightPx 30 / fontSize 24 = 1.25
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
                  child: Text(
                    '다른 계정이 있으신가요? 로그인',
                    style: TextStyle(fontSize: 16, color: Color(0xFFFC5858)),
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
          color: selected ? const Color(0x33FC5858) : const Color(0x33FDDFCC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.5)),
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
      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color(0xFF1A0802).withOpacity(0.8)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
    
    // 백스페이스로 삭제하는 경우 처리
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
      formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}';
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
    
    // 백스페이스로 삭제하는 경우 처리
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
      formatted = '${text.substring(0, 4)}-${text.substring(4, 6)}-${text.substring(6)}';
      cursorPosition++;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

