/// 여행 방 생성 후 받는 응답 데이터 모델 (API 5)
class TripCreationInfo {
  final int tripId;
  final String inviteCode;

  TripCreationInfo({required this.tripId, required this.inviteCode});

  factory TripCreationInfo.fromJson(Map<String, dynamic> json) {
    return TripCreationInfo(
      tripId: json['tripId'] ?? 0,
      inviteCode: json['inviteCode'] ?? '',
    );
  }
}

/// 내 여행 목록 조회 시 받는 각 여행의 요약 정보 모델 (API 4)
class TripSummary {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final int participants;
  final String inviteCode;
  final String status; // 예: "PLANNING", "CONFIRMED", "COMPLETED"

  TripSummary({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.inviteCode,
    required this.status,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      participants: json['participants'] ?? 0,
      inviteCode: json['inviteCode'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}
