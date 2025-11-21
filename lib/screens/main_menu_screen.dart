import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/trip.dart';
import 'package:sw_project_fe/services/trip_api.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
import 'package:sw_project_fe/widgets/sidebar.dart';
import 'newplan_screen.dart';
import 'tripplan_date_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_checklist_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentNavbarIndex = NavbarIndex.home;
  bool _showSidebar = false;

  Future<List<TripSummary>>? _tripsFuture;
  TripSummary? _currentTrip;

  @override
  void initState() {
    super.initState();
    _loadMyTrips();
  }

  void _loadMyTrips() {
    setState(() {
      _tripsFuture = TripService().getMyTrips();
      _tripsFuture?.then((trips) {
        if (trips.isNotEmpty) {
          setState(() {
            // 현재 선택된 방이 없거나, 목록에 더 이상 존재하지 않으면 첫번째 방을 선택
            if (_currentTrip == null || !trips.any((t) => t.id == _currentTrip!.id)) {
              _currentTrip = trips.first;
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 402.0;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavbar(currentIndex: _currentNavbarIndex, onTap: _onNavbarTap),
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(scale),
            if (_showSidebar) _buildSidebar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(double scale) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(17 * scale, 34 * scale, 17 * scale, 0),
          child: Row(
            children: [GestureDetector(onTap: () => setState(() => _showSidebar = true), child: Image.asset('assets/icons/menu.png', width: 35 * scale, height: 35 * scale))],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<TripSummary>>(
            future: _tripsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('오류: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildNoRoomView(scale);
              }
              // _currentTrip이 null일 경우를 대비한 방어 코드
              if (_currentTrip == null) return _buildNoRoomView(scale);
              return _buildRoomExistsView(scale, _currentTrip!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return FutureBuilder<List<TripSummary>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        final tripList = snapshot.data ?? [];
        return Sidebar(
          scale: MediaQuery.of(context).size.width / 402.0,
          tripList: tripList.map((trip) => {
            'id': trip.id.toString(), 'name': trip.title, 'date': '${trip.startDate} ~ ${trip.endDate}',
            'participants': trip.participants, 'code': trip.inviteCode, 'progress': 0, 'isOwner': false, // TODO
          }).toList(),
          onHideSidebar: () => setState(() => _showSidebar = false),
          onCreateNewPlan: _showCreateRoomDialog,
          onEnterTripRoom: (tripId) {
            setState(() {
              _currentTrip = tripList.firstWhere((t) => t.id.toString() == tripId);
              _showSidebar = false;
            });
          },
          onShowDeleteModal: (tripId) { /* TODO */ },
        );
      },
    );
  }

  Widget _buildNoRoomView(double scale) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('참여중인 여행 방이 없어요.'), ElevatedButton(onPressed: _showCreateRoomDialog, child: const Text('새로운 계획 만들기'))]));
  }

  Widget _buildRoomExistsView(double scale, TripSummary trip) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('현재 선택된 방: ${trip.title}'), ElevatedButton(onPressed: () => _navigateToTripPlan(trip.id), child: const Text('계획 보러가기'))]));
  }

  void _showCreateRoomDialog() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPlanScreen()));
    if (result == true) {
      _loadMyTrips();
    }
  }

  void _navigateToTripPlan(int tripId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TripPlanDateScreen(tripId: tripId)));
  }

  void _onNavbarTap(int index) {
    if (_currentNavbarIndex == index) return;
    if (index == 1) {
      if (_currentTrip != null) {
        _navigateToTripPlan(_currentTrip!.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('참여중인 여행 방이 없습니다.')));
      }
    } else {
      Widget? destination;
      switch (index) {
        case 0: break;
        case 2: destination = const CommunityScreen(); break;
        case 3: destination = const MypageScreen(); break;
      }
      if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
    }
  }
}
