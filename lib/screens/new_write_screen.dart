import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewWriteScreen extends StatefulWidget {
  const NewWriteScreen({super.key});

  @override
  State<NewWriteScreen> createState() => _NewWriteScreenState();
}

class _NewWriteScreenState extends State<NewWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _bodyFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _media = [];

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && _bodyController.text.trim().isNotEmpty;

  Future<void> _pickMedia() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 사진 촬영'),
                onTap: () => Navigator.pop(ctx, 'camera_photo'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('카메라로 동영상 촬영'),
                onTap: () => Navigator.pop(ctx, 'camera_video'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 사진 선택'),
                onTap: () => Navigator.pop(ctx, 'gallery_photo'),
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('갤러리에서 동영상 선택'),
                onTap: () => Navigator.pop(ctx, 'gallery_video'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    XFile? picked;
    try {
      switch (action) {
        case 'camera_photo':
          picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
          break;
        case 'camera_video':
          picked = await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
          break;
        case 'gallery_photo':
          picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
          break;
        case 'gallery_video':
          picked = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 10));
          break;
      }
    } catch (e) {
      picked = null;
    }

    if (picked != null) {
      setState(() {
        _media.add(picked!);
      });
    }
  }

  void _save() {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
      );
      return;
    }

    final now = DateTime.now();
    final post = {
      'id': now.millisecondsSinceEpoch.toString(),
      'authorId': 'me',
      'authorName': '나',
      'title': _titleController.text.trim(),
      'preview': _bodyController.text.trim(),
      'likes': 0,
      'comments': 0,
      'time': '방금 전',
      'attachments': _media.map((m) => m.path).where((p) => p.isNotEmpty).toList(),
    };

    Navigator.pop(context, post);
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
          '새 글 작성',
          style: TextStyle(
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: Text(
              '저장',
              style: TextStyle(
                color: _canSave ? const Color(0xFFFC5858) : const Color(0xFF1A0802).withOpacity(0.3),
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            children: [
              // 제목 입력
              GestureDetector(
                onTap: () => _titleFocus.requestFocus(),
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '제목을 입력하세요.',
                    border: const UnderlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 12 * scale),

              // 내용 입력
              Expanded(
                child: GestureDetector(
                  onTap: () => _bodyFocus.requestFocus(),
                  child: TextField(
                    controller: _bodyController,
                    focusNode: _bodyFocus,
                    onChanged: (_) => setState(() {}),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: '내용을 입력해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      contentPadding: EdgeInsets.all(12 * scale),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12 * scale),

              // 첨부 미리보기 및 버튼
              Row(
                children: [
                  IconButton(
                    onPressed: _pickMedia,
                    icon: const Icon(Icons.camera_alt, color: Color(0xFFFC5858)),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 64 * scale,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _media.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
                        itemBuilder: (context, index) {
                          final file = _media[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8 * scale),
                            child: Container(
                              width: 64 * scale,
                              height: 64 * scale,
                              color: const Color(0xFFE6E6E6),
                              child: file.path.toLowerCase().endsWith('.mp4')
                                  ? const Icon(Icons.videocam)
                                  : Image.file(
                                      File(file.path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

