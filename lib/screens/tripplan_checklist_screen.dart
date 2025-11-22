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

  Future<void> _addItem(String title, bool isShared) async {
    if (title.isEmpty) return;
    try {
      await TripService().createChecklistItem(widget.tripId, {
        'title': title,
        'isShared': isShared,
      });
      if (!mounted) return;
      _loadChecklists();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('항목 추가 실패: $e')),
      );
    }
  }

  Future<void> _showAddItemDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('체크리스트 항목 추가'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '항목 이름을 입력하세요'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            TextButton(
                onPressed: () {
                  _addItem(controller.text, false); // 개인
                  Navigator.pop(context);
                },
                child: const Text('개인')),
            ElevatedButton(
                onPressed: () {
                  _addItem(controller.text, true); // 공용
                  Navigator.pop(context);
                },
                child: const Text('공용')),
          ],
        );
      },
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF8282),
      ),
    );
  }

  Widget _buildSection(String title, List<ChecklistItem> items, bool isShared) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('항목이 없습니다.'),
              ),
            ...items.map((item) => CheckboxListTile(
                  title: Text(item.title, style: TextStyle(decoration: item.isChecked ? TextDecoration.lineThrough : null)),
                  subtitle: isShared && item.assignee != null ? Text('담당: ${item.assignee}') : null,
                  value: item.isChecked,
                  onChanged: (bool? value) async {
                    try {
                      await TripService().toggleChecklistCompletion(item.id);
                      if (!mounted) return;
                      _loadChecklists();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상태 변경 실패: $e')));
                    }
                  },
                  secondary: IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                      onPressed: () async {
                        try {
                          await TripService().deleteChecklistItem(item.id);
                          if (!mounted) return;
                          _loadChecklists();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
                        }
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
      case 0:
        destination = const MainMenuScreen();
        break;
      case 2:
        destination = const CommunityScreen();
        break;
      case 3:
        destination = const MypageScreen();
        break;
    }
    if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
  }

  void _onSubNavbarTap(BuildContext context, int index) {
    if (index == 4) return;
    Widget? destination;
    switch (index) {
      case 0:
        destination = TripPlanDateScreen(tripId: widget.tripId);
        break;
      case 1:
        destination = TripPlanCandidatesScreen(tripId: widget.tripId);
        break;
      case 2:
        destination = TripPlanScheduleScreen(tripId: widget.tripId);
        break;
      case 3:
        destination = TripPlanBudgetScreen(tripId: widget.tripId);
        break;
    }
    if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
  }
}
