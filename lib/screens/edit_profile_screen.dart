import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sw_project_fe/services/auth_api.dart';

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _idController.text = widget.initialId ?? '';
    _nameController.text = widget.initialName ?? '';
    _phoneController.text = widget.initialPhone ?? '';
    _birthController.text = widget.initialBirth ?? '';
    _nationController.text = widget.initialNation ?? '';
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
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final profileData = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'birthdate': _birthController.text.trim(),
        'nationality': _nationController.text.trim(),
      };

      await AuthService().updateProfile(profileData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보가 수정되었습니다.')),
      );
      Navigator.pop(context, true); // 성공 시 true와 함께 화면 닫기

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 수정에 실패했습니다: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 402.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A0802)),
        title: Text('개인정보 수정', style: TextStyle(color: const Color(0xFF1A0802), fontWeight: FontWeight.w600, fontSize: 18 * scale)),
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
                        _LabeledField(label: '아이디', scale: scale, child: TextFormField(controller: _idController, decoration: _whiteInputDecoration('아이디', scale), readOnly: true)),
                        SizedBox(height: 10 * scale),
                        _LabeledField(label: '이름', scale: scale, child: TextFormField(controller: _nameController, decoration: _whiteInputDecoration('이름', scale), validator: (v) => (v?.isEmpty ?? true) ? '이름을 입력하세요.' : null)),
                        SizedBox(height: 10 * scale),
                        _LabeledField(label: '전화번호', scale: scale, child: TextFormField(controller: _phoneController, decoration: _whiteInputDecoration('전화번호', scale), keyboardType: TextInputType.phone, inputFormatters: [PhoneNumberFormatter()], validator: (v) => (v?.isEmpty ?? true) ? '전화번호를 입력하세요.' : null)),
                        SizedBox(height: 10 * scale),
                        _LabeledField(label: '생년월일', scale: scale, child: TextFormField(controller: _birthController, decoration: _whiteInputDecoration('생년월일', scale), keyboardType: TextInputType.datetime, inputFormatters: [BirthDateFormatter()], validator: (v) => (v?.isEmpty ?? true) ? '생년월일을 입력하세요.' : null)),
                        SizedBox(height: 10 * scale),
                        _LabeledField(label: '국적', scale: scale, child: TextFormField(controller: _nationController, decoration: _whiteInputDecoration('국적', scale), validator: (v) => (v?.isEmpty ?? true) ? '국적을 입력하세요.' : null)),
                        SizedBox(height: 30 * scale),
                        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8282), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16 * scale)), child: Text('수정하기', style: TextStyle(fontSize: 24 * scale))),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ... Helper widgets and formatters (LabeledField, etc.) remain the same
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final double scale;
  const _LabeledField({required this.label, required this.child, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(bottom: 2 * scale), child: Text(label, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20 * scale, color: const Color(0xFF1A0802)))),
        child,
      ],
    );
  }
}

InputDecoration _whiteInputDecoration(String hintText, double scale) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: const Color(0xFF5D6470), fontSize: 18 * scale),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: const Color(0xFF1A0802).withOpacity(0.8))),
    contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 20 * scale),
  );
}

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
