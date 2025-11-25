import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/sidebar.dart';
import 'newplan_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_checklist_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';
import '../models/trip_room.dart';
import '../services/trip_room_service.dart';
import '../services/trip_plan_state_service.dart';
import '../services/trip_plan_budget_state_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = NavbarIndex.home;
  late TripRoomService _tripRoomService;
  late TripPlanStateService _stateService;
  late TripPlanBudgetStateService _budgetStateService;
  bool _showRoomCreatedModal = false; // 방 생성 완료 모달 표시 여부

  // 사이드바 관련 상태
  bool _showSidebar = false;
  bool _showDeleteModal = false;
  String _selectedTripId = '';

  @override
  void initState() {
    super.initState();
    _tripRoomService = TripRoomService();
    _stateService = TripPlanStateService();
    _budgetStateService = TripPlanBudgetStateService();
    // 샘플 데이터가 없으면 초기화
    if (_tripRoomService.tripRooms.isEmpty) {
      _tripRoomService.initializeSampleData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때 현재 방 정보 업데이트
    if (_tripRoomService.currentTripRoom != null) {
      setState(() {});
    }
  }

  // 현재 방이 있는지 확인
  bool get _hasRoom => _tripRoomService.currentTripRoom != null;
  
  // 현재 방 정보
  TripRoom? get _currentRoom => _tripRoomService.currentTripRoom;

  // Room ID에서 안전하게 8자리 코드 추출
  // 이제 ID가 이미 대문자 8자리이므로 그대로 반환
  String _formatRoomCode(String? roomId) {
    if (roomId == null || roomId.isEmpty) return 'N/A';
    // ID가 이미 대문자 8자리이므로 그대로 반환
    return roomId.length >= 8 
        ? roomId.substring(0, 8).toUpperCase() 
        : roomId.toUpperCase();
  }

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // 네비게이션 로직 추가
    switch (index) {
      case 0: // Home
        // 현재 페이지가 홈이므로 아무 동작 안함
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
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MypageScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  void _showCreateRoomDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPlanScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      // 새로운 TripRoom 생성
      final newRoom = TripRoom(
        id: _tripRoomService.generateRoomId(), // 대문자 8자리 ID
        title: result['tripName'] ?? '제주도 우정여행',
        participantCount: 1,
        dDay: 'D-?', // 날짜 선택 전에는 D-?
        startDate: null,
        endDate: null,
        destination: result['destination'] ?? '제주도',
        participants: ['나'], // 초기에는 방 만든 사람만
        status: 'planning',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TripRoomService에 추가
      _tripRoomService.addTripRoom(newRoom);
      _tripRoomService.setCurrentTripRoom(newRoom);

      setState(() {
        _showRoomCreatedModal = true;
      });
    }
  }

  void _hideRoomCreatedModal() {
    setState(() {
      _showRoomCreatedModal = false;
    });
  }

  void _copyRoomCode() {
    final roomCode = _formatRoomCode(_currentRoom?.id);
    Clipboard.setData(ClipboardData(text: roomCode));
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
    _tripRoomService.deleteTripRoom(_selectedTripId);
    setState(() {
      _showDeleteModal = false;
      _selectedTripId = '';
    });
  }

  void _enterTripRoom(String tripId) {
    // 여행 방을 현재 방으로 설정
    _tripRoomService.setCurrentTripRoomById(tripId);
    setState(() {
      _hideSidebar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        bottomNavigationBar: (_showDeleteModal || _showRoomCreatedModal) ? null : CustomNavbar(
          currentIndex: _currentIndex,
          onTap: _onNavbarTap,
        ),
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
              ],
            ),

              // 방 생성 완료 모달
              if (_showRoomCreatedModal) _buildRoomCreatedModal(scale),

              // 사이드바
              if (_showSidebar)
                Sidebar(
                  scale: scale,
                  tripList: _tripRoomService.tripRooms.map((room) => {
                    'id': room.id,
                    'name': room.title,
                    'date': room.startDate != null
                        ? '${room.startDate!.month}/${room.startDate!.day}'
                        : '날짜 미정',
                    'participants': room.participantCount,
                    'code': _formatRoomCode(room.id),
                    'progress': room.status == 'completed' ? 100
                        : room.status == 'confirmed' ? 50
                        : 0,
                    'isOwner': room.participants.isNotEmpty && room.participants.first == '나',
                  }).toList(),
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
              SizedBox(height: 15 * scale),

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
                        color: const Color(0x40000000),
                        offset: Offset(4, 4 * scale),
                        blurRadius: 4 * scale,
                        blurStyle: BlurStyle.inner,
                      ),
                      BoxShadow(
                        color: const Color(0x1A000000),
                        offset: Offset(0, 2 * scale),
                        blurRadius: 4 * scale,
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

              // ⛔ 진행중인 계획 버튼 (비활성 + 색만 회색으로 변경)
              IgnorePointer(
                ignoring: true,
                child: Container(
                  width: 319 * scale,      // 크기 그대로 유지
                  height: 67 * scale,      // 크기 그대로 유지
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5), // 비활성 회색 배경
                    borderRadius: BorderRadius.circular(34 * scale),
                  ),
                  child: Center(
                    child: Text(
                      '진행중인 계획',
                      style: TextStyle(
                        fontSize: 32 * scale,
                        color: const Color(0xFFB3B3B3), // 비활성 회색 텍스트
                        fontWeight: FontWeight.w400,
                      ),
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
    final TripPlanStateService stateService = _stateService;
    final TripPlanBudgetStateService budgetService = _budgetStateService;
    final String roomId = _currentRoom?.id ?? '';
    final List<String> participants = _currentRoom?.participants ?? const [];

    if (roomId.isNotEmpty) {
      stateService.setScheduleDaysForRoom(
        roomId,
        stateService.scheduleDays.map((day) => day.id),
      );
    }

    final bool dateComplete = _currentRoom?.startDate != null;
    final bool candidatesComplete =
        roomId.isNotEmpty && stateService.hasMemberSuggestedPlace(roomId);
    final bool scheduleComplete =
        roomId.isNotEmpty && stateService.isScheduleComplete(roomId);
    final bool budgetComplete =
        roomId.isNotEmpty && stateService.isBudgetComplete(roomId, participants);
    final bool checklistComplete =
        roomId.isNotEmpty && stateService.isChecklistComplete(roomId);

    final List<bool> steps = [
      dateComplete,
      candidatesComplete,
      scheduleComplete,
      budgetComplete,
      checklistComplete,
    ];
    final int progressCount = steps.where((step) => step).length;
    final double progressRatio = progressCount / 5.0;

    String? nextRoute;
    String nextStepName;
    String buttonText;

    if (!dateComplete) {
      nextRoute = 'date';
      nextStepName = '날짜 정하기';
      buttonText = '날짜 정하러 가기';
    } else if (!candidatesComplete) {
      nextRoute = 'candidates';
      nextStepName = '후보지 정하기';
      buttonText = '후보지 정하러 가기';
    } else if (!scheduleComplete) {
      nextRoute = 'schedule';
      nextStepName = '일정표 짜기';
      buttonText = '일정표 짜러 가기';
    } else if (!budgetComplete) {
      nextRoute = 'budget';
      nextStepName = '예산 정하기';
      buttonText = '예산 정하러 가기';
    } else if (!checklistComplete) {
      nextRoute = 'checklist';
      nextStepName = '체크리스트 확인하기';
      buttonText = '체크리스트 확인하러 가기';
    } else {
      nextRoute = 'date';
      nextStepName = '모두 완료';
      buttonText = '계획 보러 가기';
    }
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
                              _currentRoom?.title ?? '여행방을 선택해주세요',
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
                              _currentRoom?.dDay ?? 'D-?',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: const Color(0xFF1A0802),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                                                          Text(
                               _currentRoom?.startDate != null
                                   ? '${_currentRoom!.startDate!.month}/${_currentRoom!.startDate!.day}'
                                   : '날짜 미정',
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

              SizedBox(height: 20 * scale),

              // 계획하러 가는 버튼
              GestureDetector(
                onTap: () {
                  Widget targetScreen;
                  switch (nextRoute) {
                    case 'candidates':
                      targetScreen = const TripPlanCandidatesScreen();
                      break;
                    case 'schedule':
                      targetScreen = const TripPlanScheduleScreen();
                      break;
                    case 'budget':
                      targetScreen = const TripPlanBudgetScreen();
                      break;
                    case 'checklist':
                      targetScreen = const TripPlanChecklistScreen();
                      break;
                    case 'date':
                    default:
                      targetScreen = const TripPlanDateScreen();
                      break;
                  }

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
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
                      buttonText,
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
                              '$progressCount/5 완료',
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
                            widthFactor: progressRatio.clamp(0.0, 1.0),
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
                          '${(progressRatio * 100).toInt()}% 완료',
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
                          '다음 단계: $nextStepName',
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
                            _formatRoomCode(_currentRoom?.id),
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
    final selectedRoom = _tripRoomService.tripRooms.firstWhere(
      (room) => room.id == _selectedTripId,
      orElse: () => TripRoom(
        id: '',
        title: '',
        participantCount: 0,
        dDay: 'D-?',
        destination: '',
        participants: [],
        status: 'planning',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 10 * scale),

                // 설명
                Text(
                  '"${selectedRoom.title}"이 완전히 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    color: const Color(0xFF1A0802),
                    fontWeight: FontWeight.w400,
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

  Future<bool> _handleWillPop() async {
    if (_showDeleteModal) {
      _hideDeleteTripModal();
      return false;
    }
    if (_showRoomCreatedModal) {
      _hideRoomCreatedModal();
      return false;
    }
    if (_showSidebar) {
      _hideSidebar();
      return false;
    }
    return false;
  }
}