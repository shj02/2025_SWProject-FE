/// 날짜 합의 현황 조회 응답 모델 (API 7)
class DateStatus {
  final List<MemberDateStatus> members;
  final List<RecommendedDate> recommendedDates;

  DateStatus({required this.members, required this.recommendedDates});

  factory DateStatus.fromJson(Map<String, dynamic> json) {
    return DateStatus(
      members: (json['members'] as List? ?? []).map((i) => MemberDateStatus.fromJson(i)).toList(),
      recommendedDates: (json['recommendedDates'] as List? ?? []).map((i) => RecommendedDate.fromJson(i)).toList(),
    );
  }
}

class MemberDateStatus {
  final String name;
  final List<String> availableDates; // 예: ["2024-09-11 - 2024-09-13"]

  MemberDateStatus({required this.name, required this.availableDates});

  factory MemberDateStatus.fromJson(Map<String, dynamic> json) {
    return MemberDateStatus(
      name: json['name'] ?? '',
      availableDates: List<String>.from(json['availableDates'] ?? []),
    );
  }
}

class RecommendedDate {
  final String startDate;
  final String endDate;
  final int availableMembers;
  final double matchRate;

  RecommendedDate({
    required this.startDate,
    required this.endDate,
    required this.availableMembers,
    required this.matchRate,
  });

  factory RecommendedDate.fromJson(Map<String, dynamic> json) {
    return RecommendedDate(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      availableMembers: json['availableMembers'] ?? 0,
      matchRate: (json['matchRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
