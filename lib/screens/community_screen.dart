import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sw_project_fe/models/post.dart';
import 'package:sw_project_fe/services/api_services.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
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

  // API와 별개로 UI에 표시할 예시 게시물 목록
  final List<Post> _samplePosts = [
    Post(
        id: 9999,
        title: "제주도 2박 3일 여행 후기",
        content: "제주도 2박3일 여행 다녀온 사람입니다. 정말 재밌는 여행이었어요...",
        nickname: "여행자A",
        likeCount: 15,
        commentCount: 3,
        createdAt: "1분 전",
        thumbnailUrl: "https://picsum.photos/seed/9999/200/200"),
    Post(
        id: 9998,
        title: "부산 맛집 탐방 후기",
        content: "부산 토박이가 알려주는 진짜 맛집 리스트! 돼지국밥, 밀면, 씨앗호떡 등등...",
        nickname: "부산갈매기",
        likeCount: 42,
        commentCount: 12,
        createdAt: "10분 전",
        thumbnailUrl: "https://picsum.photos/seed/9998/200/200"),
    Post(
        id: 9997,
        title: "나홀로 서울 여행",
        content: "혼자서 서울 여행 다녀왔어요! 경복궁, 인사동, 명동까지 알차게 돌고 왔습니다.",
        nickname: "서울나들이",
        likeCount: 28,
        commentCount: 7,
        createdAt: "1시간 전",
        thumbnailUrl: "https://picsum.photos/seed/9997/200/200"),
  ];

  late Future<List<Post>> _postsFuture;
  List<Post> _allPosts = [];

  @override
  void initState() {
    super.initState();
    _postsFuture = _getCombinedPosts();
  }

  // 예시 데이터와 API 데이터를 합쳐서 반환하는 함수
  Future<List<Post>> _getCombinedPosts() async {
    try {
      final apiPosts = await ApiService().getPosts();
      final postMap = <int, Post>{};
      // 예시 데이터를 먼저 추가
      for (var post in _samplePosts) {
        postMap[post.id] = post;
      }
      // API 데이터를 추가 (ID가 겹치면 덮어씀)
      for (var post in apiPosts) {
        postMap[post.id] = post;
      }
      final combined = postMap.values.toList();
      // 최신순 (ID가 큰 순서)으로 정렬
      combined.sort((a, b) => b.id.compareTo(a.id));
      return combined;
    } catch (e) {
      // API 요청 실패 시 예시 데이터만 반환
      return _samplePosts;
    }
  }

  // 새로고침 시 데이터 다시 로드
  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _getCombinedPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
                  _buildTopBanner(scale),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: FutureBuilder<List<Post>>(
                        future: _postsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('오류: ${snapshot.error}'));
                          }

                          _allPosts = snapshot.data ?? [];
                          final filteredPosts = _getFilteredPosts();

                          if (filteredPosts.isEmpty) {
                            return const Center(
                                child: Text('게시글이 없습니다.'));
                          }

                          return ListView.separated(
                            padding: EdgeInsets.only(
                              left: 17 * scale,
                              right: 17 * scale,
                              top: 16 * scale,
                              bottom: 90 * scale,
                            ),
                            itemCount: filteredPosts.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: const Color(0xFFE5E5EA),
                            ),
                            itemBuilder: (context, index) {
                              final post = filteredPosts[index];
                              return _buildListRow(post, scale);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _buildFloatingActionButton(scale),
            ],
          ),
        ),
      ),
    );
  }

  List<Post> _getFilteredPosts() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _allPosts;
    }
    return _allPosts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      return title.contains(query) || content.contains(query);
    }).toList();
  }

  Container _buildTopBanner(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 17 * scale,
        right: 17 * scale,
        top: 16 * scale,
        bottom: 16 * scale,
      ),
      color: const Color(0xFFFFA0A0),
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
          _buildSearchBox(scale),
        ],
      ),
    );
  }

  Widget _buildSearchBox(double scale) {
    return Container(
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
          Icon(Icons.search, size: 20 * scale, color: const Color(0xFF6E6E6E)),
          SizedBox(width: 8 * scale),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(fontSize: 16 * scale),
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Color(0xFFB5B5B5)),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (_) => setState(() {}), // 검색어 변경 시 UI 갱신
            ),
          ),
          SizedBox(width: 12 * scale),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(double scale) {
    return Positioned(
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
              color: const Color(0xFFFFA0A0),
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
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    if (currentNavbarIndex == index) return;
    setState(() => currentNavbarIndex = index);

    Widget? destination;
    switch (index) {
      case 0:
        destination = const MainMenuScreen();
        break;
      case 1:
        destination = const TripPlanDateScreen(tripId: 1);
        break;
      case 2:
        return; // Current screen
      case 3:
        destination = const MypageScreen();
        break;
    }

    if (destination != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination!,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  Future<bool> _handleWillPop() async => false;

  Widget _buildListRow(Post post, double scale) {
    final randomImageUrl = 'https://picsum.photos/200/200?random=${post.id}';

    return InkWell(
      onTap: () => _onOpenPost(post.id.toString(), post.title, post.content),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18 * scale, color: const Color(0xFF1A0802), fontWeight: FontWeight.w700)),
                  SizedBox(height: 6 * scale),
                  Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13 * scale, color: const Color(0xFF1A0802), fontWeight: FontWeight.w400)),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Text(post.createdAt, style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF1A0802))),
                      SizedBox(width: 8 * scale),
                      Icon(Icons.favorite, color: const Color(0xFFFFA0A0), size: 14 * scale),
                      SizedBox(width: 2 * scale),
                      Text('${post.likeCount}', style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF1A0802))),
                      SizedBox(width: 8 * scale),
                      Icon(Icons.chat_bubble_outline, color: const Color(0xFF1A0802), size: 14 * scale),
                      SizedBox(width: 2 * scale),
                      Text('${post.commentCount}', style: TextStyle(fontSize: 12 * scale, color: const Color(0xFF1A0802))),
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
                  post.thumbnailUrl ?? randomImageUrl, // 썸네일 없으면 랜덤 이미지 표시
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(randomImageUrl, fit: BoxFit.cover), // 썸네일 로드 실패 시에도 랜덤 이미지 표시
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewWriteScreen()),
    );
    if (result == true) {
      _refreshPosts(); // 새 글 작성 후 목록 새로고침
    }
  }

  void _onOpenPost(String id, String title, String content) async {
    final isSample = int.tryParse(id)! >= 9000;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          postId: id,
          title: title,
          isSample: isSample,
          sampleContent: content,
        ),
      ),
    );
    _refreshPosts(); // 상세 화면에서 돌아온 후 목록 새로고침
  }
}
