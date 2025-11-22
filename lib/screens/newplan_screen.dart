import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sw_project_fe/models/trip.dart';
import 'package:sw_project_fe/services/trip_api.dart';

class NewPlanScreen extends StatefulWidget {
  const NewPlanScreen({super.key});

  @override
  State<NewPlanScreen> createState() => _NewPlanScreenState();
}

class _NewPlanScreenState extends State<NewPlanScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _friendCodeController = TextEditingController();
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _tripNameController.dispose();
    _friendCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = (isStartDate ? _startDate : _endDate) ?? DateTime.now();
    final firstDate = isStartDate ? DateTime.now() : (_startDate ?? DateTime.now());
    final lastDate = DateTime(2101);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8282),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF8282),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }


  Future<void> _createRoom() async {
    if (_isLoading) return;
    if (_tripNameController.text.isEmpty || _startDate == null || _endDate == null) {
      _showSnackBar('여행 이름과 기간을 모두 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startDateStr = '''${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}''';
      final endDateStr = '''${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}''';

      final result = await TripService().createTrip(
        _tripNameController.text.trim(),
        startDateStr,
        endDateStr,
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      _showSnackBar('여행 생성에 실패했습니다: ${e.toString()}');
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
        Navigator.pop(context, true);
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
                    ElevatedButton(onPressed: _isLoading ? null : _createRoom, style: ElevatedButton.styleFrom(minimumSize: Size(251 * scale, 49 * scale), backgroundColor: const Color(0xFFFF8282), foregroundColor: Colors.white), child: const Text('여행 계획 시작!')),
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
          _buildDatePickerField(label: '여행 시작일', date: _startDate, onTap: () => _selectDate(context, true), scale: scale),
          SizedBox(height: 20 * scale),
          _buildDatePickerField(label: '여행 종료일', date: _endDate, onTap: () => _selectDate(context, false), scale: scale),
          SizedBox(height: 20 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildTextField(label: '친구의 방에 초대받기', controller: _friendCodeController, hint: '친구의 코드를 입력하세요.', scale: scale, isCode: true)),
              SizedBox(width: 8 * scale),
              ElevatedButton(onPressed: _isLoading ? null : _joinRoom, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8282), foregroundColor: Colors.white), child: const Text('참여')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({required String label, DateTime? date, required VoidCallback onTap, required double scale}) {
    final dateText = date == null ? '날짜를 선택하세요' : '''${date.year}년 ${date.month}월 ${date.day}일''';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w400)),
        SizedBox(height: 4 * scale),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.black54),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: TextStyle(fontSize: 16, color: date == null ? Colors.grey[600] : Colors.black),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, required double scale, bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w400)),
        SizedBox(height: 4 * scale),
        SizedBox(
          height: 58,
          child: TextField(
            controller: controller,
            inputFormatters: isCode ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')), LengthLimitingTextInputFormatter(8)] : [],
            decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: const BorderSide(color: Colors.black54)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: const BorderSide(color: Colors.black54))
            ),
          ),
        ),
      ],
    );
  }
}
