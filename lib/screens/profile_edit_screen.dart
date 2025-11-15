import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import 'login_screen.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'community_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  int currentNavbarIndex = NavbarIndex.profile; // Profile 탭이 선택된 상태
  String _name = '홍길동';
  String _phone = '010-1234-5678';
  DateTime? _birthday = DateTime(1998, 1, 1);
  String _nation = '대한민국';

  static const String _jsonText = '{\n\n  "mcpServers": {\n\n    "TalkToFigma": {\n\n      "command": "bunx",\n\n      "args": [\n\n        "cursor-talk-to-figma-mcp@latest"\n\n      ]\n\n    }\n\n  }\n\n}';

  Future<void> _changeName() async {
    final controller = TextEditingController(text: _name);
    final String? result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('이름 변경'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '이름 입력'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('저장')),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _name = result);
    }
  }

  Future<void> _changePhone() async {
    final controller = TextEditingController(text: _phone);
    final String? result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('전화번호 변경'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '예: 010-1234-5678'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('저장')),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _phone = result);
    }
  }

  Future<void> _changeBirthday() async {
    final DateTime initial = _birthday ?? DateTime(2000, 1, 1);
    final DateTime first = DateTime(1900, 1, 1);
    final DateTime last = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  Future<void> _changeNation() async {
    final List<String> nations = <String>[
      '대한민국', '미국', '일본', '중국', '영국', '프랑스', '독일', '캐나다', '호주', '스페인'
    ];
    final String? chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            itemCount: nations.length,
            itemBuilder: (_, i) {
              final n = nations[i];
              return ListTile(
                title: Text(n),
                trailing: n == _nation ? const Icon(Icons.check, color: Color(0xFFFC5858)) : null,
                onTap: () => Navigator.pop(ctx, n),
              );
            },
          ),
        );
      },
    );
    if (chosen != null) setState(() => _nation = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    String birthdayText() {
      if (_birthday == null) return '설정 안 됨';
      final two = (int n) => n.toString().padLeft(2, '0');
      return '${_birthday!.year}-${two(_birthday!.month)}-${two(_birthday!.day)}';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      bottomNavigationBar: CustomNavbar(
        currentIndex: currentNavbarIndex,
        onTap: (index) {
          setState(() {
            currentNavbarIndex = index;
          });
          // 네비게이션 로직
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              break;
            case 1: // TripPlan
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const TripPlanDateScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              break;
            case 2: // Community
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const CommunityScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              break;
            case 3: // Profile
              // 현재 페이지가 Profile이므로 아무 동작 안함
              break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A0802)),
        title: Text(
          '프로필 편집',
          style: TextStyle(
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '.cursor/mcp.json',
                style: TextStyle(
                  fontSize: 16 * scale,
                  color: const Color(0xFF1A0802),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10 * scale),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.2), width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12 * scale),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _jsonText,
                      style: TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 14 * scale,
                        color: const Color(0xFF1A0802),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16 * scale),
              _buildRow('이름', _name, '변경', _changeName, scale),
              _buildRow('전화번호', _phone, '변경', _changePhone, scale),
              _buildRow('생년월일', birthdayText(), '변경', _changeBirthday, scale),
              _buildRow('국적', _nation, '변경', _changeNation, scale),
              SizedBox(height: 16 * scale),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8282),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                ),
                onPressed: _onLogoutPressed,
                child: Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.white, fontSize: 16 * scale, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, String action, VoidCallback onTap, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14 * scale, color: const Color(0xFF1A0802).withOpacity(0.7))),
                  SizedBox(height: 4 * scale),
                  Text(value, style: TextStyle(fontSize: 16 * scale, color: const Color(0xFF1A0802), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            TextButton(onPressed: onTap, child: Text(action)),
          ],
        ),
      ),
    );
  }

  Future<void> _onLogoutPressed() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final Size screenSize = MediaQuery.of(ctx).size;
        const double designWidth = 402.0;
        final double scale = screenSize.width / designWidth;
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCFC),
          title: const Text('로그아웃 하시겠습니까?'),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.2), width: 1),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _jsonText,
                style: TextStyle(fontFamily: 'Courier New', fontSize: 12 * scale, color: const Color(0xFF1A0802)),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
          ],
        );
      },
    );

    if (ok == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}


