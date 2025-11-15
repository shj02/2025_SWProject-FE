import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;

  const PostDetailScreen({super.key, required this.postId, required this.title});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  static const String _currentUserId = 'me';
  static const String _postAuthorId = 'me';
  static const String _postAuthorName = '나';
  final String _postTime = _formatNow();
  String _postTitleCache = '';
  String _postBody = '여기에 게시글 본문이 들어갑니다. 서버 연동 시 실제 데이터를 표시하도록 연결하세요.';

  final List<Map<String, String>> _comments = [
    {'id': 'c1', 'authorId': 'me', 'authorName': '나', 'text': '첫 댓글입니다!', 'time': '2025-11-04 12:00'},
    {'id': 'c2', 'authorId': 'u2', 'authorName': '루미', 'text': '좋은 정보 감사합니다.', 'time': '2025-11-04 12:05'},
    {'id': 'c3', 'authorId': 'u3', 'authorName': '여행자A', 'text': '저도 다녀왔어요!', 'time': '2025-11-04 12:10'},
  ];

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  static const String _confirmJson = '{\n\n  "mcpServers": {\n\n    "TalkToFigma": {\n\n      "command": "bunx",\n\n      "args": [\n\n        "cursor-talk-to-figma-mcp@latest"\n\n      ]\n\n    }\n\n  }\n\n}';

  Future<void> _confirmDelete(String commentId) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final Size screenSize = MediaQuery.of(ctx).size;
        const double designWidth = 402.0;
        final double scale = screenSize.width / designWidth;

        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCFC),
          title: Text(
            '댓글을 삭제하시겠습니까?',
            style: TextStyle(color: const Color(0xFF1A0802), fontWeight: FontWeight.w600, fontSize: 18 * scale),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.2), width: 1),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _confirmJson,
                style: TextStyle(fontFamily: 'Courier New', fontSize: 12 * scale, color: const Color(0xFF1A0802)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      setState(() {
        _comments.removeWhere((c) => c['id'] == commentId);
      });
    }
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final nowId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      // 최신 댓글이 아래로 가도록 리스트 끝에 추가
      _comments.add({
        'id': nowId,
        'authorId': _currentUserId,
        'authorName': '나',
        'text': text,
        'time': _formatNow(),
      });
      _commentController.clear();
    });
    _commentFocus.requestFocus();
  }

  static String _formatNow() {
    final dt = DateTime.now();
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _confirmDeletePost() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final Size screenSize = MediaQuery.of(ctx).size;
        const double designWidth = 402.0;
        final double scale = screenSize.width / designWidth;

        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCFC),
          title: Text(
            '게시글을 삭제하시겠습니까?',
            style: TextStyle(color: const Color(0xFF1A0802), fontWeight: FontWeight.w600, fontSize: 18 * scale),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.2), width: 1),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _confirmJson,
                style: TextStyle(fontFamily: 'Courier New', fontSize: 12 * scale, color: const Color(0xFF1A0802)),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인')),
          ],
        );
      },
    );

    if (ok == true && mounted) {
      Navigator.pop(context); // 상세 화면 종료 → 커뮤니티로 복귀
    }
  }

  Future<void> _editPost() async {
    _postTitleCache = widget.title;
    final titleController = TextEditingController(text: widget.title);
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
                  const Text('게시글 수정', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: '제목을 입력하세요.', border: UnderlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: '내용을 입력해주세요.', border: OutlineInputBorder()),
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A0802)),
        title: Text(
          '게시글 상세',
          style: TextStyle(
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_currentUserId == _postAuthorId) ...[
            IconButton(
              tooltip: '수정',
              onPressed: _editPost,
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A0802)),
            ),
            IconButton(
              tooltip: '삭제',
              onPressed: _confirmDeletePost,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFC5858)),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _postTitleCache.isEmpty ? widget.title : _postTitleCache,
                style: TextStyle(
                  fontSize: 24 * scale,
                  color: const Color(0xFF1A0802),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12 * scale),
              Row(
                children: [
                  Text(
                    '$_postAuthorName (작성자) $_postTime',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: const Color(0xFF1A0802).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * scale),
              const Divider(),
              SizedBox(height: 12 * scale),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: _comments.length + 1,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12 * scale),
                              child: Text(
                                _postBody,
                                style: TextStyle(fontSize: 16 * scale, color: const Color(0xFF1A0802)),
                              ),
                            );
                          }
                          final comment = _comments[index - 1];
                          final mine = comment['authorId'] == _currentUserId;
                          final isAuthor = comment['authorId'] == _postAuthorId;
                          return ListTile(
                            title: Text(
                              isAuthor
                                  ? '${comment['authorName'] ?? ''} (작성자) ${comment['time'] ?? ''}'
                                  : '${comment['authorName'] ?? ''} ${comment['time'] ?? ''}',
                            ),
                            subtitle: Text(comment['text'] ?? ''),
                            trailing: mine
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color(0xFFFC5858)),
                                    onPressed: () => _confirmDelete(comment['id'] ?? ''),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    // 입력 영역
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8 * scale),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _commentFocus.requestFocus(),
                                child: TextField(
                                  controller: _commentController,
                                  focusNode: _commentFocus,
                                  decoration: InputDecoration(
                                    hintText: '댓글을 입력하세요.',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            IconButton(
                              onPressed: _addComment,
                              icon: const Icon(Icons.send, color: Color(0xFFFC5858)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


