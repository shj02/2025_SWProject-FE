import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialId,
    this.initialName,
    this.initialPhone,
    this.initialBirth,
    this.initialNation,
  });

  final String? initialId;
  final String? initialName;
  final String? initialPhone;
  final String? initialBirth;
  final String? initialNation;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _nationController = TextEditingController();
  
  String? _profileImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 기존 사용자 정보로 초기화
    _idController.text = widget.initialId ?? 'user123';
    _nameController.text = widget.initialName ?? '홍길동';
    _phoneController.text = widget.initialPhone ?? '010-1234-5678';
    _birthController.text = widget.initialBirth ?? '1990-01-01';
    _nationController.text = widget.initialNation ?? '대한민국';
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _nationController.dispose();
    super.dispose();
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: 실제 API 호출로 데이터 저장
    await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('개인정보가 수정되었습니다.'),
        backgroundColor: Color(0xFFFC5858),
      ),
    );

    Navigator.pop(context, {
      'id': _idController.text.trim(),
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'birth': _birthController.text.trim(),
      'nation': _nationController.text.trim(),
      'profileImage': _profileImagePath,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A0802)),
        title: Text(
          '개인정보 수정',
          style: TextStyle(
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 17 * scale, vertical: 16 * scale),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40 * scale),
                        
                        // 아이디
                        _LabeledField(
                          label: '아이디',
                          scale: scale,
                          child: TextFormField(
                            controller: _idController,
                            autofocus: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            decoration: _whiteInputDecoration('아이디를 입력하세요.', scale),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '아이디는 필수입니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        
                        // 이름
                        _LabeledField(
                          label: '이름',
                          scale: scale,
                          child: TextFormField(
                            controller: _nameController,
                            autofocus: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            ],
                            decoration: _whiteInputDecoration('이름을 입력하세요.', scale),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '이름은 필수입니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        
                        // 전화번호
                        _LabeledField(
                          label: '전화번호',
                          scale: scale,
                          child: TextFormField(
                            controller: _phoneController,
                            autofocus: false,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              PhoneNumberFormatter(),
                            ],
                            decoration: _whiteInputDecoration("'-' 제외 숫자 11자리를 입력하세요.", scale),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '전화번호는 필수입니다';
                              }
                              final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                              if (digitsOnly.length != 11) {
                                return '전화번호는 11자리여야 합니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        
                        // 생년월일
                        _LabeledField(
                          label: '생년월일',
                          scale: scale,
                          child: TextFormField(
                            controller: _birthController,
                            autofocus: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              BirthDateFormatter(),
                            ],
                            decoration: _whiteInputDecoration("'-' 제외 생년월일 8자를 입력하세요.", scale),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '생년월일은 필수입니다';
                              }
                              final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                              if (digitsOnly.length != 8) {
                                return '생년월일은 8자리여야 합니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        
                        // 국적
                        _LabeledField(
                          label: '국적',
                          scale: scale,
                          child: TextFormField(
                            controller: _nationController,
                            autofocus: false,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            ],
                            decoration: _whiteInputDecoration('국적을 입력하세요.', scale),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '국적은 필수입니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 30 * scale),
                        
                        // 수정하기 버튼
                        Center(
                          child: Container(
                            width: 326 * scale,
                            height: 64 * scale,
                            padding: EdgeInsets.symmetric(horizontal: 51 * scale, vertical: 17 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8282),
                              borderRadius: BorderRadius.circular(12 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x40000000),
                                  offset: Offset(4 * scale, 4 * scale),
                                  blurRadius: 4 * scale,
                                  spreadRadius: 0,
                                  blurStyle: BlurStyle.inner,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _save,
                                borderRadius: BorderRadius.circular(12 * scale),
                                child: Center(
                                  child: Text(
                                    '수정하기',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 24 * scale,
                                      color: const Color(0xFFFFFFFF),
                                      letterSpacing: 0,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final double scale;

  const _LabeledField({
    required this.label,
    required this.child,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 2 * scale),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20 * scale,
              color: const Color(0xFF1A0802),
            ),
          ),
        ),
        child,
      ],
    );
  }
}


InputDecoration _whiteInputDecoration(String hintText, double scale) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: const Color(0xFF5D6470),
      fontSize: 18 * scale,
    ),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12 * scale),
      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12 * scale),
      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12 * scale),
      borderSide: BorderSide(color: const Color(0xFF1A0802).withOpacity(0.8)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 20 * scale),
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
    
    if (newText.length < oldText.length) {
      return _formatPhoneNumber(newText);
    }
    
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
    
    if (newText.length < oldText.length) {
      return _formatBirthDate(newText);
    }
    
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
