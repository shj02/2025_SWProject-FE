import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/sidebar.dart';
import 'newplan_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = NavbarIndex.home;
  bool _hasRoom = false; // 방이 있는지 여부
  String _roomCode = 'SJDKSHDK'; // 생성된 방 코드
  String _tripName = '제주도 우정여행'; // 여행 이름
  String _destination = '제주도'; // 여행지
  bool _showRoomCreatedModal = false; // 방 생성 완료 모달 표시 여부
  
  // 사이드바 관련 상태
  bool _showSidebar = false;
  bool _showDeleteModal = false;
  String _selectedTripId = '';
  
  // 여행 목록 데이터
  List<Map<String, dynamic>> _tripList = [
    {
      'id': '1',
      'name': '제주도 우정 여행',
      'date': '날짜 미정',
      'participants': 3,
      'code': 'SJDKSHDK',
      'progress': 0,
      'isOwner': true,
    },
    {
      'id': '2',
      'name': '일본 가족 여행',
      'date': '12/22',
      'participants': 4,
      'code': 'SHEFGJCS',
      'progress': 20,
      'isOwner': false,
    },
    {
      'id': '3',
      'name': '스페인 배낭 여행',
      'date': '1/25',
      'participants': 2,
      'code': 'FJDOSOFJ',
      'progress': 100,
      'isOwner': true,
    },
  ];

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showCreateRoomDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPlanScreen()),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      // 새로운 여행을 목록에 추가
      final newTrip = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': result['tripName'] ?? '제주도 우정여행',
        'date': '날짜 미정',
        'participants': 1,
        'code': result['roomCode'] ?? 'SJDKSHDK',
        'progress': 0,
        'isOwner': true,
      };
      
      setState(() {
        _hasRoom = true;
        _tripName = result['tripName'] ?? '제주도 우정여행';
        _destination = result['destination'] ?? '제주도';
        _roomCode = result['roomCode'] ?? 'SJDKSHDK';
        _showRoomCreatedModal = true;
        
        // 새로운 여행을 목록 맨 앞에 추가
        _tripList.insert(0, newTrip);
      });
    }
  }

  void _createRoom() {
    // 새로운 여행을 목록에 추가
    final newTrip = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _tripName,
      'date': '날짜 미정',
      'participants': 1,
      'code': _roomCode,
      'progress': 0,
      'isOwner': true,
    };
    
    setState(() {
      _hasRoom = true;
      _showRoomCreatedModal = true;
      
      // 새로운 여행을 목록 맨 앞에 추가
      _tripList.insert(0, newTrip);
    });
  }

  void _hideRoomCreatedModal() {
    setState(() {
      _showRoomCreatedModal = false;
    });
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: _roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('방 코드가 복사되었습니다!'),
        backgroundColor: Color(0xFFFC5858),
      ),
    );
  }

  // 사이드바 관련 함수들
  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  void _hideSidebar() {
    setState(() {
      _showSidebar = false;
    });
  }

  void _showDeleteTripModal(String tripId) {
    setState(() {
      _selectedTripId = tripId;
      _showDeleteModal = true;
    });
  }

  void _hideDeleteTripModal() {
    setState(() {
      _showDeleteModal = false;
      _selectedTripId = '';
    });
  }

  void _deleteTrip() {
    setState(() {
      _tripList.removeWhere((trip) => trip['id'] == _selectedTripId);
      _showDeleteModal = false;
      _selectedTripId = '';
    });
  }

  void _enterTripRoom(String tripId) {
    // 여행 방으로 이동하는 로직
    // 나중에 백엔드 연동 시 구현
    print('여행 방 $tripId로 이동');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            Column(
              children: [
                // 상단 메뉴 아이콘
                Padding(
                  padding: EdgeInsets.only(
                    top: 34 * scale,
                    left: 17 * scale,
                    right: 17 * scale,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon 위젯을 Image.asset으로 변경합니다.
                      GestureDetector(
                        onTap: _toggleSidebar,
                        child: Image.asset(
                          'assets/icons/menu.png', // 이미지 경로
                          width: 35 * scale, // 아이콘과 동일한 너비
                          height: 35 * scale, // 아이콘과 동일한 높이
                        ),
                      ),
                    ],
                  ),
                ),

                // 메인 콘텐츠 영역
                Expanded(
                  child: _hasRoom ? _buildRoomExistsView(scale) : _buildNoRoomView(scale),
                ),

                // 네비게이션 바
                CustomNavbar(
                  currentIndex: _currentIndex,
                  onTap: _onNavbarTap,
                ),
              ],
            ),

            // 방 생성 완료 모달
            if (_showRoomCreatedModal) _buildRoomCreatedModal(scale),
            
            // 사이드바
            if (_showSidebar) Sidebar(
              scale: scale,
              tripList: _tripList,
              onHideSidebar: _hideSidebar,
              onCreateNewPlan: _showCreateRoomDialog,
              onEnterTripRoom: _enterTripRoom,
              onShowDeleteModal: _showDeleteTripModal,
            ),
            
            // 여행 삭제 모달
            if (_showDeleteModal) _buildDeleteTripModal(scale),
          ],
        ),
      ),
    );
  }

  // 방이 없을 때의 뷰 (4번 프레임)
  Widget _buildNoRoomView(double scale) {
    return Stack(
      children: [
        // 장식용 원들
        Positioned(
          left: 10 * scale,
          top: 140 * scale,
          child: Image.asset(
            'assets/icons/ellipse3.png',
            width: 331 * scale,
            height: 267 * scale,
          ),
        ),

        // 메인 콘텐츠
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 17 * scale),
          child: Column(
            children: [
              SizedBox(height: 15* scale),
              
              // "뭐하지..?" 텍스트
              Text(
                '뭐하지..?',
                style: TextStyle(
                  fontSize: 38 * scale,
                  color: const Color(0xFF1A0802),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4,
                ),
              ),
              
              SizedBox(height: 65 * scale),
              
              // 마스코트 이미지 (rumisad.png)
              Image.asset(
                'assets/icons/rumisad.png',
                width: 179 * scale,
                height: 257 * scale,
                fit: BoxFit.contain,
              ),
              
              SizedBox(height: 50 * scale),
              
              // 계획 세우기 버튼
              GestureDetector(
                onTap: _showCreateRoomDialog,
                child: Container(
                  width: 319 * scale,
                  height: 68 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8282),
                    borderRadius: BorderRadius.circular(34 * scale),
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
                      '계획 세우기 !',
                      style: TextStyle(
                        fontSize: 32 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16 * scale),
              
              // 진행중인 계획 버튼 (비활성화)
              Container(
                width: 319 * scale,
                height: 67 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8282),
                  borderRadius: BorderRadius.circular(34 * scale),
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
                    '진행중인 계획',
                    style: TextStyle(
                      fontSize: 32 * scale,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 방이 있을 때의 뷰 (4-1번 프레임)
  Widget _buildRoomExistsView(double scale) {
    return Stack(
      children: [
        // 장식용 원들
        Positioned(
          left: 35 * scale,
          top: 115 * scale,
          child: Image.asset(
            'assets/icons/ellipse4.png',
            width: 331 * scale,
            height: 320 * scale,
          ),
        ),

        // 메인 콘텐츠
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 17 * scale),
          child: Column(
            children: [
              SizedBox(height: 13 * scale),
              
              // 여행 정보 카드
              Container(
                width: 369 * scale,
                height: 97 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: const Color(0xFF1A0802).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _tripName,
                              style: TextStyle(
                                fontSize: 22 * scale,
                                color: const Color(0xFF1A0802),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 93 * scale,
                        height: 70 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50 * scale),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'D-?',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: const Color(0xFF1A0802),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '날짜 미정',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: const Color(0xFF1A0802),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 50 * scale),

              // 마스코트 이미지 (rumi.png)
              Image.asset(
                'assets/icons/rumi.png',
                width: 265 * scale,
                height: 257 * scale,
                fit: BoxFit.contain,
              ),


              SizedBox(height: 32 * scale),
              
              // 계획하러 가는 버튼
              GestureDetector(
                onTap: () {
                  // 날짜 선택 페이지로 이동
                },
                child: Container(
                  width: 301 * scale,
                  height: 49 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8282),
                    borderRadius: BorderRadius.circular(30 * scale),
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
                      '날짜 선택하러 가기',
                      style: TextStyle(
                        fontSize: 24 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20 * scale),
              
              // 여행 계획 진행률 카드
              Container(
                width: 369 * scale,
                height: 142 * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: const Color(0xFF1A0802),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '여행 계획 진행률',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              color: const Color(0xFF1A0802),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * scale,
                              vertical: 3 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7 * scale),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              '0/5 완료',
                              style: TextStyle(
                                fontSize: 13 * scale,
                                color: const Color(0xFF1A0802),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * scale),
                      // Stack을 사용하여 배경과 진행률 바를 겹치도록 수정
                      Stack(
                        children: [
                          // 1. 배경 바
                          Container(
                            height: 15 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F3F8),
                              borderRadius: BorderRadius.circular(4 * scale),
                              border: Border.all(
                                color: const Color(0xFF979797).withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          // 2. 실제 진행률을 나타내는 바
                          FractionallySizedBox(
                            widthFactor: 0.01, // 0% 완료 (나중에 동적으로 변경될 값)
                            child: Container(
                              height: 15 * scale, // 배경과 동일한 높이
                              decoration: BoxDecoration(
                                color: const Color(0xFFFC5858),
                                borderRadius: BorderRadius.circular(4 * scale),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      Center(
                        child: Text(
                          '0% 완료',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: const Color(0xFF1A0802),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Center(
                        child: Text(
                          '다음 단계: 날짜 정하기',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A0802),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // 방 생성 완료 모달 (5-1번 프레임)
  Widget _buildRoomCreatedModal(double scale) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 366 * scale,
          height: 280 * scale,
          margin: EdgeInsets.symmetric(horizontal: 18 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCFC),
            borderRadius: BorderRadius.circular(25 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.all(20 * scale),
            child: Column(
              children: [
                SizedBox(height: 12 * scale),
                
                // 제목
                Text(
                  '여행 방이 생성되었습니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24 * scale,
                    color: const Color(0xFF1A0802),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: 13 * scale),
                
                // 설명
                Text(
                  '친구에게 아래 초대코드를 보내 같이\n 여행 계획을 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    color: const Color(0xFF1A0802),
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                
                SizedBox(height: 18 * scale),
                
                // 방 코드
                Container(
                  height: 57 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: const Color(0xFF1A0802).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _roomCode,
                            style: TextStyle(
                              fontSize: 20 * scale,
                              color: const Color(0xFF1A0802),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _copyRoomCode,
                          child: Image.asset(
                            'assets/icons/copy.png',
                            width: 24 * scale,
                            height: 24 * scale,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 19 * scale),
                
                // 시작하기 버튼
                GestureDetector(
                  onTap: _hideRoomCreatedModal,
                  child: Container(
                    width: 245 * scale,
                    height: 43 * scale,
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
                        '시작하기',
                        style: TextStyle(
                          fontSize: 20 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
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
    );
  }


  // 여행 삭제 모달 (피그마 6-1번 프레임)
  Widget _buildDeleteTripModal(double scale) {
    final selectedTrip = _tripList.firstWhere(
      (trip) => trip['id'] == _selectedTripId,
      orElse: () => {'name': ''},
    );
    
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 366 * scale,
          height: 210 * scale,
          margin: EdgeInsets.symmetric(horizontal: 18 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCFC),
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.all(21 * scale),
            child: Column(
              children: [
                SizedBox(height: 12 * scale),
                
                // 제목
                Text(
                  '여행 방을 삭제하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26 * scale,
                    color: const Color(0xFF1A0802),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Jua',
                  ),
                ),
                
                SizedBox(height: 10 * scale),
                
                // 설명
                Text(
                  '"${selectedTrip['name']}"이 완전히 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    color: const Color(0xFF1A0802),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Jua',
                    height: 1.1,
                  ),
                ),
                
                SizedBox(height: 20 * scale),
                
                // 버튼들
                Row(
                  children: [
                    // 삭제 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: _deleteTrip,
                        child: Container(
                          height: 43 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8282),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Center(
                            child: Text(
                              '삭제',
                              style: TextStyle(
                                fontSize: 20 * scale,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Jua',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 9 * scale),
                    
                    // 돌아가기 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: _hideDeleteTripModal,
                        child: Container(
                          height: 43 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8282),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Center(
                            child: Text(
                              '돌아가기',
                              style: TextStyle(
                                fontSize: 20 * scale,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Jua',
                              ),
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

