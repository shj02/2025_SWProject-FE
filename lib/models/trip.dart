class TripCreationInfo {
  final int tripId;
  final String inviteCode;

  TripCreationInfo({
    required this.tripId,
    required this.inviteCode,
  });

  factory TripCreationInfo.fromJson(Map<String, dynamic> json) {
    return TripCreationInfo(
      tripId: json['tripId'] ?? 0,
      inviteCode: json['inviteCode'] ?? '',
    );
  }
}

class TripSummary {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final int participants;
  final String inviteCode;
  final String status;

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
      participants: json['participants'] ?? 1,
      inviteCode: json['inviteCode'] ?? '',
      status: json['status'] ?? 'PLANNING',
    );
  }
}

class TripDetail {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final List<TripMember> members;
  final String status;

  TripDetail({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.members,
    required this.status,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) {
    return TripDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => TripMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );
  }
}

class TripMember {
  final int id;
  final String name;
  final String profileImageUrl;

  TripMember({
    required this.id,
    required this.name,
    required this.profileImageUrl,
  });

  factory TripMember.fromJson(Map<String, dynamic> json) {
    return TripMember(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }
}
