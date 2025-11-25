class Checklist {
  final List<ChecklistItem> sharedList;
  final List<ChecklistItem> personalList;

  Checklist({required this.sharedList, required this.personalList});

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      sharedList: (json['sharedList'] as List? ?? []).map((i) => ChecklistItem.fromJson(i)).toList(),
      personalList: (json['personalList'] as List? ?? []).map((i) => ChecklistItem.fromJson(i)).toList(),
    );
  }
}

class ChecklistItem {
  final int id;
  final String title;
  final bool isChecked;
  final String? assignee; // 담당자 이름, null일 수 있음

  ChecklistItem({
    required this.id,
    required this.title,
    required this.isChecked,
    this.assignee,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isChecked: json['checked'] ?? false,
      assignee: json['assignee'],
    );
  }
}
