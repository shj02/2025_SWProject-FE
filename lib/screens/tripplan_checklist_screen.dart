import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trip_room.dart';
import '../services/trip_room_service.dart';
import '../services/trip_plan_state_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/top_tab.dart';
import 'community_screen.dart';
import 'main_menu_screen.dart';
import 'mypage_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_schedule_screen.dart';

class TripPlanChecklistScreen extends StatefulWidget {
  const TripPlanChecklistScreen({super.key});

  @override
  State<TripPlanChecklistScreen> createState() => _TripPlanChecklistScreenState();
}

class _TripPlanChecklistScreenState extends State<TripPlanChecklistScreen> {
  static const double _designWidth = 402.0;

  int _currentNavbarIndex = 1;
  int _selectedSubTabIndex = 4;

  late final TripRoomService _tripRoomService;
  late final TripPlanStateService _stateService;
  TripRoom? _currentTripRoom;

  late List<ChecklistItem> _sharedChecklist;
  late List<ChecklistItem> _personalChecklist;

  @override
  void initState() {
    super.initState();
    _tripRoomService = TripRoomService();
    _stateService = TripPlanStateService();
    _currentTripRoom = _tripRoomService.currentTripRoom;

    if (_currentTripRoom != null) {
      _tripRoomService.updateDDay();
    }

    _sharedChecklist = [
      ChecklistItem(
        id: 'shared-1',
        title: '항공권 예약',
        assignee: '홍길동',
        dueLabel: '마감: 9/10',
      ),
      ChecklistItem(
        id: 'shared-2',
        title: '숙소 예약',
        assignee: '이순신',
        dueLabel: '마감: 9/10',
      ),
      ChecklistItem(
        id: 'shared-3',
        title: '식당 예약',
        assignee: '이순신',
        memo: '현지 맛집 2~3곳 예약',
      ),
    ];

    _personalChecklist = [
      ChecklistItem(
        id: 'personal-1',
        title: '옷 준비',
        isShared: false,
      ),
      ChecklistItem(
        id: 'personal-2',
        title: '삼각대',
        isShared: false,
      ),
      ChecklistItem(
        id: 'personal-3',
        title: '운동화',
        memo: '편한 운동화',
        isShared: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = screenSize.width / _designWidth;

    if (_tripRoomService.tripRooms.isEmpty || _currentTripRoom == null) {
      return WillPopScope(
        onWillPop: _handleWillPop,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFFFF5F5),
            systemNavigationBarColor: Color(0xFFFFFCFC),
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFCFC),
            bottomNavigationBar: CustomNavbar(
              currentIndex: _currentNavbarIndex,
              onTap: _handleNavbarTap,
            ),
            body: SafeArea(
              child: Center(
                child: Text(
                  '계획중인 여행이 없습니다.',
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A0802),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFFF5F5),
          systemNavigationBarColor: Color(0xFFFFFCFC),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFCFC),
          bottomNavigationBar: CustomNavbar(
            currentIndex: _currentNavbarIndex,
            onTap: _handleNavbarTap,
          ),
          body: SafeArea(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showTripRoomSelector,
                  child: TopTab(
                    title: _currentTripRoom?.title ?? '여행방을 선택해주세요',
                    participantCount: _currentTripRoom?.participantCount ?? 0,
                    dDay: _currentTripRoom?.dDay ?? 'D-?',
                  ),
                ),
                TabNavigation(
                  selectedIndex: _selectedSubTabIndex,
                  onTap: (index) {
                    if (_selectedSubTabIndex == index) return;
                    setState(() {
                      _selectedSubTabIndex = index;
                    });
                    _navigateToSubTab(index);
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 17 * scale, vertical: 16 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          scale: scale,
                          icon: Icons.groups,
                          title: '공용 체크리스트',
                          items: _sharedChecklist,
                          onToggle: _toggleSharedItem,
                          onAddPressed: () => _openAddChecklistModal(isShared: true),
                        ),
                        SizedBox(height: 16 * scale),
                        _buildSection(
                          scale: scale,
                          icon: Icons.person_outline,
                          title: '개인 체크리스트',
                          items: _personalChecklist,
                          onToggle: _togglePersonalItem,
                          onAddPressed: () => _openAddChecklistModal(isShared: false),
                        ),
                      ],
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

  Widget _buildSection({
    required double scale,
    required IconData icon,
    required String title,
    required List<ChecklistItem> items,
    required ValueChanged<ChecklistItem> onToggle,
    required VoidCallback onAddPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24 * scale, color: const Color(0xFF1A0802)),
                  SizedBox(width: 7 * scale),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddPressed,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8282), // 1. 배경색 추가
                  foregroundColor: Colors.white,             // 2. 아이콘/텍스트 색상 변경
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 2 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6 * scale), // 3. 둥근 모서리 적용
                  ),
                ),
                icon: Icon(Icons.add_circle_outline, size: 16 * scale, color: Colors.white),
                label: Text(
                  '체크리스트 추가',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: _ChecklistTile(
                item: item,
                scale: scale,
                onToggle: () => onToggle(item),
                onMemoTap: item.memo?.isNotEmpty == true ? () => _showMemoDialog(item) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSharedItem(ChecklistItem item) {
    setState(() {
      final int index = _sharedChecklist.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _sharedChecklist[index] = item.copyWith(isDone: !item.isDone);
      }
    });
  }

  void _togglePersonalItem(ChecklistItem item) {
    setState(() {
      final int index = _personalChecklist.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _personalChecklist[index] = item.copyWith(isDone: !item.isDone);
      }
    });
  }

  void _openAddChecklistModal({required bool isShared}) {
    showModalBottomSheet<ChecklistItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChecklistEditorSheet(isShared: isShared),
    ).then((result) {
      if (result == null) return;
      setState(() {
        if (isShared) {
          _sharedChecklist.add(result);
        } else {
          _personalChecklist.add(result);
        }
        final String roomId = _currentTripRoom?.id ?? '';
        if (roomId.isNotEmpty) {
          _stateService.markChecklistAdded(roomId, isShared: isShared);
        }
      });
    });
  }

  void _showMemoDialog(ChecklistItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Text(item.memo ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<bool> _handleWillPop() async => false;

  void _handleNavbarTap(int index) {
    if (_currentNavbarIndex == index) return;

    setState(() {
      _currentNavbarIndex = index;
    });

    switch (index) {
      case 0:
        _replaceWith(const MainMenuScreen());
        break;
      case 1:
        _replaceWith(const TripPlanDateScreen());
        break;
      case 2:
        _replaceWith(const CommunityScreen());
        break;
      case 3:
        _replaceWith(const MypageScreen());
        break;
    }
  }

  void _navigateToSubTab(int index) {
    switch (index) {
      case 0:
        _replaceWith(const TripPlanDateScreen());
        break;
      case 1:
        _replaceWith(const TripPlanCandidatesScreen());
        break;
      case 2:
        _replaceWith(const TripPlanScheduleScreen());
        break;
      case 3:
        _replaceWith(const TripPlanBudgetScreen());
        break;
      case 4:
        break;
    }
  }

  void _replaceWith(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
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
                color: Colors.grey.shade300,
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
                  final TripRoom room = _tripRoomService.tripRooms[index];
                  final bool isSelected = _currentTripRoom?.id == room.id;

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
                    trailing:
                        isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFFA0A0)) : null,
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
}

class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.title,
    this.memo,
    this.assignee,
    this.dueLabel,
    this.isShared = true,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String? memo;
  final String? assignee;
  final String? dueLabel;
  final bool isShared;
  final bool isDone;

  ChecklistItem copyWith({
    String? title,
    String? memo,
    String? assignee,
    String? dueLabel,
    bool? isShared,
    bool? isDone,
  }) {
    return ChecklistItem(
      id: id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      assignee: assignee ?? this.assignee,
      dueLabel: dueLabel ?? this.dueLabel,
      isShared: isShared ?? this.isShared,
      isDone: isDone ?? this.isDone,
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.scale,
    required this.onToggle,
    this.onMemoTap,
  });

  final ChecklistItem item;
  final double scale;
  final VoidCallback onToggle;
  final VoidCallback? onMemoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 22 * scale,
                  height: 22 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6 * scale),
                    border: Border.all(color: const Color(0xFF1A0802), width: 1.2),
                    color: item.isDone ? const Color(0xFFFF8282) : Colors.white,
                  ),
                  child: item.isDone
                      ? Icon(Icons.check, size: 16 * scale, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                        color: item.isDone ? const Color(0xFF9AA0A6) : Colors.black,
                        decoration: item.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    if (item.memo?.isNotEmpty == true)
                      Padding(
                        padding: EdgeInsets.only(top: 6 * scale),
                        child: GestureDetector(
                          onTap: onMemoTap,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.sticky_note_2_outlined,
                                  size: 14 * scale,
                                  color: const Color(0xFF1A0802).withOpacity(0.8)),
                              SizedBox(width: 6 * scale),
                              Expanded(
                                child: Text(
                                  item.memo!,
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A0802).withOpacity(0.75),
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
          ),
          if (item.assignee != null || item.dueLabel != null)
            Padding(
              padding: EdgeInsets.only(top: 12 * scale),
              child: Row(
                children: [
                  if (item.assignee != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6 * scale),
                        color: const Color(0xFFFFF5F5),
                        border: Border.all(color: const Color(0xFFFF8282), width: 1),
                      ),
                      child: Text(
                        item.assignee!,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A0802),
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                  ],
                  if (item.dueLabel != null)
                    Text(
                      item.dueLabel!,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5D6470),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ChecklistEditorSheet extends StatefulWidget {
  const ChecklistEditorSheet({required this.isShared});

  final bool isShared;

  @override
  State<ChecklistEditorSheet> createState() => _ChecklistEditorSheetState();
}

class _ChecklistEditorSheetState extends State<ChecklistEditorSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  final TextEditingController _dueController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _assigneeController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / _TripPlanChecklistScreenState._designWidth;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20 * scale,
        right: 20 * scale,
        top: 20 * scale,
        bottom: 20 * scale + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48 * scale,
                height: 4 * scale,
                margin: EdgeInsets.only(bottom: 16 * scale),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
            ),
            Text(
              widget.isShared ? '공용 체크리스트 추가' : '개인 체크리스트 추가',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('항목 이름', scale),
            _buildTextField(_titleController, '예) 항공권 예약', scale),
            SizedBox(height: 16 * scale),
            _buildLabel('메모 (선택)', scale),
            _buildTextField(_memoController, '추가 설명을 입력하세요', scale, maxLines: 2),
            if (widget.isShared) ...[
              SizedBox(height: 16 * scale),
              _buildLabel('담당자 (선택)', scale),
              _buildTextField(_assigneeController, '홍길동', scale),
              SizedBox(height: 16 * scale),
              _buildLabel('마감일 (선택)', scale),
              _buildTextField(_dueController, '예) 마감: 9/10', scale),
            ],
            SizedBox(height: 24 * scale),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8282),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  textStyle: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'YeongdeokSea',
                  ),
                ),
                child: const Text('추가하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty) {
      _showValidationDialog('항목 이름을 입력해주세요.');
      return;
    }

    Navigator.pop(
      context,
      ChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
        assignee: widget.isShared && _assigneeController.text.trim().isNotEmpty
            ? _assigneeController.text.trim()
            : null,
        dueLabel: widget.isShared && _dueController.text.trim().isNotEmpty
            ? _dueController.text.trim()
            : null,
        isShared: widget.isShared,
      ),
    );
  }

  void _showValidationDialog(String message) {
    final double scale =
        MediaQuery.of(context).size.width / _TripPlanChecklistScreenState._designWidth;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
          title: Text(
            '알림',
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A0802),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A0802),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                '확인',
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A0802),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    double scale, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0x801A0802)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFFC5858), width: 2),
        ),
      ),
    );
  }
}
