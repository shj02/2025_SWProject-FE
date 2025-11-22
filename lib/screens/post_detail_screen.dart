import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/post_detail.dart';
import 'package:sw_project_fe/services/api_services.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;
  final bool isSample;
  final String? sampleContent;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.title,
    this.isSample = false,
    this.sampleContent,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // --- Sample Data Fields ---
  static const String _currentUserId = 'me';
  static const String _postAuthorId = 'me';
  static const String _postAuthorName = '루미';
  final String _postTime = _formatNow();
  String _postTitleCache = '';
  String _postBody = '';

  final List<Map<String, String>> _comments = [
    {
      'id': 'c1',
      'authorId': 'u1',
      'text': '우와 정말 좋은 정보네요! 저도 다음 달에 제주도 가는데 참고할게요 ✈️',
      'time': '09/09 16:10',
    },
    {
      'id': 'c2',
      'authorId': 'me',
      'text': '좋게 봐주셔서 감사합니다.',
      'time': '09/09 16:15',
    },
  ];

  // --- API Data Fields ---
  late Future<PostDetail> _postDetailFuture;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiking = false;
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isSample) {
      _postBody = widget.sampleContent ??
          '안녕하세요! 지난주에 제주도 다녀온 루미입니다. 정말 알찬 여행이었어서 코스를 공유해드리려고 해요. 첫날은 공항에서 렌터카 픽업 후 성산일출봉으로 향했습니다..';
    } else {
      _loadPostDetail();
    }
  }

  // --- API Methods ---
  void _loadPostDetail() {
    setState(() {
      _postDetailFuture = ApiService().getPostDetail(int.parse(widget.postId));
    });
  }

  Future<void> _handleLikeButton() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);
    try {
      await ApiService().toggleLike(int.parse(widget.postId));
      _loadPostDetail();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  Future<void> _handleCommentSubmit() async {
    if (_commentController.text.trim().isEmpty || _isCommenting) return;
    setState(() => _isCommenting = true);
    try {
      await ApiService().createComment(
        int.parse(widget.postId),
        _commentController.text.trim(),
      );
      _commentController.clear();
      _loadPostDetail();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCommenting = false);
    }
  }

  // --- Sample Methods ---
  static String _formatNow() {
    final dt = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  void _addSampleComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final nowId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _comments.add({
        'id': nowId,
        'authorId': _currentUserId,
        'text': text,
        'time': _formatNow(),
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 커뮤니티'),
        centerTitle: true,
      ),
      body: widget.isSample ? _buildSampleView() : _buildApiView(),
    );
  }

  // =================== API-based View ===================
  Widget _buildApiView() {
    return FutureBuilder<PostDetail>(
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
                      _buildApiPostHeader(post),
                      const SizedBox(height: 16),
                      Text(post.content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildApiActionButtons(post),
                      const Divider(height: 32),
                      _buildApiCommentSection(post.comments),
                    ],
                  ),
                ),
              ),
            ),
            _buildApiCommentInputField(),
          ],
        );
      },
    );
  }

  // =================== Sample View ===================
  Widget _buildSampleView() {
    final double scale = MediaQuery.of(context).size.width / 402.0;
    final int commentCount = _comments.length;
    const int likeCount = 1;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSamplePostCard(scale, likeCount, commentCount),
                    SizedBox(height: 12 * scale),
                    const Divider(color: Color(0xFFE5E5EA)),
                    ..._buildSampleCommentList(scale),
                  ],
                ),
              ),
            ),
            _buildSampleCommentInputField(scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePostCard(double scale, int likeCount, int commentCount) {
    final TextStyle metaStyle = TextStyle(
      fontSize: 14 * scale,
      color: const Color(0xFF1A0802),
      fontWeight: FontWeight.w400,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        16 * scale,
        16 * scale,
        8 * scale, // 하단 여백 줄임
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 프로필 (게시글)
          Row(
            children: [
              Container(
                width: 40 * scale,
                height: 40 * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0xFFFFA0A0),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10 * scale),
                  child: Image.asset(
                    'assets/icons/duck.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _postAuthorName,
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    _postTime,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: const Color(0xFF1A0802).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12 * scale),

          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22 * scale,
              color: const Color(0xFF1A0802),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),

          Text(
            _postBody,
            style: TextStyle(
              fontSize: 15 * scale,
              color: const Color(0xFF1A0802),
            ),
          ),
          SizedBox(height: 12 * scale),

          Container(
            height: 180 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(12 * scale),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/${widget.postId}/400/300'),
                fit: BoxFit.cover
              )
            ),
          ),
          SizedBox(height: 12 * scale),

          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: Color(0xFFFFA0A0),
                    size: 18,
                  ),
                  SizedBox(width: 4 * scale),
                  Text('공감 $likeCount', style: metaStyle),
                  SizedBox(width: 12 * scale),
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF1A0802),
                    size: 18,
                  ),
                  SizedBox(width: 4 * scale),
                  Text('댓글 $commentCount', style: metaStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSampleCommentList(double scale) {
    int nonAuthorCounter = 0;
    return _comments.asMap().entries.map((entry) {
      final index = entry.key;
      final comment = entry.value;
      final isAuthor = comment['authorId'] == _postAuthorId;

      String displayName;
      if (isAuthor) {
        displayName = '$_postAuthorName(작성자)';
      } else {
        nonAuthorCounter++;
        displayName = '루미$nonAuthorCounter';
      }

      return _buildSampleCommentItem(
        comment,
        scale,
        isFirst: index == 0,
        displayName: displayName,
        isAuthor: isAuthor,
        isMine: comment['authorId'] == _currentUserId,
      );
    }).toList();
  }

  Widget _buildSampleCommentItem(
    Map<String, String> comment,
    double scale,
      {
        required bool isFirst,
        required String displayName,
        required bool isAuthor,
        required bool isMine,
      }) {
    final TextStyle commentBase = TextStyle(
      fontFamily: 'YeongdeokSea',
      fontSize: 15 * scale,
      color: const Color(0xFF1A0802),
      fontWeight: FontWeight.w400,
    );

    return Column(
      children: [
        if (!isFirst) const Divider(color: Color(0xFFE5E5EA)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4 * scale), // Reduced vertical padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32 * scale,
                height: 32 * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: const Color(0xFFFFA0A0),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12 * scale),
                  child: Image.asset(
                    'assets/icons/duck.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: commentBase,
                              children: [
                                TextSpan(
                                  text: displayName,
                                  style: TextStyle(fontWeight: isAuthor ? FontWeight.w600 : FontWeight.w400),
                                ),
                                TextSpan(
                                  text: '  ${comment['time'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMine)
                          TextButton(
                            onPressed: () {},
                            child: const Text('삭제'),
                          ),
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      comment['text'] ?? '',
                      style: commentBase,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSampleCommentInputField(double scale) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: 8 * scale),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: TextStyle(
                  fontSize: 15 * scale,
                  color: const Color(0xFF1A0802),
                ),
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요.',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB5B5B5),
                    fontSize: 15 * scale,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 10 * scale,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA0A0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA0A0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA0A0),
                      width: 1.3,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    onPressed: _addSampleComment,
                    icon: Icon(
                      Icons.send,
                      color: const Color(0xFFFF8282),
                      size: 20 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildApiPostHeader(PostDetail post) {
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

  Widget _buildApiActionButtons(PostDetail post) {
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

  Widget _buildApiCommentSection(List<Comment> comments) {
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

  Widget _buildApiCommentInputField() {
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
