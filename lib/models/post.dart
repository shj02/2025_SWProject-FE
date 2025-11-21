class Post {
  final int id;
  final String title;
  final String content;
  final String nickname;
  final int likeCount;
  final int commentCount;
  final String createdAt; // 예: "1분 전", "2024-05-23"
  final String? thumbnailUrl; // 썸네일 이미지 URL (nullable)

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.nickname,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.thumbnailUrl,
  });

  // 서버에서 받은 JSON 데이터를 Post 객체로 변환하는 factory 생성자
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      content: json['content'] ?? '',
      nickname: json['nickname'] ?? '익명',
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      thumbnailUrl: json['thumbnailUrl'], // 썸네일은 없을 수도 있으므로 null 허용
    );
  }
}
