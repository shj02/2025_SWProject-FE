import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/post_detail.dart';
import 'package:sw_project_fe/services/api_services.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.title,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<PostDetail> _postDetailFuture;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiking = false;
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
  }

  void _loadPostDetail() {
    setState(() {
      _postDetailFuture = ApiService().getPostDetail(int.parse(widget.postId));
    });
  }

  /// 좋아요 버튼 클릭 처리 (토글 방식)
  Future<void> _handleLikeButton() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);

    try {
      // 서버에 좋아요 토글 요청
      await ApiService().toggleLike(int.parse(widget.postId));
      // 성공 시, 화면 데이터를 새로고침하여 최신 상태(좋아요 수, 눌림 여부)를 반영
      _loadPostDetail();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }

  /// 댓글 작성 처리
  Future<void> _handleCommentSubmit() async {
    if (_commentController.text.trim().isEmpty || _isCommenting) return;
    setState(() => _isCommenting = true);

    try {
      await ApiService().createComment(
        int.parse(widget.postId),
        _commentController.text.trim(),
      );
      _commentController.clear();
      _loadPostDetail(); // 성공 시 데이터 새로고침
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCommenting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 커뮤니티'),
        centerTitle: true,
      ),
      body: FutureBuilder<PostDetail>(
        future: _postDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('게시글을 찾을 수 없습니다.'));
          }

          final post = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadPostDetail(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostHeader(post),
                        const SizedBox(height: 16),
                        Text(post.content, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        _buildActionButtons(post), 
                        const Divider(height: 32),
                        _buildCommentSection(post.comments),
                      ],
                    ),
                  ),
                ),
              ),
              _buildCommentInputField(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(PostDetail post) {
    return Row(
      children: [
        const CircleAvatar(child: Icon(Icons.person)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(post.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const Spacer(),
        if (post.isOwner)
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}), // TODO: 수정/삭제 메뉴
      ],
    );
  }

  Widget _buildActionButtons(PostDetail post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
          onPressed: _isLiking ? null : _handleLikeButton,
        ),
        Text('${post.likeCount}개'),
        const SizedBox(width: 16),
        const Icon(Icons.mode_comment_outlined),
        const SizedBox(width: 4),
        Text('${post.comments.length}개'),
      ],
    );
  }

  Widget _buildCommentSection(List<Comment> comments) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: Text('아직 댓글이 없습니다.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(comment.content, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              if (comment.isOwner)
                IconButton(icon: const Icon(Icons.more_horiz, size: 16), onPressed: () {}), // TODO: 댓글 수정/삭제
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleCommentSubmit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isCommenting ? null : _handleCommentSubmit,
          ),
        ],
      ),
    );
  }
}
