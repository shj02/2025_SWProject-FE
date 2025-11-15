import 'dart:math';
import '../models/trip_room.dart';

class TripRoomService {
  static final TripRoomService _instance = TripRoomService._internal();
  factory TripRoomService() => _instance;
  TripRoomService._internal();

  final Random _random = Random();

  // 대문자 8자리 ID 생성
  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  // 외부에서 사용할 수 있도록 public 메서드로 제공
  String generateRoomId() {
    return _generateRoomId();
  }

  TripRoom? _currentTripRoom;
  final List<TripRoom> _tripRooms = [];

  // 현재 생성된 여행방
  TripRoom? get currentTripRoom => _currentTripRoom;

  // 모든 여행방 목록
  List<TripRoom> get tripRooms => List.unmodifiable(_tripRooms);

  // 현재 여행방 설정
  void setCurrentTripRoom(TripRoom tripRoom) {
    _currentTripRoom = tripRoom;
  }

  // 여행방 ID로 현재 여행방 설정
  void setCurrentTripRoomById(String tripRoomId) {
    _currentTripRoom = _tripRooms.firstWhere(
      (room) => room.id == tripRoomId,
      orElse: () => throw Exception('여행방을 찾을 수 없습니다: $tripRoomId'),
    );
  }

  // 여행방 추가
  void addTripRoom(TripRoom tripRoom) {
    _tripRooms.add(tripRoom);
    if (_currentTripRoom == null) {
      _currentTripRoom = tripRoom;
    }
  }

  // 여행방 업데이트
  void updateTripRoom(TripRoom updatedTripRoom) {
    final index = _tripRooms.indexWhere((room) => room.id == updatedTripRoom.id);
    if (index != -1) {
      _tripRooms[index] = updatedTripRoom;
      if (_currentTripRoom?.id == updatedTripRoom.id) {
        _currentTripRoom = updatedTripRoom;
      }
    }
  }

  // 여행방 삭제
  void deleteTripRoom(String tripRoomId) {
    _tripRooms.removeWhere((room) => room.id == tripRoomId);
    if (_currentTripRoom?.id == tripRoomId) {
      _currentTripRoom = _tripRooms.isNotEmpty ? _tripRooms.first : null;
    }
  }

  // 샘플 데이터 초기화
  // 백엔드 연동 전 테스트용으로 사용자가 만든 방처럼 생성
  void initializeSampleData() {
    if (_tripRooms.isNotEmpty) return;

    final now = DateTime.now();
    
    final sampleRooms = [
      TripRoom(
        id: _generateRoomId(), // 대문자 8자리 ID
        title: '제주도 우정여행',
        participantCount: 3,
        dDay: 'D-?', // 날짜 미정
        startDate: null, // 사용자가 아직 선택하지 않은 상태
        endDate: null,
        destination: '제주도',
        participants: ['나', '친구1', '친구2'], // 사용자('나')를 포함
        status: 'planning',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      TripRoom(
        id: _generateRoomId(), // 대문자 8자리 ID
        title: '일본 가족여행',
        participantCount: 4,
        dDay: 'D-15',
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 17)),
        destination: '일본',
        participants: ['나', '엄마', '아빠', '동생'], // 사용자('나')를 포함
        status: 'planning',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      TripRoom(
        id: _generateRoomId(), // 대문자 8자리 ID
        title: '제주 힐링여행',
        participantCount: 2,
        dDay: 'D-3',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        destination: '제주',
        participants: ['나', '연인'], // 사용자('나')를 포함
        status: 'confirmed',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
    ];

    for (final room in sampleRooms) {
      addTripRoom(room);
    }
  }

  // D-Day 업데이트 (시간에 따라 자동 업데이트)
  void updateDDay() {
    if (_currentTripRoom != null) {
      final updatedRoom = _currentTripRoom!.copyWith(
        dDay: _currentTripRoom!.calculateDDay(),
        updatedAt: DateTime.now(),
      );
      updateTripRoom(updatedRoom);
    }
  }

  // 여행방 상태 업데이트
  void updateTripRoomStatus(String tripRoomId, String status) {
    final room = _tripRooms.firstWhere(
      (r) => r.id == tripRoomId,
      orElse: () => throw Exception('여행방을 찾을 수 없습니다: $tripRoomId'),
    );

    final updatedRoom = room.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    updateTripRoom(updatedRoom);
  }

  // 여행 날짜 업데이트
  void updateTripDates(String tripRoomId, DateTime? startDate, DateTime? endDate) {
    final room = _tripRooms.firstWhere(
      (r) => r.id == tripRoomId,
      orElse: () => throw Exception('여행방을 찾을 수 없습니다: $tripRoomId'),
    );

    // 새로운 날짜로 임시 방을 생성하여 D-Day 계산
    final tempRoom = room.copyWith(
      startDate: startDate,
      endDate: endDate,
    );

    // 날짜가 설정되면 'date' 단계를 완료로 표시
    final completedSteps = Set<String>.from(room.completedSteps);
    if (startDate != null) {
      completedSteps.add('date');
    } else {
      completedSteps.remove('date');
    }

    final updatedRoom = tempRoom.copyWith(
      dDay: startDate != null ? tempRoom.calculateDDay() : 'D-?',
      completedSteps: completedSteps,
      updatedAt: DateTime.now(),
    );

    updateTripRoom(updatedRoom);
  }
}

