import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import 'edit_profile_screen.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  int _currentIndex = NavbarIndex.profile;

  // 사용자 정보 (나중에 실제 데이터로 교체)
  String _userId = 'user123';
  String _userName = '홍길동';
  String _userPhone = '010-1234-5678';
  String _userBirth = '1990-01-01';
  String _userNation = '대한민국';
  String _userEmail = 'hong@example.com';
  String _userProfileImage = ''; // 프로필 이미지 경로

  // 메뉴 항목
  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.person_outline,
      'title': '프로필 수정',
      'action': 'edit_profile',
    },
    {
      'icon': Icons.article_outlined,
      'title': '내 게시글',
      'action': 'my_posts',
    },
    {
      'icon': Icons.favorite_outline,
      'title': '좋아요한 게시글',
      'action': 'liked_posts',
    },
    {
      'icon': Icons.settings_outlined,
      'title': '설정',
      'action': 'settings',
    },
    {
      'icon': Icons.help_outline,
      'title': '고객센터',
      'action': 'customer_service',
    },
    {
      'icon': Icons.info_outline,
      'title': '앱 정보',
      'action': 'app_info',
    },
  ];

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
      // 네비게이션 로직 (나중에 구현)
      // if (index != NavbarIndex.profile) {
      //   Navigator.pushReplacementNamed(context, '/home'); // 예시
      // }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit_profile':
        _showEditProfileDialog();
        break;
      case 'my_posts':
        _showMyPosts();
        break;
      case 'liked_posts':
        _showLikedPosts();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'customer_service':
        _showCustomerService();
        break;
      case 'app_info':
        _showAppInfo();
        break;
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialId: _userId,
          initialName: _userName,
          initialPhone: _userPhone,
          initialBirth: _userBirth,
          initialNation: _userNation,
        ),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      // 프로필 정보 업데이트
      setState(() {
        _userId = result['id'] ?? _userId;
        _userName = result['name'] ?? _userName;
        _userPhone = result['phone'] ?? _userPhone;
        _userBirth = result['birth'] ?? _userBirth;
        _userNation = result['nation'] ?? _userNation;
        _userProfileImage = result['profileImage'] ?? _userProfileImage;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('개인정보가 수정되었습니다.'),
          backgroundColor: Color(0xFFFC5858),
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    _navigateToEditProfile();
  }

  void _showMyPosts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('내 게시글 기능은 준비 중입니다.')),
    );
  }

  void _showLikedPosts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('좋아요한 게시글 기능은 준비 중입니다.')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('설정 기능은 준비 중입니다.')),
    );
  }

  void _showCustomerService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('고객센터 기능은 준비 중입니다.')),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앱 이름: MongleTrip'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 로그아웃 로직
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃되었습니다.')),
              );
            },
            child: const Text('로그아웃', style: TextStyle(color: Color(0xFFFC5858))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Padding(
              padding: EdgeInsets.only(
                top: 34 * scale,
                left: 17 * scale,
                right: 17 * scale,
                bottom: 16 * scale,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '마이페이지',
                    style: TextStyle(
                      fontSize: 28 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // 설정 또는 다른 액션
                    },
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 28 * scale,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                ],
              ),
            ),

            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * scale),
                  child: Column(
                    children: [
                      // 프로필 섹션
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: const Color(0xFF1A0802).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // 프로필 이미지
                            Stack(
                              children: [
                                Container(
                                  width: 100 * scale,
                                  height: 100 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE6E6E6),
                                    border: Border.all(
                                      color: const Color(0xFFFC5858),
                                      width: 3 * scale,
                                    ),
                                  ),
                                  child: _userProfileImage.isNotEmpty
                                      ? ClipOval(
                                          child: Image.asset(
                                            _userProfileImage,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 50 * scale,
                                          color: const Color(0xFF1A0802).withOpacity(0.5),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 32 * scale,
                                    height: 32 * scale,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFC5858),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2 * scale,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 16 * scale,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * scale),
                            // 사용자 이름과 변경 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _userName,
                                  style: TextStyle(
                                    fontSize: 24 * scale,
                                    color: const Color(0xFF1A0802),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8 * scale),
                                TextButton(
                                  onPressed: _navigateToEditProfile,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '변경',
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      color: const Color(0xFFFC5858),
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8 * scale),
                            // 사용자 이메일
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: const Color(0xFF1A0802).withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 20 * scale),
                            // 통계 정보 (선택적)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('게시글', '0', scale),
                                _buildStatItem('좋아요', '0', scale),
                                _buildStatItem('댓글', '0', scale),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24 * scale),

                      // 메뉴 리스트
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: const Color(0xFF1A0802).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: _menuItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    item['icon'] as IconData,
                                    color: const Color(0xFF1A0802),
                                    size: 24 * scale,
                                  ),
                                  title: Text(
                                    item['title'] as String,
                                    style: TextStyle(
                                      fontSize: 18 * scale,
                                      color: const Color(0xFF1A0802),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: const Color(0xFF1A0802).withOpacity(0.3),
                                    size: 24 * scale,
                                  ),
                                  onTap: () => _handleMenuAction(item['action'] as String),
                                ),
                                if (index < _menuItems.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: const Color(0xFFE5E5EA),
                                    indent: 60 * scale,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 24 * scale),

                      // 로그아웃 버튼
                      Container(
                        width: double.infinity,
                        height: 56 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: const Color(0xFF1A0802).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: const Color(0xFFFC5858),
                            size: 24 * scale,
                          ),
                          title: Text(
                            '로그아웃',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              color: const Color(0xFFFC5858),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: _showLogoutDialog,
                        ),
                      ),

                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ),
            ),

            // 네비게이션 바
            CustomNavbar(
              currentIndex: _currentIndex,
              onTap: _onNavbarTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, double scale) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20 * scale,
            color: const Color(0xFF1A0802),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * scale,
            color: const Color(0xFF1A0802).withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
