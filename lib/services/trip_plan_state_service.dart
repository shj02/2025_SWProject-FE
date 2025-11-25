import 'package:flutter/material.dart';


import '../models/schedule_models.dart';

class TripPlanStateService {
  TripPlanStateService._internal() {
    _initialise();
  }

  static final TripPlanStateService _instance = TripPlanStateService._internal();

  factory TripPlanStateService() => _instance;

  bool _initialized = false;

  final List<Map<String, dynamic>> aiRecommendedPlaces = [];
  final List<Map<String, dynamic>> friendSuggestedPlaces = [];
  final List<Map<String, dynamic>> recommendedDates = [];
  final List<DateTimeRange> selectedDateRanges = [];
  final List<ScheduleDay> scheduleDays = [];
  final List<String> activeEditors = [];
  final Map<String, int> _activeEditorCounts = {};
  final Map<String, Map<String, int>> _entryEditorCounts = {};

  final Map<String, Set<String>> _memberPlaceSuggestorsByRoom = {};
  final Map<String, Set<String>> _checklistTypesByRoom = {};
  final Map<String, Set<String>> _scheduleDaysByRoom = {};
  final Map<String, Set<String>> _scheduleCompletedDaysByRoom = {};
  final Map<String, Set<String>> _budgetMembersByRoom = {};
  final Set<String> _memberPlaceSuggestors = {};
  final Set<String> _completedChecklistTypes = {};
  bool _budgetComplete = false;

  Map<String, dynamic>? selectedRecommendedDate;
  bool isDateConfirmed = false;
  bool showDateConfirmModal = false;

  void _initialise() {
    if (_initialized) return;
    _initialized = true;

    aiRecommendedPlaces.addAll([
      {
        'id': '1',
        'name': '한라산',
        'category': '자연/체험',
        'description': '제주 최고봉 트레킹',
        'imageUrl': 'assets/images/hallasan.jpg',
        'voteCount': 1,
        'isAddedToSchedule': false,
        'hasVoted': false,
      },
      {
        'id': '2',
        'name': '우도',
        'category': '자연/체험',
        'description': '아름다운 섬 투어',
        'imageUrl': 'assets/images/udo.jpg',
        'voteCount': 1,
        'isAddedToSchedule': false,
        'hasVoted': false,
      },
      {
        'id': '3',
        'name': '성산일출봉',
        'category': '자연/관광',
        'description': '제주도 대표 일출 명소',
        'imageUrl': 'assets/images/seongsan.jpg',
        'voteCount': 1,
        'isAddedToSchedule': false,
        'hasVoted': false,
      },
    ]);

    friendSuggestedPlaces.addAll([
      {
        'id': '4',
        'name': '애월 해안도로',
        'category': '자연/관광',
        'description':
            '제주도 서쪽 해안을 따라 이어지는 아름다운 드라이브 코스입니다. 카페 거리와 함께 환상적인 석양을 볼 수 있어요.',
        'suggestedBy': '홍길동',
        'voteCount': 1,
        'isAddedToSchedule': false,
        'hasVoted': false,
      },
      {
        'id': '5',
        'name': '성산 일출봉',
        'category': '자연/관광',
        'description':
            '제주도 서쪽 해안을 따라 이어지는 아름다운 드라이브 코스입니다. 카페 거리와 함께 환상적인 석양을 볼 수 있어요.',
        'suggestedBy': '홍길동',
        'voteCount': 1,
        'isAddedToSchedule': false,
        'hasVoted': false,
      },
      {
        'id': '6',
        'name': '중문 관광단지',
        'category': '자연/관광',
        'description':
            '제주도 서쪽 해안을 따라 이어지는 아름다운 드라이브 코스입니다. 카페 거리와 함께 환상적인 석양을 볼 수 있어요.',
        'suggestedBy': '홍길동',
        'voteCount': 1,
        'isAddedToSchedule': false,
        'hasVoted': false,
      },
    ]);

    recommendedDates.addAll([
      {
        'dateRange': '11/11 (목) - 11/13 (토)',
        'availableMembers': 3,
        'matchRate': 100,
        'isSelected': false,
      },
      {
        'dateRange': '11/12 (목) - 11/13 (토)',
        'availableMembers': 3,
        'matchRate': 100,
        'isSelected': false,
      },
      {
        'dateRange': '11/13 (목) - 11/14 (토)',
        'availableMembers': 1,
        'matchRate': 33,
        'isSelected': false,
      },
    ]);

    scheduleDays.addAll([
      ScheduleDay(
        id: 'day1',
        title: 'Day 1 - 9/11 (목)',
        items: [
          ScheduleEntry(
            id: '1',
            time: const TimeOfDay(hour: 9, minute: 0),
            title: '공항도착',
            location: '김포공항',
            editors: const [],
            memo: '',
          ),
          ScheduleEntry(
            id: '2',
            time: const TimeOfDay(hour: 11, minute: 0),
            title: '제주공항도착',
            location: '제주국제공항',
            editors: const [],
            memo: '',
          ),
          ScheduleEntry(
            id: '3',
            time: const TimeOfDay(hour: 15, minute: 0),
            title: '숙소 체크인',
            location: '00호텔',
            editors: const [],
            memo: '',
          ),
        ],
      ),
      ScheduleDay(
        id: 'day2',
        title: 'Day 2 - 9/12 (금)',
        items: [
          ScheduleEntry(
            id: '4',
            time: const TimeOfDay(hour: 8, minute: 0),
            title: '조식먹기',
            location: '호텔',
            editors: const [],
            memo: '',
          ),
          ScheduleEntry(
            id: '5',
            time: const TimeOfDay(hour: 11, minute: 0),
            title: '제주공항출발',
            location: '제주국제공항',
            editors: const [],
            memo: '',
          ),
        ],
      ),
    ]);

    _refreshActiveEditorsFromCounts();
  }

  void startEditingUser(String editor) {
    if (editor.isEmpty) return;
    _activeEditorCounts.update(editor, (value) => value + 1, ifAbsent: () => 1);
    _refreshActiveEditorsFromCounts();
  }

  void stopEditingUser(String editor) {
    if (editor.isEmpty) return;
    final int? current = _activeEditorCounts[editor];
    if (current == null) return;
    if (current <= 1) {
      _activeEditorCounts.remove(editor);
    } else {
      _activeEditorCounts[editor] = current - 1;
    }
    _refreshActiveEditorsFromCounts();
  }

  void startEditingEntry(String entryId, String editor) {
    if (entryId.isEmpty || editor.isEmpty) return;
    final Map<String, int> entryCounts =
        _entryEditorCounts.putIfAbsent(entryId, () => <String, int>{});
    entryCounts.update(editor, (value) => value + 1, ifAbsent: () => 1);
    startEditingUser(editor);
  }

  void stopEditingEntry(String entryId, String editor) {
    if (entryId.isEmpty || editor.isEmpty) return;
    final Map<String, int>? entryCounts = _entryEditorCounts[entryId];
    if (entryCounts != null) {
      final int? current = entryCounts[editor];
      if (current != null) {
        if (current <= 1) {
          entryCounts.remove(editor);
        } else {
          entryCounts[editor] = current - 1;
        }
        if (entryCounts.isEmpty) {
          _entryEditorCounts.remove(entryId);
        }
      }
    }
    stopEditingUser(editor);
  }

  List<String> editorsForEntry(String entryId) {
    final Map<String, int>? entryCounts = _entryEditorCounts[entryId];
    if (entryCounts == null) return const [];
    final List<String> editors = entryCounts.keys.toList()..sort();
    return editors;
  }

  void _refreshActiveEditorsFromCounts() {
    final List<String> sortedEditors = _activeEditorCounts.keys.toList()..sort();
    activeEditors
      ..clear()
      ..addAll(sortedEditors);
  }

  void addFriendSuggestionMember(String roomId, String memberName) {
    if (roomId.isEmpty || memberName.isEmpty) return;
    _memberPlaceSuggestorsByRoom
        .putIfAbsent(roomId, () => <String>{})
        .add(memberName);
  }

  bool hasMemberSuggestedPlace(String roomId) =>
      _memberPlaceSuggestorsByRoom[roomId]?.isNotEmpty ?? false;

  void markChecklistAdded(String roomId, {required bool isShared}) {
    if (roomId.isEmpty) return;
    _checklistTypesByRoom
        .putIfAbsent(roomId, () => <String>{})
        .add(isShared ? 'shared' : 'personal');
  }

  bool hasSharedChecklist(String roomId) =>
      _checklistTypesByRoom[roomId]?.contains('shared') ?? false;

  bool hasPersonalChecklist(String roomId) =>
      _checklistTypesByRoom[roomId]?.contains('personal') ?? false;

  bool isChecklistComplete(String roomId) =>
      hasSharedChecklist(roomId) && hasPersonalChecklist(roomId);

  void setScheduleDaysForRoom(String roomId, Iterable<String> dayIds) {
    if (roomId.isEmpty) return;
    final Set<String> ids = dayIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    _scheduleDaysByRoom[roomId] = ids;
    _scheduleCompletedDaysByRoom
        .putIfAbsent(roomId, () => <String>{})
        .removeWhere((id) => !ids.contains(id));
  }

  void markScheduleEntryAdded(String roomId, String dayId) {
    if (roomId.isEmpty || dayId.isEmpty) return;
    final Set<String> completedDays =
        _scheduleCompletedDaysByRoom.putIfAbsent(roomId, () => <String>{});
    completedDays.add(dayId);
    final Set<String>? availableDays = _scheduleDaysByRoom[roomId];
    if (availableDays != null) {
      completedDays.removeWhere((id) => !availableDays.contains(id));
    }
  }

  bool isScheduleComplete(String roomId) {
    final Set<String>? availableDays = _scheduleDaysByRoom[roomId];
    if (availableDays == null || availableDays.isEmpty) return false;
    final Set<String>? completedDays = _scheduleCompletedDaysByRoom[roomId];
    if (completedDays == null) return false;
    return availableDays.every(completedDays.contains);
  }

  void markBudgetForMember(String roomId, String memberName) {
    final String trimmedRoomId = roomId.trim();
    final String trimmedName = memberName.trim();
    if (trimmedRoomId.isEmpty || trimmedName.isEmpty) return;
    _budgetMembersByRoom
        .putIfAbsent(trimmedRoomId, () => <String>{})
        .add(trimmedName);
  }

  bool isBudgetComplete(String roomId, Iterable<String> participants) {
    final String trimmedRoomId = roomId.trim();
    if (trimmedRoomId.isEmpty) return false;
    final Set<String> participantSet = participants
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    if (participantSet.isEmpty) return false;
    final Set<String> filledMembers =
        _budgetMembersByRoom[trimmedRoomId] ?? const <String>{};
    final bool nameMatchComplete = participantSet.every(filledMembers.contains);
    if (nameMatchComplete) return true;
    return filledMembers.length >= participantSet.length;
  }
}

