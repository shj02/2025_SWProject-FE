import 'package:flutter/material.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
import 'package:sw_project_fe/widgets/tab_navigation.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'tripplan_checklist_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';

class TripPlanBudgetScreen extends StatefulWidget {
  final int tripId;

  const TripPlanBudgetScreen({super.key, required this.tripId});

  @override
  State<TripPlanBudgetScreen> createState() => _TripPlanBudgetScreenState();
}

class _TripPlanBudgetScreenState extends State<TripPlanBudgetScreen> {
  int _currentNavbarIndex = 1;
  int _selectedSubTabIndex = 3;

  // TODO: 예산 관련 API 연동 필요

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('예산 (Trip ID: ${widget.tripId})')),
      bottomNavigationBar: CustomNavbar(currentIndex: _currentNavbarIndex, onTap: _onNavbarTap),
      body: Column(
        children: [
          // TopTab 위젯 대신 간단한 Text로 현재 여행방 정보 표시 (추후 수정)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('현재 여행방 ID: ${widget.tripId}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          TabNavigation(selectedIndex: _selectedSubTabIndex, onTap: _onSubNavbarTap),
          const Expanded(
            child: Center(
              child: Text('예산 기능은 현재 개발 중입니다.'),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavbarTap(int index) {
    if (_currentNavbarIndex == index) return;

    Widget destination;
    switch (index) {
      case 0: destination = const MainMenuScreen(); break;
      case 1: destination = TripPlanDateScreen(tripId: widget.tripId); break;
      case 2: destination = const CommunityScreen(); break;
      case 3: destination = const MypageScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination, transitionDuration: Duration.zero));
  }

  void _onSubNavbarTap(int index) {
    if (_selectedSubTabIndex == index) return;

    Widget destination;
    switch (index) {
      case 0: destination = TripPlanDateScreen(tripId: widget.tripId); break;
      case 1: destination = TripPlanCandidatesScreen(tripId: widget.tripId); break;
      case 2: destination = TripPlanScheduleScreen(tripId: widget.tripId); break;
      case 3: return; // 현재 화면
      case 4: destination = TripPlanChecklistScreen(tripId: widget.tripId); break;
      default: return;
    }
    Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination, transitionDuration: Duration.zero));
  }
}
