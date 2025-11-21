import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sw_project_fe/services/trip_api.dart';

class NewPlanScreen extends StatefulWidget {
  const NewPlanScreen({super.key});

  @override
  State<NewPlanScreen> createState() => _NewPlanScreenState();
}

class _NewPlanScreenState extends State<NewPlanScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _friendCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _friendCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_isLoading) return;
    if (_tripNameController.text.isEmpty || _destinationController.text.isEmpty) {
      _showSnackBar('여행이름과 여행지를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await TripService().createTrip(
        _tripNameController.text.trim(),
        _destinationController.text.trim(),
      );
      if (mounted) {
        // TODO: 생성된 방 정보를 이전 화면(main_menu)으로 전달해야 함
        _showSnackBar('새로운 여행 방이 생성되었습니다! (초대코드: ${result.inviteCode})', isError: false);
        Navigator.pop(context, true); // 성공했다는 의미로 true 전달
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    if (_isLoading) return;
    if (_friendCodeController.text.isEmpty) {
      _showSnackBar('친구의 코드를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await TripService().joinTrip(_friendCodeController.text.trim());
      if (mounted) {
        _showSnackBar('여행 방에 성공적으로 참여했습니다!', isError: false);
        Navigator.pop(context, true); // 성공했다는 의미로 true 전달
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 402.0;
    // UI 구조는 기존과 동일하게 유지
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(17 * scale, 62 * scale, 17 * scale, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios, size: 24 * scale))]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 17 * scale),
                child: Column(
                  children: [
                    SizedBox(height: 50 * scale),
                    Text('여행 메이트를 초대하세요 ✈️', textAlign: TextAlign.center, style: TextStyle(fontSize: 28 * scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 7 * scale),
                    Text('같이 여행 계획하고 일정도 함께 만들어봐요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20 * scale)),
                    SizedBox(height: 37 * scale),
                    _buildInputForm(scale),
                    SizedBox(height: 37 * scale),
                    ElevatedButton(onPressed: _isLoading ? null : _createRoom, style: ElevatedButton.styleFrom(minimumSize: Size(251 * scale, 49 * scale)), child: const Text('여행 계획 시작!')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(double scale) {
    return Container(
      width: 326 * scale,
      padding: EdgeInsets.all(25 * scale),
      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(25 * scale), border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.5))),
      child: Column(
        children: [
          _buildTextField(label: '여행이름', controller: _tripNameController, hint: '여행이름을 입력하세요.', scale: scale),
          SizedBox(height: 20 * scale),
          _buildTextField(label: '여행지', controller: _destinationController, hint: '여행지를 입력하세요.', scale: scale),
          SizedBox(height: 20 * scale),
          Row(
            children: [
              Expanded(child: _buildTextField(label: '친구의 방에 초대받기', controller: _friendCodeController, hint: '친구의 코드를 입력하세요.', scale: scale, isCode: true)),
              SizedBox(width: 8 * scale),
              Padding(
                padding: EdgeInsets.only(top: 24 * scale), // To align with the text field
                child: ElevatedButton(onPressed: _isLoading ? null : _joinRoom, child: const Text('참여')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, required double scale, bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w400)),
        SizedBox(height: 4 * scale),
        TextField(
          controller: controller,
          inputFormatters: isCode ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')), LengthLimitingTextInputFormatter(8)] : [],
          decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale))),
        ),
      ],
    );
  }
}
