import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 상태바 색 변경용
import '../widgets/custom_navbar.dart';
import 'new_write_screen.dart';
import 'post_detail_screen.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'mypage_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int currentNavbarIndex = NavbarIndex.community;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, dynamic>> _posts = List.generate(8, (i) => {
    'id': 'p$i',
    'authorId': 'u${i % 3}',
    'authorName': ['나', '루미', '여행자A'][i % 3],
    'title': '제주도 2박3일 여행 후기',
    'preview':
    '제주도 2박3일 여행 다녀온 사람입니다. 정말 재밌는 여행이었어요..',
    'likes': 1 + (i % 5),
    'comments': 1 + (i % 3),
    'time': '1분 전',
  });

  List<Map<String, dynamic>> get _filteredPosts {
    final q = _searchController.text.trim();
    if (q.isEmpty) return _posts;
    final lowerQ = q.toLowerCase();
    return _posts.where((p) {
      final title = (p['title'] as String).toLowerCase();
      final preview = (p['preview'] as String).toLowerCase();
      return title.contains(lowerQ) || preview.contains(lowerQ);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 상태바도 배너와 같은 색으로
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFA0A0), // 변경
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFCFC),
        bottomNavigationBar: CustomNavbar(
          currentIndex: currentNavbarIndex,
          onTap: (index) => _onNavbarTap(context, index),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 🔥 상단 배너
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: 17 * scale,
                      right: 17 * scale,
                      top: 16 * scale,
                      bottom: 16 * scale,
                    ),
                    color: const Color(0xFFFFA0A0), // 변경
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '여행 커뮤니티',
                          style: TextStyle(
                            fontSize: 26 * scale,
                            color: const Color(0xFF1A0802),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Container(
                          height: 44 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6 * scale,
                                offset: Offset(0, 2 * scale),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 12 * scale),
                              Icon(
                                Icons.search,
                                size: 20 * scale,
                                color: const Color(0xFF6E6E6E),
                              ),
                              SizedBox(width: 8 * scale),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  style: TextStyle(fontSize: 16 * scale),
                                  decoration: const InputDecoration(
                                    hintText: 'Search',
                                    hintStyle:
                                    TextStyle(color: Color(0xFFB5B5B5)),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.only(
                        left: 17 * scale,
                        right: 17 * scale,
                        top: 16 * scale,
                        bottom: 90 * scale,
                      ),
                      itemCount: _filteredPosts.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: const Color(0xFFE5E5EA),
                      ),
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return _buildListRow(post, scale);
                      },
                    ),
                  ),
                ],
              ),

              // 🔥 새 글 작성 버튼
              Positioned(
                left: 0,
                right: 0,
                bottom: 18 * scale,
                child: Center(
                  child: GestureDetector(
                    onTap: _onCreatePost,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 22 * scale),
                      height: 48 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA0A0), // 변경
                        borderRadius: BorderRadius.circular(24 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x33000000),
                            offset: Offset(0, 4 * scale),
                            blurRadius: 8 * scale,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28 * scale,
                            height: 28 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20 * scale,
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            '새 글 작성',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    setState(() => currentNavbarIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainMenuScreen(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TripPlanDateScreen(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MypageScreen(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  Future<bool> _handleWillPop() async => false;

  Widget _buildListRow(Map<String, dynamic> post, double scale) {
    return InkWell(
      onTap: () => _onOpenPost(post['id'] as String, post['title'] as String),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    post['preview'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Text(
                        post['time'] as String,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: const Color(0xFF1A0802),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.favorite,
                        color: const Color(0xFFFFA0A0), // ❤️ 변경
                        size: 14 * scale,
                      ),
                      SizedBox(width: 2 * scale),

                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: const Color(0xFF1A0802),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.chat_bubble_outline,
                        color: const Color(0xFF1A0802),
                        size: 14 * scale,
                      ),
                      SizedBox(width: 2 * scale),
                      Text(
                        '${post['comments']}',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: const Color(0xFF1A0802),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10 * scale),
            ClipRRect(
              borderRadius: BorderRadius.circular(8 * scale),
              child: Container(
                width: 92 * scale,
                height: 92 * scale,
                color: const Color(0xFFE6E6E6),
                child: Image.network(
                  'https://picsum.photos/200/200?random=${post['id']}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFFE6E6E6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewWriteScreen()),
    ).then((result) {
      if (result is Map<String, dynamic>) {
        setState(() => _posts.insert(0, result));
      }
    });
  }

  void _onOpenPost(String id, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: id, title: title),
      ),
    );
  }
}