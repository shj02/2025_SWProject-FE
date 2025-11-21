import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/user_profile.dart';
import 'package:sw_project_fe/services/auth_api.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
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
  late Future<UserProfile> _userProfileFuture;

  final List<Map<String, String>> _allTravelTags = const [
    {'emoji': '🏃‍♀️', 'label': '액티비티'},
    {'emoji': '🧖‍♀️', 'label': '힐링· 휴양'},
    {'emoji': '🏛️', 'label': '문화 탐방'},
    {'emoji': '🍜', 'label': '맛집 탐방'},
    {'emoji': '🛍️', 'label': '쇼핑'},
    {'emoji': '🏞️', 'label': '자연· 풍경'},
    {'emoji': '🏙️', 'label': '도시 중심형'},
    {'emoji': '🏘️', 'label': '로컬 중심형'},
    {'emoji': '💎', 'label': '럭셔리'},
    {'emoji': '🍱', 'label': '일상· 가성비'},
    {'emoji': '🏨', 'label': '호텔· 백팩커'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    setState(() {
      _userProfileFuture = AuthService().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      bottomNavigationBar: CustomNavbar(currentIndex: _currentIndex, onTap: _onNavbarTap),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }
          return _buildProfileView(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildProfileView(UserProfile userProfile) {
    final scale = MediaQuery.of(context).size.width / 402.0;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _loadUserProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18 * scale, 20 * scale, 18 * scale, 16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('마이페이지', style: TextStyle(fontSize: 26 * scale, fontWeight: FontWeight.w700, color: const Color(0xFF1A0802))),
              SizedBox(height: 24 * scale),
              _buildAccountCard(userProfile, scale),
              SizedBox(height: 20 * scale),
              _buildTravelStyleCard(userProfile, scale),
              SizedBox(height: 28 * scale),
              _buildLogoutButton(scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(UserProfile profile, double scale) {
    final labelStyle = TextStyle(fontSize: 14 * scale, color: const Color(0xFF1A0802), fontWeight: FontWeight.w400);
    final valueStyle = TextStyle(fontSize: 16 * scale, color: const Color(0xFF1A0802), fontWeight: FontWeight.w500);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(16 * scale), border: Border.all(color: const Color(0xFFFFA0A0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.person_outline, size: 22 * scale), const SizedBox(width: 6), Text('계정 설정', style: TextStyle(fontSize: 19 * scale, fontWeight: FontWeight.w600))]),
              TextButton(onPressed: () => _navigateToEditProfile(profile), child: const Text('변경')),
            ],
          ),
          SizedBox(height: 16 * scale),
          Text('아이디', style: labelStyle), SizedBox(height: 2 * scale), Text(profile.email, style: valueStyle), SizedBox(height: 10 * scale),
          Text('이름', style: labelStyle), SizedBox(height: 2 * scale), Text(profile.name, style: valueStyle), SizedBox(height: 10 * scale),
          Text('전화번호', style: labelStyle), SizedBox(height: 2 * scale), Text(profile.phoneNumber, style: valueStyle), SizedBox(height: 10 * scale),
          Text('생년월일', style: labelStyle), SizedBox(height: 2 * scale), Text(profile.birthdate, style: valueStyle), SizedBox(height: 10 * scale),
          Text('국적', style: labelStyle), SizedBox(height: 2 * scale), Text(profile.nationality, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildTravelStyleCard(UserProfile profile, double scale) {
    final userStyles = profile.travelStyles.toSet();
    final tagsToShow = _allTravelTags.where((tag) => userStyles.contains(tag['label'])).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(16 * scale), border: Border.all(color: const Color(0xFFFFA0A0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.menu_book_outlined, size: 22 * scale), const SizedBox(width: 6), Text('여행 스타일', style: TextStyle(fontSize: 19 * scale, fontWeight: FontWeight.w600))]),
              TextButton(onPressed: () { /* TODO: 여행 스타일 변경 기능 */ }, child: const Text('변경')),
            ],
          ),
          SizedBox(height: 16 * scale),
          Wrap(spacing: 10 * scale, runSpacing: 8 * scale, children: tagsToShow.map((tag) => _buildTravelTag(scale: scale, emoji: tag['emoji']!, label: tag['label']!)).toList()),
        ],
      ),
    );
  }

  Widget _buildTravelTag({required double scale, required String emoji, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18 * scale), border: Border.all(color: const Color(0xFFFFA0A0).withAlpha(178))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(emoji, style: TextStyle(fontSize: 16 * scale)), SizedBox(width: 4 * scale), Text(label, style: TextStyle(fontSize: 14 * scale))]),
    );
  }

  Widget _buildLogoutButton(double scale) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: _showLogoutDialog, child: const Text('로그아웃')),
    );
  }

  void _onNavbarTap(int index) {
    if (_currentIndex == index) return;
    Widget? destination;
    switch (index) {
      case 0: destination = const MainMenuScreen(); break;
      case 1: 
        // TODO: 현재 활성화된 여행방 ID를 동적으로 전달해야 함
        destination = const TripPlanDateScreen(tripId: 1); 
        break;
      case 2: destination = const CommunityScreen(); break;
      case 3: break;
    }
    if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
  }

  void _navigateToEditProfile(UserProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(
        initialName: profile.name,
        initialPhone: profile.phoneNumber,
        initialBirth: profile.birthdate,
        initialNation: profile.nationality,
        initialId: profile.email,
      )),
    );
    if (result == true) {
      _loadUserProfile();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              await AuthService().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
