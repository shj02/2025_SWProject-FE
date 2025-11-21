/// 일정표 전체 조회 응답 모델 (API 12)
class Itinerary {
  final String date; // 예: "2024-09-11"
  final int day;
  final List<ItineraryItem> items;

  Itinerary({required this.date, required this.day, required this.items});

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      date: json['date'] ?? '',
      day: json['day'] ?? 0,
      items: (json['items'] as List? ?? []).map((i) => ItineraryItem.fromJson(i)).toList(),
    );
  }
}

class ItineraryItem {
  final int id;
  final String time;
  final String title;
  final String location;
  final String memo;

  ItineraryItem({
    required this.id,
    required this.time,
    required this.title,
    required this.location,
    required this.memo,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] ?? 0,
      time: json['time'] ?? '00:00',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      memo: json['memo'] ?? '',
    );
  }
}
