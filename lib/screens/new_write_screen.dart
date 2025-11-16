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
      _titleController.text.trim().isNotEmpty &&
          _bodyController.text.trim().isNotEmpty;

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
          picked = await _picker.pickImage(
              source: ImageSource.camera, imageQuality: 85);
          break;
        case 'camera_video':
          picked = await _picker.pickVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(minutes: 5));
          break;
        case 'gallery_photo':
          picked = await _picker.pickImage(
              source: ImageSource.gallery, imageQuality: 85);
          break;
        case 'gallery_video':
          picked = await _picker.pickVideo(
              source: ImageSource.gallery,
              maxDuration: const Duration(minutes: 10));
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
      'attachments':
      _media.map((m) => m.path).where((p) => p.isNotEmpty).toList(),
    };

    Navigator.pop(context, post);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A0802)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '글쓰기',
          style: TextStyle(
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12 * scale),
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _canSave ? const Color(0xFFFFA0A0) : const Color(0xFFFFC4C4),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 6 * scale,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                minimumSize: const Size(0, 0),
              ),
              child: Text(
                '저장',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocus,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요.',
                  hintStyle: TextStyle(color: Color(0xFFB5B5B5)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB5B5B5)),
                  ),
                ),
              ),

              SizedBox(height: 16 * scale),

              Expanded(
                child: GestureDetector(
                  onTap: () => _bodyFocus.requestFocus(),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _bodyController,
                        focusNode: _bodyFocus,
                        onChanged: (_) => setState(() {}),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: '내용을 입력해주세요.',
                          hintStyle:
                          const TextStyle(color: Color(0xFFB5B5B5)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(
                            0,
                            8 * scale,
                            40 * scale,
                            8 * scale,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 4 * scale,
                        top: 4 * scale,
                        child: IconButton(
                          onPressed: _pickMedia,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFFFFA0A0),
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
}
