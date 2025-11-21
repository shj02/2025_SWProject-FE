import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sw_project_fe/models/post.dart';
import 'package:sw_project_fe/services/api_services.dart';
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

  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = ApiService().getPosts();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = ApiService().getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFA0A0),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final scale = MediaQuery.of(context).size.width / 402.0;

    return PopScope(
      canPop: false,
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
                  _buildHeader(scale),
                  Expanded(
                    child: FutureBuilder<List<Post>>(
                      future: _postsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('데이터를 불러오는 데 실패했습니다: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('아직 작성된 글이 없어요.'));
                        }
                        final posts = snapshot.data!;
                        return RefreshIndicator(
                          onRefresh: () async => _refreshPosts(),
                          child: _buildPostListView(posts, scale),
                        );
                      },
                    ),
                  ),
                ],
              ),
              _buildCreatePostButton(scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17 * scale, 16 * scale, 17 * scale, 16 * scale),
      color: const Color(0xFFFFA0A0),
      child: Column(
        children: [
          Text('여행 커뮤니티', style: TextStyle(fontSize: 26 * scale, color: const Color(0xFF1A0802), fontWeight: FontWeight.w600)),
          SizedBox(height: 14 * scale),
          Container(
            height: 44 * scale,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22 * scale), boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6 * scale, offset: Offset(0, 2 * scale))]),
            child: Row(children: [SizedBox(width: 12 * scale), Icon(Icons.search, size: 20 * scale, color: const Color(0xFF6E6E6E)), SizedBox(width: 8 * scale), Expanded(child: TextField(controller: _searchController, focusNode: _searchFocusNode, decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none)))]),
          ),
        ],
      ),
    );
  }

  Widget _buildPostListView(List<Post> posts, double scale) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(17 * scale, 16 * scale, 17 * scale, 90 * scale),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE5E5EA)),
      itemBuilder: (context, index) => _buildListRow(posts[index], scale),
    );
  }

  Widget _buildCreatePostButton(double scale) {
    return Positioned(
      left: 0, right: 0, bottom: 18 * scale,
      child: Center(
        child: GestureDetector(
          onTap: _onCreatePost,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22 * scale), height: 48 * scale,
            decoration: BoxDecoration(color: const Color(0xFFFFA0A0), borderRadius: BorderRadius.circular(24 * scale), boxShadow: [BoxShadow(color: Colors.black.withAlpha(51), offset: Offset(0, 4 * scale), blurRadius: 8 * scale)]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 28 * scale, height: 28 * scale, decoration: BoxDecoration(color: Colors.white.withAlpha(76), shape: BoxShape.circle), child: Icon(Icons.add, color: Colors.white, size: 20 * scale)), SizedBox(width: 8 * scale), Text('새 글 작성', style: TextStyle(color: Colors.white, fontSize: 18 * scale, fontWeight: FontWeight.w600))]),
          ),
        ),
      ),
    );
  }

  Widget _buildListRow(Post post, double scale) {
    return InkWell(
      onTap: () => _onOpenPost(post.id.toString(), post.title),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w700)),
              SizedBox(height: 6 * scale), Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13 * scale)),
              SizedBox(height: 6 * scale),
              Row(children: [Text(post.createdAt, style: TextStyle(fontSize: 12 * scale)), const SizedBox(width: 8), Icon(Icons.favorite, color: const Color(0xFFFFA0A0), size: 14 * scale), const SizedBox(width: 2), Text(post.likeCount.toString(), style: TextStyle(fontSize: 12 * scale)), const SizedBox(width: 8), Icon(Icons.chat_bubble_outline, size: 14 * scale), const SizedBox(width: 2), Text(post.commentCount.toString(), style: TextStyle(fontSize: 12 * scale))]),
            ]),
          ),
          SizedBox(width: 10 * scale),
          if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(8 * scale), child: Image.network(post.thumbnailUrl!, width: 92 * scale, height: 92 * scale, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 92 * scale, height: 92 * scale, color: const Color(0xFFE6E6E6)))),
        ]),
      ),
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    if (currentNavbarIndex == index) return;
    switch (index) {
      case 0: Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const MainMenuScreen(), transitionDuration: Duration.zero)); break;
      case 1: 
        // TODO: 현재 선택된 여행방의 ID를 동적으로 전달해야 함
        Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const TripPlanDateScreen(tripId: 1), transitionDuration: Duration.zero)); 
        break;
      case 2: break; 
      case 3: Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const MypageScreen(), transitionDuration: Duration.zero)); break;
    }
  }

  void _onCreatePost() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const NewWriteScreen()));
    if (result == true) {
      _refreshPosts();
    }
  }

  void _onOpenPost(String id, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postId: id, title: title)));
  }
}
