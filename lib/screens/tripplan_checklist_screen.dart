import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/checklist.dart';
import 'package:sw_project_fe/services/trip_api.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
import 'package:sw_project_fe/widgets/tab_navigation.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'tripplan_budget_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';

class TripPlanChecklistScreen extends StatefulWidget {
  final int tripId;

  const TripPlanChecklistScreen({super.key, required this.tripId});

  @override
  State<TripPlanChecklistScreen> createState() => _TripPlanChecklistScreenState();
}

class _TripPlanChecklistScreenState extends State<TripPlanChecklistScreen> {
  late Future<Checklist> _checklistFuture;

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  void _loadChecklists() {
    setState(() {
      _checklistFuture = TripService().getChecklists(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('체크리스트 (Trip ID: ${widget.tripId})')),
      bottomNavigationBar: CustomNavbar(currentIndex: 1, onTap: (index) => _onNavbarTap(context, index)),
      body: Column(
        children: [
          TabNavigation(selectedIndex: 4, onTap: (index) => _onSubNavbarTap(context, index)),
          Expanded(
            child: FutureBuilder<Checklist>(
              future: _checklistFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('데이터가 없습니다.'));
                }
                final checklist = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async => _loadChecklists(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSection('공용 체크리스트', checklist.sharedList, true),
                        const SizedBox(height: 16),
                        _buildSection('개인 체크리스트', checklist.personalList, false),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ChecklistItem> items, bool isShared) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(icon: const Icon(Icons.add), onPressed: () {}), // TODO: 항목 추가 모달
            ),
            ...items.map((item) => CheckboxListTile(
                  title: Text(item.title, style: TextStyle(decoration: item.isChecked ? TextDecoration.lineThrough : null)),
                  subtitle: item.assignee != null ? Text('담당: ${item.assignee}') : null,
                  value: item.isChecked,
                  onChanged: (bool? value) async {
                    await TripService().toggleChecklistCompletion(item.id);
                    _loadChecklists();
                  },
                  secondary: IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () async {
                    await TripService().deleteChecklistItem(item.id);
                    _loadChecklists();
                  }),
                )),
          ],
        ),
      ),
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    if (index == 1) return;
    Widget? destination;
    switch (index) {
      case 0: destination = const MainMenuScreen(); break;
      case 2: destination = const CommunityScreen(); break;
      case 3: destination = const MypageScreen(); break;
    }
    if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
  }

  void _onSubNavbarTap(BuildContext context, int index) {
    if (index == 4) return;
    Widget? destination;
    switch (index) {
      case 0: destination = TripPlanDateScreen(tripId: widget.tripId); break;
      case 1: destination = TripPlanCandidatesScreen(tripId: widget.tripId); break;
      case 2: destination = TripPlanScheduleScreen(tripId: widget.tripId); break;
      case 3: destination = TripPlanBudgetScreen(tripId: widget.tripId); break;
    }
    if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
  }
}
