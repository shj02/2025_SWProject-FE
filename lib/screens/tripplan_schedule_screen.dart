import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/schedule_models.dart';
import '../models/trip_room.dart';
import '../services/trip_plan_state_service.dart';
import '../services/trip_room_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/top_tab.dart';
import 'community_screen.dart';
import 'main_menu_screen.dart';
import 'mypage_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_checklist_screen.dart';
import 'tripplan_date_screen.dart';

class TripPlanScheduleScreen extends StatefulWidget {
  const TripPlanScheduleScreen({super.key, this.initialPlaceName});

  final String? initialPlaceName;

  @override
  State<TripPlanScheduleScreen> createState() => _TripPlanScheduleScreenState();
}

class _TripPlanScheduleScreenState extends State<TripPlanScheduleScreen> {
  static const double _designWidth = 402.0;

  int _currentNavbarIndex = 1;
  int _selectedSubTabIndex = 2;

  late final TripRoomService _tripRoomService;
  late final TripPlanStateService _stateService;
  TripRoom? _currentTripRoom;

  late List<String> _activeEditors;

  late final List<ScheduleDay> _scheduleDays;

  @override
  void initState() {
    super.initState();
    _tripRoomService = TripRoomService();
    _stateService = TripPlanStateService();
    _currentTripRoom = _tripRoomService.currentTripRoom;

    if (_currentTripRoom != null) {
      _tripRoomService.updateDDay();
    }

    _scheduleDays = _stateService.scheduleDays;
    _activeEditors = List<String>.from(_stateService.activeEditors);

    if (widget.initialPlaceName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openAddSchedule(prefilledLocation: widget.initialPlaceName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = screenSize.width / _designWidth;
    final String defaultFontFamily = Theme.of(context).textTheme.titleMedium?.fontFamily ??
        Theme.of(context).textTheme.bodyMedium?.fontFamily ??
        'YeongdeokSea';

    if (_tripRoomService.tripRooms.isEmpty || _currentTripRoom == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
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
      );
    }

    final double buttonBottomSpacing = 12 * scale;
    final double buttonHeight = 55 * scale;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        17 * scale,
                        14 * scale,
                        17 * scale,
                        buttonHeight + buttonBottomSpacing,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditorsBanner(scale),
                          SizedBox(height: 14 * scale),
                          ..._scheduleDays.map(
                            (day) => Padding(
                              padding: EdgeInsets.only(bottom: 14 * scale),
                              child: _buildDaySection(day, scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 17 * scale,
                      right: 17 * scale,
                      bottom: buttonBottomSpacing,
                      child: Center( // 1. Center 위젯으로 감싸기
                        child: SizedBox(
                          width: 211 * scale, // 2. 원하는 가로 길이 지정
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () => _openAddSchedule(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8282),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12 * scale),
                              textStyle: TextStyle(
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.w600,
                                fontFamily: defaultFontFamily,
                              ),
                            ),
                            child: const Text('일정 추가하기'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorsBanner(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28 * scale,
            height: 28 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A0802), width: 1),
            ),
            child: Icon(
              Icons.group_add,
              size: 18 * scale,
              color: const Color(0xFF1A0802),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              '현재 편집 중:',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Wrap(
            spacing: 8 * scale,
            children: _activeEditors
                .map(
                  (editor) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale,
                      vertical: 6 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6 * scale),
                      border: Border.all(color: const Color(0xFFFC5858), width: 1),
                    ),
                    child: Text(
                      editor,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A0802),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(ScheduleDay day, double scale) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 22 * scale, color: const Color(0xFF1A0802)),
              SizedBox(width: 10 * scale),
              Text(
                day.title,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          ...day.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: _buildScheduleCard(day, item, scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleDay day, ScheduleEntry item, double scale) {
    final List<String> editingEditors = _stateService.editorsForEntry(item.id);
    final bool hasEditors = editingEditors.isNotEmpty;

    return GestureDetector(
      onTap: () => _openScheduleDetail(item, day.title),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: const Color(0xFF1A0802), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50 * scale,
              height: 50 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFFDDFCC),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 16 * scale, color: const Color(0xFF1A0802)),
                  SizedBox(height: 4 * scale),
                  Text(
                    item.formattedTime,
                    style: TextStyle(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                ],
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
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Icon(Icons.location_pin, size: 14 * scale, color: const Color(0xFF1A0802)),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A0802),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.memo.isNotEmpty) ...[
                    SizedBox(height: 8 * scale),
                    Text(
                      item.memo,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5D6470),
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (hasEditors) ...[
                    SizedBox(height: 8 * scale),
                    Wrap(
                      spacing: 8 * scale,
                      children: editingEditors
                          .map(
                            (editor) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 4 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6 * scale),
                                border: Border.all(color: const Color(0xFFFC5858), width: 1),
                              ),
                              child: Text(
                                editor,
                                style: TextStyle(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A0802),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8 * scale),
            IconButton(
              onPressed: () => _openEditSchedule(day, item),
              icon: Icon(Icons.edit_outlined, size: 20 * scale, color: const Color(0xFFFC5858)),
            ),
          ],
        ),
      ),
    );
  }

  void _openScheduleDetail(ScheduleEntry item, String dayTitle) {
    final List<String> editingEditors = _stateService.editorsForEntry(item.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleDetailSheet(
        item: item,
        dayTitle: dayTitle,
        editingEditors: editingEditors,
      ),
    );
  }

  void _openAddSchedule({String? prefilledLocation}) {
    final String currentUserName = UserService().userName ?? '나';
    _stateService.startEditingUser(currentUserName);
    setState(() {
      _activeEditors = List<String>.from(_stateService.activeEditors);
    });

    final Future<ScheduleEditorResult?> modalFuture = showModalBottomSheet<ScheduleEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleEditorSheet(
        days: _scheduleDays,
        initialLocation: prefilledLocation,
      ),
    );

    modalFuture.then((result) {
      if (result == null) return;
      setState(() {
        final ScheduleDay day = _scheduleDays.firstWhere((d) => d.id == result.dayId);
        day.items.add(
          ScheduleEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            time: result.time,
            title: result.title,
            location: result.location,
            memo: result.memo,
            editors: const [],
          ),
        );
        day.items.sort((a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));
        _activeEditors = List<String>.from(_stateService.activeEditors);
      });
    });

    modalFuture.whenComplete(() {
      _stateService.stopEditingUser(currentUserName);
      if (!mounted) return;
      setState(() {
        _activeEditors = List<String>.from(_stateService.activeEditors);
      });
    });
  }

  void _openEditSchedule(ScheduleDay day, ScheduleEntry item) {
    final String currentUserName = UserService().userName ?? '나';
    _stateService.startEditingEntry(item.id, currentUserName);
    setState(() {
      _activeEditors = List<String>.from(_stateService.activeEditors);
    });

    final Future<ScheduleEditorResult?> modalFuture = showModalBottomSheet<ScheduleEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleEditorSheet(
        days: _scheduleDays,
        initialDayId: day.id,
        initialEntry: item,
      ),
    );

    modalFuture.then((result) {
      if (result == null) return;
      setState(() {
        final ScheduleDay sourceDay = _scheduleDays.firstWhere((d) => d.id == day.id);
        sourceDay.items.removeWhere((entry) => entry.id == item.id);

        final ScheduleDay targetDay = _scheduleDays.firstWhere((d) => d.id == result.dayId);
        targetDay.items.add(
          item.copyWith(
            time: result.time,
            title: result.title,
            location: result.location,
            memo: result.memo,
            editors: const [],
          ),
        );

        for (final ScheduleDay scheduleDay in _scheduleDays) {
          scheduleDay.items.sort((a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));
        }
        _activeEditors = List<String>.from(_stateService.activeEditors);
      });
    });

    modalFuture.whenComplete(() {
      _stateService.stopEditingEntry(item.id, currentUserName);
      if (!mounted) return;
      setState(() {
        _activeEditors = List<String>.from(_stateService.activeEditors);
      });
    });
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

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
        break;
      case 3:
        _replaceWith(const TripPlanBudgetScreen());
        break;
      case 4:
        _replaceWith(const TripPlanChecklistScreen());
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

class ScheduleEditorResult {
  ScheduleEditorResult({
    required this.dayId,
    required this.time,
    required this.title,
    required this.location,
    required this.memo,
    required this.editors,
  });

  final String dayId;
  final TimeOfDay time;
  final String title;
  final String location;
  final String memo;
  final List<String> editors;
}

class ScheduleEditorSheet extends StatefulWidget {
  const ScheduleEditorSheet({
    required this.days,
    this.initialDayId,
    this.initialEntry,
    this.initialLocation,
  });

  final List<ScheduleDay> days;
  final String? initialDayId;
  final ScheduleEntry? initialEntry;
  final String? initialLocation;

  @override
  State<ScheduleEditorSheet> createState() => _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends State<ScheduleEditorSheet> {
  late String _selectedDayId;
  late TimeOfDay _selectedTime;
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _selectedDayId = widget.initialDayId ?? widget.days.first.id;
    _selectedTime = widget.initialEntry?.time ?? const TimeOfDay(hour: 9, minute: 0);
    _titleController = TextEditingController(text: widget.initialEntry?.title ?? '');
    _locationController = TextEditingController(
      text: widget.initialEntry?.location ?? widget.initialLocation ?? '',
    );
    _memoController = TextEditingController(text: widget.initialEntry?.memo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / _TripPlanScheduleScreenState._designWidth;

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
              widget.initialEntry == null ? '일정 추가하기' : '일정 수정하기',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('Day 선택', scale),
            DropdownButtonFormField<String>(
              value: _selectedDayId,
              decoration: _inputDecoration(scale),
              items: widget.days
                  .map(
                    (day) => DropdownMenuItem<String>(
                      value: day.id,
                      child: Text(day.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedDayId = value;
                });
              },
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('시간', scale),
            OutlinedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
                side: const BorderSide(color: Color(0xFF1A0802)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 18 * scale, color: const Color(0xFF1A0802)),
                  SizedBox(width: 8 * scale),
                  Text(
                    ScheduleEntry.formatTime(_selectedTime),
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('일정 제목', scale),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(scale).copyWith(hintText: '예) 공항 도착'),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('장소', scale),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration(scale).copyWith(hintText: '예) 김포공항'),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('메모 (선택)', scale),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: _inputDecoration(scale).copyWith(
                hintText: '메모를 남겨보세요.',
              ),
            ),
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
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(widget.initialEntry == null ? '일정 추가' : '일정 수정'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 장소를 입력해주세요.')),
      );
      return;
    }

    Navigator.pop(
      context,
      ScheduleEditorResult(
        dayId: _selectedDayId,
        time: _selectedTime,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        memo: _memoController.text.trim(),
        editors: const [],
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(double scale) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * scale),
        borderSide: const BorderSide(color: Color(0x801A0802)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * scale),
        borderSide: const BorderSide(color: Color(0x801A0802)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * scale),
        borderSide: const BorderSide(color: Color(0xFFFC5858), width: 2),
      ),
    );
  }
}

class ScheduleDetailSheet extends StatelessWidget {
  const ScheduleDetailSheet({
    super.key,
    required this.item,
    required this.dayTitle,
    required this.editingEditors,
  });

  final ScheduleEntry item;
  final String dayTitle;
  final List<String> editingEditors;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / _TripPlanScheduleScreenState._designWidth;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            dayTitle,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Icon(Icons.access_time, size: 18 * scale, color: const Color(0xFF1A0802)),
              SizedBox(width: 8 * scale),
              Text(
                item.formattedTime,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A0802),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 18 * scale, color: const Color(0xFF1A0802)),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  item.location,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A0802),
                  ),
                ),
              ),
            ],
          ),
          if (item.memo.isNotEmpty) ...[
            SizedBox(height: 16 * scale),
            Text(
              '메모',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              item.memo,
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A0802),
                height: 1.4,
              ),
            ),
          ],
          if (editingEditors.isNotEmpty) ...[
            SizedBox(height: 16 * scale),
            Text(
              '현재 편집 중',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8 * scale),
            Wrap(
              spacing: 8 * scale,
              children: editingEditors
                  .map(
                    (editor) => Chip(
                      label: Text(editor),
                      backgroundColor: const Color(0xFFFFF5F5),
                      side: const BorderSide(color: Color(0xFFFC5858)),
                    ),
                  )
                  .toList(),
            ),
          ],
          SizedBox(height: 24 * scale),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ),
        ],
      ),
    );
  }
}
