class TripRoom {
  final String id;
  final String title;
  final int participantCount;
  final String dDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final String destination;
  final List<String> participants;
  final String status; // 'planning', 'confirmed', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Set<String> completedSteps; // 완료된 단계: 'date', 'candidates', 'schedule', 'budget', 'checklist'

  const TripRoom({
    required this.id,
    required this.title,
    required this.participantCount,
    required this.dDay,
    this.startDate,
    this.endDate,
    required this.destination,
    required this.participants,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedSteps = const {},
  });

  // JSON 변환 메서드
  factory TripRoom.fromJson(Map<String, dynamic> json) {
    return TripRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      participantCount: json['participantCount'] as int,
      dDay: json['dDay'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      destination: json['destination'] as String,
      participants: List<String>.from(json['participants'] as List),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedSteps: json['completedSteps'] != null
          ? Set<String>.from(json['completedSteps'] as List)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participantCount': participantCount,
      'dDay': dDay,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'destination': destination,
      'participants': participants,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedSteps': completedSteps.toList(),
    };
  }

  // D-Day 계산 메서드
  String calculateDDay() {
    if (startDate == null) return 'D-?';

    final now = DateTime.now();
    final difference = startDate!.difference(now).inDays;

    if (difference < 0) {
      return 'D+${-difference}';
    } else if (difference == 0) {
      return 'D-Day';
    } else {
      return 'D-$difference';
    }
  }

  // 완료된 단계 수 계산 (날짜 선택은 startDate로 자동 판단)
  int getProgressCount() {
    int count = 0;
    // 날짜 선택 완료 확인
    if (startDate != null) {
      count++;
    }
    // 나머지 단계 확인
    if (completedSteps.contains('candidates')) count++;
    if (completedSteps.contains('schedule')) count++;
    if (completedSteps.contains('budget')) count++;
    if (completedSteps.contains('checklist')) count++;
    return count;
  }

  // --- 여기부터 수정 ---

  // [기존] 다음 단계 이름 반환 (텍스트 표시용)
  String getNextStepName() {
    if (startDate == null) return '날짜 정하기';
    if (!completedSteps.contains('candidates')) return '후보지 정하기';
    if (!completedSteps.contains('schedule')) return '일정표 짜기';
    if (!completedSteps.contains('budget')) return '예산 정하기';
    if (!completedSteps.contains('checklist')) return '체크리스트 확인하기';
    return '모두 완료';
  }

  // [추가] 다음 단계로 가는 버튼 텍스트 반환 (버튼용)
  String getNextStepButtonText() {
    if (startDate == null) return '날짜 정하러 가기';
    if (!completedSteps.contains('candidates')) return '후보지 정하러 가기';
    if (!completedSteps.contains('schedule')) return '일정표 짜러 가기';
    if (!completedSteps.contains('budget')) return '예산 정하러 가기';
    if (!completedSteps.contains('checklist')) return '체크리스트 확인하러 가기';
    return '계획 보러 가기';
  }

  // --- 여기까지 수정 ---


  // 다음 단계로 이동할 화면 이름 반환
  String? getNextStepRoute() {
    if (startDate == null) return 'date';
    if (!completedSteps.contains('candidates')) return 'candidates';
    if (!completedSteps.contains('schedule')) return 'schedule';
    if (!completedSteps.contains('budget')) return 'budget';
    if (!completedSteps.contains('checklist')) return 'checklist';
    return null; // 모두 완료
  }

  // 여행계획 복사 메서드 생성 (상태 업데이트용)
  TripRoom copyWith({
    String? id,
    String? title,
    int? participantCount,
    String? dDay,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    List<String>? participants,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Set<String>? completedSteps,
  }) {
    return TripRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      participantCount: participantCount ?? this.participantCount,
      dDay: dDay ?? this.dDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedSteps: completedSteps ?? this.completedSteps,
    );
  }
}
