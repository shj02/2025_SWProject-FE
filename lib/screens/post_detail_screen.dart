import 'package:flutter/material.dart';

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
  static const String _currentUserId = 'me';
  static const String _postAuthorId = 'me';
  static const String _postAuthorName = '루미';

  final String _postTime = _formatNow();
  String _postTitleCache = '';
  String _postBody =
      '안녕하세요! 지난주에 제주도 다녀온 루미입니다. 정말 알찬 여행이었어서 코스를 공유해드리려고 해요. 첫날은 공항에서 렌터카 픽업 후 성산일출봉으로 향했습니다..';

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

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  static const String _confirmJson = '''
{
  "mcpServers": {
    "TalkToFigma": {
      "command": "bunx",
      "args": [
        "cursor-talk-to-figma-mcp@latest"
      ]
    }
  }
}
''';

  // 시간 포맷: MM/dd HH:mm
  static String _formatNow() {
    final dt = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  // ================= 댓글 삭제 모달 =================
  Future<void> _confirmDelete(String commentId) async {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24 * scale,
              vertical: 20 * scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 4 * scale),
                Text(
                  '해당 댓글을 삭제하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * scale, // 더 크게
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A0802),
                  ),
                ),
                SizedBox(height: 20 * scale),
                Row(
                  children: [
                    // 확인 버튼 (분홍색)
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 10 * scale,
                          ),
                          backgroundColor: const Color(0xFFFFA0A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6 * scale),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    // 취소 버튼 (흰 배경 + 분홍 테두리)
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 10 * scale,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6 * scale),
                            side: const BorderSide(
                              color: Color(0xFFFFA0A0),
                              width: 1,
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFA0A0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) {
      setState(() {
        _comments.removeWhere((c) => c['id'] == commentId);
      });
    }
  }

  // ================= 게시글 삭제 모달 (피그마 왼쪽 스타일) =================
  Future<void> _confirmDeletePost() async {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24 * scale,
              vertical: 20 * scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 4 * scale),
                Text(
                  '해당 글을 삭제하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * scale, // 크게
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A0802),
                  ),
                ),
                SizedBox(height: 20 * scale),
                Row(
                  children: [
                    // 확인 버튼 (분홍색)
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 10 * scale,
                          ),
                          backgroundColor: const Color(0xFFFFA0A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6 * scale),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    // 취소 버튼 (흰 배경 + 분홍 테두리)
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 10 * scale,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6 * scale),
                            side: const BorderSide(
                              color: Color(0xFFFFA0A0),
                              width: 1,
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFA0A0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _editPost() async {
    _postTitleCache = widget.title;
    final titleController = TextEditingController(
      text: _postTitleCache.isEmpty ? widget.title : _postTitleCache,
    );
    final bodyController = TextEditingController(text: _postBody);

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final inset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '게시글 수정',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: '제목을 입력하세요.',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: '내용을 입력해주세요.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    if (saved == true) {
      setState(() {
        _postBody = bodyController.text;
        _postTitleCache = titleController.text;
      });
    }
  }

  void _addComment() {
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
    _commentFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    final int commentCount = _comments.length;
    const int likeCount = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A0802)),
        title: Text(
          '여행 커뮤니티',
          style: TextStyle(
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
            fontSize: 20 * scale,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPostCard(scale, likeCount, commentCount),
                      SizedBox(height: 12 * scale),
                      const Divider(color: Color(0xFFE5E5EA)),
                      ..._buildCommentList(scale),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(top: 8 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _commentFocus,
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
                              onPressed: _addComment,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 댓글 닉네임: 루미1, 루미2 … / 작성자는 루미(작성자)
  List<Widget> _buildCommentList(double scale) {
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
        displayName = '$_postAuthorName$nonAuthorCounter';
      }

      return _buildCommentItem(
        comment,
        scale,
        isFirst: index == 0,
        displayName: displayName,
        isAuthor: isAuthor,
        isMine: comment['authorId'] == _currentUserId,
      );
    }).toList();
  }

  Widget _buildPostCard(double scale, int likeCount, int commentCount) {
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
            _postTitleCache.isEmpty ? widget.title : _postTitleCache,
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
              const Spacer(),
              if (_currentUserId == _postAuthorId)
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale,
                          vertical: 4 * scale,
                        ),
                        minimumSize: Size(0, 28 * scale),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: const Color(0xFFFFA0A0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                      ),
                      onPressed: _confirmDeletePost,
                      child: Text(
                        '삭제',
                        style: metaStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale,
                          vertical: 4 * scale,
                        ),
                        minimumSize: Size(0, 28 * scale),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: const Color(0xFFFFA0A0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                      ),
                      onPressed: _editPost,
                      child: Text(
                        '수정',
                        style: metaStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
      Map<String, String> comment,
      double scale, {
        required bool isFirst,
        required String displayName,
        required bool isAuthor,
        required bool isMine,
      }) {
    final TextStyle commentBase = TextStyle(
      fontSize: 15 * scale,
      color: const Color(0xFF1A0802),
      fontWeight: FontWeight.w400,
    );

    return Column(
      children: [
        if (!isFirst) const Divider(color: Color(0xFFE5E5EA)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 댓글 프로필 (더 둥근 사각형)
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
                                  style: commentBase.copyWith(
                                    fontWeight: isAuthor
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: '  ${comment['time'] ?? ''}',
                                  style: commentBase.copyWith(
                                    fontSize: 14 * scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMine)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 3 * scale,
                              ),
                              minimumSize: Size(0, 24 * scale),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: const Color(0xFFFFA0A0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4 * scale),
                              ),
                              textStyle: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () =>
                                _confirmDelete(comment['id'] ?? ''),
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
}
