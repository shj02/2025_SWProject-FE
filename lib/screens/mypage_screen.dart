import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import 'community_screen.dart';
import 'edit_profile_screen.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'login_screen.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  int _currentIndex = NavbarIndex.profile;

  // 사용자 정보 (나중에 실제 데이터로 교체)
  String _userId = 'qwer1234@naver.com';
  String _userName = '홍길동';
  String _userPhone = '010-****-6658';
  String _userBirth = '2000-01-01';
  String _userNation = '대한민국';
  String _userEmail = 'qwer1234@naver.com';

  // 여행 스타일 태그 (이모지 + 라벨)
  final List<Map<String, String>> _travelTags = const [
    {'emoji': '🎢', 'label': '액티비티'},
    {'emoji': '🌇', 'label': '힐링 · 휴양'},
    {'emoji': '🏛️', 'label': '문화 탐방'},
    {'emoji': '🍽️', 'label': '맛집 탐방'},
    {'emoji': '🛍️', 'label': '쇼핑'},
    {'emoji': '🌲', 'label': '자연 · 풍경'},
    {'emoji': '🏙️', 'label': '도시 중심형'},
    {'emoji': '🏡', 'label': '로컬 중심형'},
    {'emoji': '🍷', 'label': '럭셔리'},
    {'emoji': '🍰', 'label': '일상 · 가성비'},
    {'emoji': '🏨', 'label': '호텔 · 백팩커'},
  ];

  void _onNavbarTap(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case NavbarIndex.home:
        _replaceWith(const MainMenuScreen());
        break;
      case NavbarIndex.tripPlan:
        _replaceWith(const TripPlanDateScreen());
        break;
      case NavbarIndex.community:
        _replaceWith(const CommunityScreen());
        break;
      case NavbarIndex.profile:
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
      setState(() {
        _userId = result['id'] ?? _userId;
        _userName = result['name'] ?? _userName;
        _userPhone = result['phone'] ?? _userPhone;
        _userBirth = result['birth'] ?? _userBirth;
        _userNation = result['nation'] ?? _userNation;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('개인정보가 수정되었습니다.'),
          backgroundColor: Color(0xFFFFA0A0),
        ),
      );
    }
  }

  void _showTravelStyleEdit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('여행 스타일 설정은 준비 중입니다.')),
    );
  }

  // ----- 커스텀 로그아웃 모달 (피그마 스타일) -----
  void _showLogoutDialog() {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    showDialog(
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
            padding: EdgeInsets.fromLTRB(
              24 * scale,
              24 * scale,
              24 * scale,
              20 * scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '로그아웃 하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A0802),
                  ),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  '로그아웃하면 다시 로그인이 필요합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: const Color(0xFF1A0802).withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 20 * scale),
                // 로그아웃 버튼 (분홍색)
                SizedBox(
                  width: double.infinity,
                  height: 44 * scale,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA0A0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // 모달 닫기
                      // 로그인 화면으로 이동 + 스택 모두 제거
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    },
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scale),
                // 취소 버튼 (화이트 + 테두리)
                SizedBox(
                  width: double.infinity,
                  height: 44 * scale,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * scale),
                        side: const BorderSide(
                          color: Color(0xFFFFA0A0),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFCFC),
        bottomNavigationBar: CustomNavbar(
          currentIndex: _currentIndex,
          onTap: _onNavbarTap,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22 * scale,
                vertical: 24 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 상단 타이틀 (가운데 정렬)
                  Center(
                    child: Text(
                      '마이페이지',
                      style: TextStyle(
                        fontSize: 26 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0802),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),

                  // 계정 설정 카드
                  _buildAccountCard(scale),

                  SizedBox(height: 20 * scale),

                  // 여행 스타일 카드
                  _buildTravelStyleCard(scale),

                  SizedBox(height: 28 * scale),

                  // 로그아웃 버튼
                  _buildLogoutButton(scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(double scale) {
    final labelStyle = TextStyle(
      fontSize: 14 * scale,
      color: const Color(0xFF1A0802),
      fontWeight: FontWeight.w400,
    );
    final valueStyle = TextStyle(
      fontSize: 16 * scale,
      color: const Color(0xFF1A0802),
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        18 * scale,
        20 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0xFFFFA0A0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 제목 + 변경 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 22 * scale,
                    color: const Color(0xFF1A0802),
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    '계정 설정',
                    style: TextStyle(
                      fontSize: 19 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _navigateToEditProfile,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 6 * scale,
                  ),
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18 * scale),
                    side: const BorderSide(
                      color: Color(0xFFFFA0A0),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '변경',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A0802),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          Text('아이디', style: labelStyle),
          SizedBox(height: 2 * scale),
          Text(_userId, style: valueStyle),
          SizedBox(height: 10 * scale),

          Text('이름', style: labelStyle),
          SizedBox(height: 2 * scale),
          Text(_userName, style: valueStyle),
          SizedBox(height: 10 * scale),

          Text('전화번호', style: labelStyle),
          SizedBox(height: 2 * scale),
          Text(_userPhone, style: valueStyle),
          SizedBox(height: 10 * scale),

          Text('생년월일', style: labelStyle),
          SizedBox(height: 2 * scale),
          Text(_userBirth, style: valueStyle),
          SizedBox(height: 10 * scale),

          Text('국적', style: labelStyle),
          SizedBox(height: 2 * scale),
          Text(_userNation, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildTravelStyleCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        18 * scale,
        20 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0xFFFFA0A0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 제목 + 변경 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 22 * scale,
                    color: const Color(0xFF1A0802),
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    '여행 스타일',
                    style: TextStyle(
                      fontSize: 19 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A0802),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _showTravelStyleEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 6 * scale,
                  ),
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18 * scale),
                    side: const BorderSide(
                      color: Color(0xFFFFA0A0),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '변경',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A0802),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          Wrap(
            spacing: 10 * scale,
            runSpacing: 8 * scale,
            children: _travelTags.map((tag) {
              return _buildTravelTag(
                scale: scale,
                emoji: tag['emoji']!,
                label: tag['label']!,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelTag({
    required double scale,
    required String emoji,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: const Color(0xFFFFA0A0).withOpacity(0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 16 * scale),
          ),
          SizedBox(width: 4 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * scale,
              color: const Color(0xFF1A0802),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(double scale) {
    return SizedBox(
      width: double.infinity,
      height: 56 * scale,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFA0A0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * scale),
          ),
        ),
        onPressed: _showLogoutDialog,
        child: Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _replaceWith(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}