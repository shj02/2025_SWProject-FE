import 'package:flutter/material.dart';
import 'package:sw_project_fe/services/api_services.dart';

class NewWriteScreen extends StatefulWidget {
  const NewWriteScreen({super.key});

  @override
  State<NewWriteScreen> createState() => _NewWriteScreenState();
}

class _NewWriteScreenState extends State<NewWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  // 저장 버튼 활성화 조건
  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // 컨트롤러에 리스너를 추가하여 버튼 상태를 동적으로 업데이트
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 게시글 저장 함수
  Future<void> _savePost() async {
    if (!_canSave || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // API 서비스를 통해 서버에 게시글 생성 요청
      await ApiService().createPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 성공적으로 등록되었습니다.')),
      );
      Navigator.pop(context, true); // 성공 시 true와 함께 화면을 닫음

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 등록에 실패했습니다: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A0802)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('글쓰기', style: TextStyle(color: Color(0xFF1A0802), fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: _canSave && !_isLoading ? _savePost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? const Color(0xFFFFA0A0) : const Color(0xFFFFC4C4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('저장'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요.',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력해주세요.',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
