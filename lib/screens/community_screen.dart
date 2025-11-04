import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import 'new_write_screen.dart';
import 'post_detail_screen.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'profile_edit_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int currentNavbarIndex = NavbarIndex.community; // Community 탭이 선택된 상태
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Demo posts
  final List<Map<String, dynamic>> _posts = List.generate(8, (i) => {
        'id': 'p$i',
        'authorId': 'u${i % 3}',
        'authorName': ['나', '루미', '여행자A'][i % 3],
        'title': '제주도 2박3일 여행 후기',
        'preview': '제주도 2박3일 여행 다녀온 사람입니다. 정말 재밌는 여행이었어요..',
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
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      bottomNavigationBar: CustomNavbar(
        currentIndex: currentNavbarIndex,
        onTap: (index) {
          setState(() {
            currentNavbarIndex = index;
          });
          // 네비게이션 로직
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              break;
            case 1: // TripPlan
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const TripPlanDateScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              break;
            case 2: // Community
              // 현재 페이지가 Community이므로 아무 동작 안함
              break;
            case 3: // Profile
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ProfileEditScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              break;
          }
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.only(left: 17 * scale, right: 17 * scale, top: 16 * scale, bottom: 8 * scale),
                  child: Row(
                    children: [
                      Text(
                        '여행 커뮤니티',
                        style: TextStyle(
                          fontSize: 28 * scale,
                          color: const Color(0xFF1A0802),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * scale),
                  child: GestureDetector(
                    onTap: () => _searchFocusNode.requestFocus(),
                    child: Container(
                    height: 44 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22 * scale),
                      border: Border.all(color: const Color(0xFF1A0802).withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12 * scale),
                        Icon(Icons.search, size: 20 * scale, color: const Color(0xFF1A0802).withOpacity(0.6)),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextStyle(fontSize: 16 * scale),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(color: const Color(0xFF1A0802).withOpacity(0.4)),
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
                ),
                ),

                SizedBox(height: 8 * scale),

                // List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 17 * scale, right: 17 * scale, top: 8 * scale, bottom: 90 * scale),
                    itemCount: _filteredPosts.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: const Color(0xFFE5E5EA)),
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return _buildListRow(post, scale);
                    },
                  ),
                ),
              ],
            ),

            // Bottom pink pill button
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
                      color: const Color(0xFFFF8282),
                      borderRadius: BorderRadius.circular(24 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x40000000),
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
                          child: Icon(Icons.add, color: Colors.white, size: 20 * scale),
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
    );
  }

  Widget _buildListRow(Map<String, dynamic> post, double scale) {
    return InkWell(
      onTap: () => _onOpenPost(post['id'] as String, post['title'] as String),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left texts
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
                        '${post['authorName']} (작성자) ${post['time']}',
                        style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF1A0802)),
                      ),
                      SizedBox(width: 8 * scale),
                      Icon(Icons.favorite, color: const Color(0xFFFC5858), size: 14 * scale),
                      SizedBox(width: 2 * scale),
                      Text('${post['likes']}', style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF1A0802))),
                      SizedBox(width: 8 * scale),
                      Icon(Icons.chat_bubble_outline, color: const Color(0xFF1A0802), size: 14 * scale),
                      SizedBox(width: 2 * scale),
                      Text('${post['comments']}', style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF1A0802))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10 * scale),
            // Right thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8 * scale),
              child: Container(
                width: 92 * scale,
                height: 92 * scale,
                color: const Color(0xFFE6E6E6),
                child: Image.network(
                  'https://picsum.photos/200/200?random=${post['id']}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE6E6E6)),
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
        setState(() {
          _posts.insert(0, result);
        });
      }
    });
  }

  void _onOpenPost(String id, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(postId: id, title: title)),
    );
  }
}


