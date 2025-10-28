import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_navbar.dart';

class NewPlanScreen extends StatefulWidget {
  const NewPlanScreen({super.key});

  @override
  State<NewPlanScreen> createState() => _NewPlanScreenState();
}

class _NewPlanScreenState extends State<NewPlanScreen> {
  int _currentIndex = NavbarIndex.home;
  
  // 텍스트 컨트롤러들
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _friendCodeController = TextEditingController();

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _createRoom() {
    if (_tripNameController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
      // 방 생성 로직 - 메인 메뉴로 돌아가면서 방 생성 완료 모달 표시
      Navigator.pop(context, {
        'tripName': _tripNameController.text,
        'destination': _destinationController.text,
        'roomCode': _generateRoomCode(),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행이름과 여행지를 입력해주세요.'),
          backgroundColor: Color(0xFFFC5858),
        ),
      );
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  void _joinRoom() {
    if (_friendCodeController.text.isNotEmpty) {
      // 친구 방 참여 로직
      Navigator.pop(context); // 메인 메뉴로 돌아가기
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('친구의 코드를 입력해주세요.'),
          backgroundColor: Color(0xFFFC5858),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

     return Scaffold(
       backgroundColor: const Color(0xFFFFFCFC),
       body: GestureDetector(
         onTap: () {
           // 다른 부분을 클릭하면 키보드 숨기기
           FocusScope.of(context).unfocus();
         },
         child: SafeArea(
           child: Column(
          children: [
            // 상단 메뉴 아이콘
            Padding(
              padding: EdgeInsets.only(
                top: 62 * scale,
                left: 17 * scale,
                right: 17 * scale,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 24 * scale,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                ],
              ),
            ),

            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 50 * scale),
                      
                      // 제목
                      Text(
                        '여행 메이트를 초대하세요 ✈️',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28 * scale,
                          color: const Color(0xFF1A0802),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.25,
                        ),
                      ),
                      
                      SizedBox(height: 7 * scale),
                      
                      Text(
                        '같이 여행 계획하고 일정도 함께 만들어봐요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20 * scale,
                          color: const Color(0xFF1A0802),
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.25,
                        ),
                      ),
                      
                      SizedBox(height: 37 * scale),
                      
                      // 입력 폼 컨테이너
                      Container(
                        width: 326 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(25 * scale),
                          border: Border.all(
                            color: const Color(0xFF1A0802).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(25 * scale),
                          child: Column(
                            children: [
                              // 여행이름 입력
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '여행이름',
                                    style: TextStyle(
                                      fontSize: 20 * scale,
                                      color: const Color(0xFF1A0802),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Container(
                                    height: 56 * scale,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                    child: TextField(
                                      controller: _tripNameController,
                                      decoration: InputDecoration(
                                        hintText: '여행이름을 입력하세요.',
                                        hintStyle: TextStyle(
                                          fontSize: 16 * scale,
                                          color: const Color(0xFF5D6470),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.25,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10 * scale,
                                          vertical: 16 * scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 20 * scale),
                              
                              // 여행지 입력
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '여행지',
                                    style: TextStyle(
                                      fontSize: 20 * scale,
                                      color: const Color(0xFF1A0802),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Container(
                                    height: 57 * scale,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                    child: TextField(
                                      controller: _destinationController,
                                      decoration: InputDecoration(
                                        hintText: '여행지를 입력하세요.',
                                        hintStyle: TextStyle(
                                          fontSize: 16 * scale,
                                          color: const Color(0xFF5D6470),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.25,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10 * scale,
                                          vertical: 16 * scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 20 * scale),
                              
                              // 친구의 방에 초대받기
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '친구의 방에 초대받기',
                                    style: TextStyle(
                                      fontSize: 20 * scale,
                                      color: const Color(0xFF1A0802),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Container(
                                    height: 57 * scale,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                     child: TextField(
                                       controller: _friendCodeController,
                                       textCapitalization: TextCapitalization.characters,
                                       inputFormatters: [
                                         FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                                         LengthLimitingTextInputFormatter(8), // 최대 8자
                                       ],
                                       decoration: InputDecoration(
                                         hintText: '친구의 코드를 입력하세요.',
                                         hintStyle: TextStyle(
                                           fontSize: 16 * scale,
                                           color: const Color(0xFF5D6470),
                                           fontWeight: FontWeight.w400,
                                           letterSpacing: -0.25,
                                         ),
                                         border: InputBorder.none,
                                         contentPadding: EdgeInsets.symmetric(
                                           horizontal: 10 * scale,
                                           vertical: 16 * scale,
                                         ),
                                       ),
                                     ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 37 * scale),
                      
                      // 여행 계획 시작 버튼
                      GestureDetector(
                        onTap: _createRoom,
                        child: Container(
                          width: 251 * scale,
                          height: 49 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8282),
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
                                fontSize: 20 * scale,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
           ],
         ),
       ),
     ),
     );
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _friendCodeController.dispose();
    super.dispose();
  }
}
