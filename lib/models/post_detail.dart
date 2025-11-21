class PostDetail {
  final int id;
  final String title;
  final String content;
  final String nickname;
  final int likeCount;
  final String createdAt;
  final bool isLiked; // 내가 좋아요를 눌렀는지 여부
  final bool isOwner; // 내가 작성한 글인지 여부
  final List<String> imageUrls; // 본문 이미지 URL 리스트
  final List<Comment> comments;

  PostDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.nickname,
    required this.likeCount,
    required this.createdAt,
    required this.isLiked,
    required this.isOwner,
    required this.imageUrls,
    required this.comments,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    var commentList = (json['comments'] as List? ?? []).map((i) => Comment.fromJson(i)).toList();

    return PostDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      content: json['content'] ?? '',
      nickname: json['nickname'] ?? '익명',
      likeCount: json['likeCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      isLiked: json['liked'] ?? false, // API 명세에 따라 'liked' 필드로 가정
      isOwner: json['owner'] ?? false, // API 명세에 따라 'owner' 필드로 가정
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      comments: commentList,
    );
  }
}

class Comment {
  final int id;
  final String content;
  final String nickname;
  final String createdAt;
  final bool isOwner; // 내가 작성한 댓글인지 여부

  Comment({
    required this.id,
    required this.content,
    required this.nickname,
    required this.createdAt,
    required this.isOwner,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      nickname: json['nickname'] ?? '익명',
      createdAt: json['createdAt'] ?? '',
      isOwner: json['owner'] ?? false, // API 명세에 따라 'owner' 필드로 가정
    );
  }
}
