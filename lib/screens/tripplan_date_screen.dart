import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trip_room.dart';
import '../services/trip_plan_state_service.dart';
import '../services/trip_room_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/top_tab.dart';
import 'main_menu_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_checklist_screen.dart';

class TripPlanDateScreen extends StatefulWidget {
  const TripPlanDateScreen({Key? key}) : super(key: key);

  @override
  State<TripPlanDateScreen> createState() => _TripPlanDateScreenState();
}

class _TripPlanDateScreenState extends State<TripPlanDateScreen> {
  int currentNavbarIndex = 1; // TripPlan 탭이 선택된 상태
  int selectedSubTabIndex = 0; // 날짜 탭이 기본 선택
  late final List<DateTimeRange> selectedDateRanges; // 여러 날짜 기간 저장
  late TripRoomService _tripRoomService;
  late TripPlanStateService _stateService;
  TripRoom? _currentTripRoom;
  bool _showDateConfirmModal = false; // 7-2 모달 표시 여부
  Map<String, dynamic>? _selectedRecommendedDate; // 선택된 AI 추천 날짜
  bool _isDateConfirmed = false; // 날짜 확정 여부 (7-3 화면 표시용)
  late final List<Map<String, dynamic>> recommendedDates;

  List<Map<String, dynamic>> get members {
    if (_currentTripRoom == null) return [];

    final userService = UserService();
    final currentUserName = userService.userName ?? '나';

    return _currentTripRoom!.participants.map((participant) {
      // 현재 사용자인 경우 선택한 날짜 범위를 기간 형식으로 변환
      List<String> availableDates = [];
      if (participant == currentUserName || participant == '나') {
        // 선택한 날짜 범위를 기간 형식으로 변환 (예: "11/11 - 11/15")
        availableDates = selectedDateRanges.map((range) {
          final startMonth = range.start.month;
          final startDay = range.start.day;
          final endMonth = range.end.month;
          final endDay = range.end.day;
          return '$startMonth/$startDay - $endMonth/$endDay';
        }).toList();
      } else {
        // 다른 멤버는 샘플 데이터 사용 (실제로는 각 멤버별로 관리되어야 함)
        availableDates = ['11/11 - 11/13'];
      }

      return {
        'name': participant == '나' ? currentUserName : participant,
        'availableDates': availableDates,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tripRoomService = TripRoomService();
    _stateService = TripPlanStateService();
    selectedDateRanges = _stateService.selectedDateRanges;
    recommendedDates = _stateService.recommendedDates;
    _showDateConfirmModal = _stateService.showDateConfirmModal;
    _selectedRecommendedDate = _stateService.selectedRecommendedDate;
    _isDateConfirmed = _stateService.isDateConfirmed;
    // 샘플 데이터는 MainMenuScreen에서만 초기화 (백엔드 연동 전 테스트용)
    // 여기서는 자동 생성하지 않음
    _currentTripRoom = _tripRoomService.currentTripRoom;

    // D-Day 업데이트
    if (_currentTripRoom != null) {
      _tripRoomService.updateDDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    // 계획중인 여행이 없을 때 빈 화면 표시
    if (_tripRoomService.tripRooms.isEmpty || _currentTripRoom == null) {
      return WillPopScope(
        onWillPop: _handleWillPop,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: const Color(0xFFFFF5F5),
            systemNavigationBarColor: const Color(0xFFFFFCFC),
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFCFC),
            bottomNavigationBar: _showDateConfirmModal ? null : CustomNavbar(
              currentIndex: currentNavbarIndex,
              onTap: (index) {
                setState(() {
                  currentNavbarIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    break;
                  case 1:
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const CommunityScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    break;
                  case 3:
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
              },
            ),
            body: SafeArea(
              child: Center(
                child: Text(
                  '계획중인 여행이 없습니다.',
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A0802),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 7-3 화면이 표시되면 기존 요소들을 모두 숨기고 7-3만 표시
    if (_isDateConfirmed) {
      return WillPopScope(
        onWillPop: _handleWillPop,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: const Color(0xFFFFF5F5),
            systemNavigationBarColor: const Color(0xFFFFFCFC),
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFCFC),
            bottomNavigationBar: _showDateConfirmModal ? null : CustomNavbar(
              currentIndex: currentNavbarIndex,
              onTap: (index) {
                setState(() {
                  currentNavbarIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    break;
                  case 1:
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const CommunityScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    break;
                  case 3:
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
              },
            ),
            body: SafeArea(
              child: _buildDateConfirmedView(scale),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: const Color(0xFFFFF5F5),
            systemNavigationBarColor: const Color(0xFFFFFCFC),
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFCFC),
            bottomNavigationBar: _showDateConfirmModal ? null : CustomNavbar(
              currentIndex: currentNavbarIndex,
              onTap: (index) {
                setState(() {
                  currentNavbarIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    break;
                  case 1:
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const CommunityScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    break;
                  case 3:
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
              },
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _showTripRoomSelector,
                        child: TopTab(
                          title: _currentTripRoom?.title ?? "여행방을 선택해주세요",
                          participantCount: _currentTripRoom?.participantCount ?? 0,
                          dDay: _currentTripRoom?.dDay ?? "D-?",
                        ),
                      ),
                      TabNavigation(
                        selectedIndex: selectedSubTabIndex,
                        onTap: (index) {
                          setState(() {
                            selectedSubTabIndex = index;
                          });
                          _navigateToSubTab(index);
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            child: Column(
                              children: [
                                const SizedBox(height: 14),
                                _buildAddMyDateSection(),
                                const SizedBox(height: 14),
                                _buildRecommendedDatesSection(),
                                const SizedBox(height: 14),
                                _buildMemberDatesSection(),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showDateConfirmModal) _buildDateConfirmModal(scale),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildAddMyDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x801A0802)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 24,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              const Text(
                '내 가능 날짜 추가',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDFD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/calendar_add.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedDateRanges.isEmpty ? '캘린더에서 날짜 선택' : '${selectedDateRanges.length}개의 날짜 기간 선택됨',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 선택된 날짜 범위들 표시
          if (selectedDateRanges.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...selectedDateRanges.asMap().entries.map((entry) {
              int index = entry.key;
              DateTimeRange range = entry.value;
              String dateText = '${range.start.month}/${range.start.day} - ${range.end.month}/${range.end.day}';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF8A6A6)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateRanges.removeAt(index);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFFF8A6A6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendedDatesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x801A0802)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/Date_range.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text(
                'AI 추천 날짜',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...recommendedDates.map((date) => _buildDateOption(date)),
        ],
      ),
    );
  }

  Widget _buildDateOption(Map<String, dynamic> date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date['dateRange'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${date['availableMembers']}명 가능',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFFC5858)),
                      ),
                      child: Text(
                        '${date['matchRate']}% 매치',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _isRoomOwner() ? () {
              setState(() {
                for (var d in recommendedDates) {
                  d['isSelected'] = false;
                }
                date['isSelected'] = true;
                _selectedRecommendedDate = date;
                _stateService.selectedRecommendedDate = date;
                _showDateConfirmModal = true; // 7-2 모달 표시
                _stateService.showDateConfirmModal = true;
              });
            } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _isRoomOwner()
                    ? const Color(0xFFFF8282)
                    : const Color(0xFFD9D9D9), // 방장이 아닌 경우 회색
                borderRadius: BorderRadius.circular(5),
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
              child: Text(
                '선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isRoomOwner() ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberDatesSection() {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: const Color(0xFF1A0802),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/group2.png',
                width: 24 * scale,
                height: 24 * scale,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 7 * scale),
              Text(
                '멤버별 가능 날짜',
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A0802),
                  height: 22.5 / 20,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          ...members.map((member) => _buildMemberDateItem(member, scale)),
        ],
      ),
    );
  }

  Widget _buildMemberDateItem(Map<String, dynamic> member, double scale) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 11 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6 * scale),
        // 왼쪽에만 Border를 추가합니다.
        border: const Border(
          left: BorderSide(
            color: Color(0xFF1A0802),
            width: 3.0, // 두께 3
          ),
        ),
      ),
      child: Stack(
        children: [
          // 내용
          Padding(
            padding: EdgeInsets.only(
              left: 17 * scale,
              top: 8 * scale,
              right: 17 * scale,
              bottom: 11 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member['name'],
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A0802),
                    height: 20 / 16,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Wrap(
                  spacing: 3 * scale, // 태그 간 간격
                  runSpacing: 8 * scale,
                  children: (member['availableDates'] as List<String>).map((date) {
                    return Container(
                      width: 90 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 2 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6 * scale),
                        border: Border.all(
                          color: const Color(0xFFFC5858),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A0802),
                            height: 13.2 / 11,
                            letterSpacing: 0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8282), // 선택된 날짜 동그라미 색상
              onPrimary: Colors.white,   // 선택된 날짜의 글자색
              secondary: Color(0xFFFFC9C9), // 활성화된 버튼 등의 색상
              primaryContainer: Color(0xFFF8A6A6), // 날짜 기간(범위)의 배경색
              onSurface: Colors.black,   // 캘린더의 일반 글자색
            ),
            dialogBackgroundColor: Color(0xFFFFF5F5), // 다이얼로그 배경색
            scaffoldBackgroundColor: Color(0xFFFFF5F5), // 스캐폴드 배경색
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Color(0xFFFFF5F5), // 캘린더 배경색
              dayStyle: TextStyle(color: Colors.black),
              weekdayStyle: TextStyle(color: Colors.black),
              headerBackgroundColor: Color(0xFFFFF5F5),
              headerForegroundColor: Colors.black,
              rangeSelectionBackgroundColor: Color(0xFFF8A6A6),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFC5858), // 확인/취소 버튼 글자색
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // 새로운 날짜 범위를 리스트에 추가
        selectedDateRanges.add(picked);
      });
    }
  }

  // 방장인지 확인 (첫 번째 참여자가 방장으로 간주)
  // 실제로는 현재 사용자 정보와 비교해야 하지만, 임시로 항상 true로 설정
  // 나중에 실제 사용자 정보와 비교하도록 수정 필요
  bool _isRoomOwner() {
    if (_currentTripRoom == null || _currentTripRoom!.participants.isEmpty) {
      return false;
    }
    // 임시로 항상 방장으로 간주 (실제로는 현재 사용자 ID와 비교 필요)
    return true;
  }

  // 7-2 모달: 날짜 선택 확인
  Widget _buildDateConfirmModal(double scale) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: 366 * scale,
          height: 210 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF7),
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.all(40 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 26 * scale),
                // 제목
                Text(
                  '해당 날짜로 선택하시겠습니까?',
                  style: TextStyle(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 26 * scale),
                // 확인/취소 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 확인 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // 날짜 확정 시 TripRoomService 업데이트
                          if (_selectedRecommendedDate != null && _currentTripRoom != null) {
                            // 날짜 파싱 (예: "9/11 (목) - 9/13 (토)" 형식)
                            final dateRange = _selectedRecommendedDate!['dateRange'] as String;
                            // 간단한 날짜 파싱 (실제로는 더 정확한 파싱 필요)
                            final now = DateTime.now();
                            final year = now.year;
                            final month = now.month;

                            // 날짜 범위에서 시작일과 종료일 추출 (간단한 예시)
                            final parts = dateRange.split(' - ');
                            if (parts.length >= 2) {
                              final startPart = parts[0].split(' ')[0]; // "9/11"
                              final endPart = parts[1].split(' ')[0]; // "9/13"

                              final startDateParts = startPart.split('/');
                              final endDateParts = endPart.split('/');

                              if (startDateParts.length == 2 && endDateParts.length == 2) {
                                final startDate = DateTime(
                                  year,
                                  int.parse(startDateParts[0]),
                                  int.parse(startDateParts[1]),
                                );
                                final endDate = DateTime(
                                  year,
                                  int.parse(endDateParts[0]),
                                  int.parse(endDateParts[1]),
                                );

                                // TripRoomService에 날짜 업데이트
                                _tripRoomService.updateTripDates(
                                  _currentTripRoom!.id,
                                  startDate,
                                  endDate,
                                );

                                // 현재 방 정보 갱신
                                _currentTripRoom = _tripRoomService.currentTripRoom;
                              }
                            }
                          }

                          setState(() {
                        _showDateConfirmModal = false;
                        _stateService.showDateConfirmModal = false;
                        _isDateConfirmed = true; // 7-3 화면 표시
                        _stateService.isDateConfirmed = true;
                          });
                        },
                        child: Container(
                          height: 43 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8282),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Center(
                            child: Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 9 * scale),
                    // 취소 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showDateConfirmModal = false;
                            _stateService.showDateConfirmModal = false;
                          });
                        },
                        child: Container(
                          height: 43 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8282),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Center(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
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

  // 7-3 화면: 날짜 선택 완료 (전체 화면)
  Widget _buildDateConfirmedView(double scale) {
    final dateRange = _selectedRecommendedDate?['dateRange'] ?? '9월 11일 (목) ~ 9월 12일 (금)';

    return Column(
      children: [
        // 상단탭
        GestureDetector(
          onTap: _showTripRoomSelector,
          child: TopTab(
            title: _currentTripRoom?.title ?? "여행방을 선택해주세요",
            participantCount: _currentTripRoom?.participantCount ?? 0,
            dDay: _currentTripRoom?.dDay ?? "D-?",
          ),
        ),
        // 하위 탭 네비게이션 (확정 화면에서도 유지)
        TabNavigation(
          selectedIndex: selectedSubTabIndex,
          onTap: (index) {
            setState(() {
              selectedSubTabIndex = index;
            });
            _navigateToSubTab(index);
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: 369 * scale,
              margin: EdgeInsets.symmetric(horizontal: 16.5 * scale, vertical: 20 * scale),
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: const Color(0x801A0802),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 85 * scale,
                    height: 85 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFC5858).withOpacity(0.5),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 85 * scale,
                      color: const Color(0xFFFC5858),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  Text(
                    '여행 날짜가 확정되었습니다!',
                    style: TextStyle(
                      fontSize: 26 * scale,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    '2박 3일 여행',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25 * scale),
                  GestureDetector(
                    onTap: () {
                      if (_currentTripRoom != null) {
                        _tripRoomService.updateTripDates(
                          _currentTripRoom!.id,
                          null,
                          null,
                        );
                        _currentTripRoom = _tripRoomService.currentTripRoom;
                      }
                      setState(() {
                        _isDateConfirmed = false;
                      _stateService.isDateConfirmed = false;
                      _showDateConfirmModal = false;
                      _stateService.showDateConfirmModal = false;
                      _selectedRecommendedDate = null;
                      _stateService.selectedRecommendedDate = null;
                        selectedDateRanges.clear();
                      for (final date in recommendedDates) {
                        date['isSelected'] = false;
                      }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCFC),
                        borderRadius: BorderRadius.circular(6 * scale),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(4, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: Text(
                        '날짜 수정',
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
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
    );
  }

  void _showTripRoomSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '여행방 선택',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tripRoomService.tripRooms.length,
                itemBuilder: (context, index) {
                  final room = _tripRoomService.tripRooms[index];
                  final isSelected = _currentTripRoom?.id == room.id;

                  return ListTile(
                    title: Text(
                      room.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFFFA0A0) : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${room.participantCount}명 • ${room.destination} • ${room.dDay}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFFFFA0A0))
                        : null,
                    onTap: () {
                      setState(() {
                        _tripRoomService.setCurrentTripRoom(room);
                        _currentTripRoom = room;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSubTab(int index) {
    switch (index) {
      case 0: // 날짜
        // 현재 페이지
        break;
      case 1: // 후보지
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TripPlanCandidatesScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2: // 일정표
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TripPlanScheduleScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3: // 예산
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TripPlanBudgetScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 4: // 체크리스트
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TripPlanChecklistScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  Future<bool> _handleWillPop() async {
    if (_showDateConfirmModal) {
      setState(() {
        _showDateConfirmModal = false;
        _stateService.showDateConfirmModal = false;
      });
      return false;
    }
    return false;
  }
}