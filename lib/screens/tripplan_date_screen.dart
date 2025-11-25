import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/trip_date.dart';
import 'package:sw_project_fe/services/trip_api.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
import 'package:sw_project_fe/widgets/tab_navigation.dart';
import 'main_menu_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_checklist_screen.dart';

class TripPlanDateScreen extends StatefulWidget {
  final int tripId;

  const TripPlanDateScreen({super.key, required this.tripId});

  @override
  State<TripPlanDateScreen> createState() => _TripPlanDateScreenState();
}

class _TripPlanDateScreenState extends State<TripPlanDateScreen> {
  late Future<DateStatus> _dateStatusFuture;
  final List<DateTimeRange> _selectedDateRanges = [];

  @override
  void initState() {
    super.initState();
    _loadDateStatus();
  }

  void _loadDateStatus() {
    setState(() {
      _dateStatusFuture = TripService().getDateStatus(widget.tripId);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('날짜 정하기')),
      bottomNavigationBar: CustomNavbar(currentIndex: 1, onTap: (index) => _onNavbarTap(context, index)),
      body: Column(
        children: [
          TabNavigation(selectedIndex: 0, onTap: (index) => _onSubNavbarTap(context, index)),
          Expanded(
            child: FutureBuilder<DateStatus>(
              future: _dateStatusFuture,
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
                final dateStatus = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async => _loadDateStatus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildAddMyDateSection(),
                        const SizedBox(height: 16),
                        _buildRecommendedDatesSection(dateStatus.recommendedDates),
                        const SizedBox(height: 16),
                        _buildMemberDatesSection(dateStatus.members),
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

  Widget _buildAddMyDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('내 가능 날짜 추가', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._selectedDateRanges.map((range) => Text('${_formatDate(range.start)} - ${_formatDate(range.end)}')),
            ElevatedButton(onPressed: _showDatePicker, child: const Text('캘린더에서 날짜 선택')),
            ElevatedButton(onPressed: _submitAvailableDates, child: const Text('내 날짜 저장')),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRanges.add(picked);
      });
    }
  }

  Future<void> _submitAvailableDates() async {
    final dates = _selectedDateRanges.map((range) => {
      'startDate': _formatDate(range.start),
      'endDate': _formatDate(range.end),
    }).toList();

    try {
      await TripService().updateAvailableDates(widget.tripId, dates);
      _loadDateStatus();
      _selectedDateRanges.clear();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildRecommendedDatesSection(List<RecommendedDate> recommendedDates) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI 추천 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recommendedDates.map((date) => ListTile(
              title: Text('${date.startDate} ~ ${date.endDate}'),
              subtitle: Text('${date.availableMembers}명 가능 / ${date.matchRate.toStringAsFixed(1)}% 매치'),
              trailing: ElevatedButton(onPressed: () => _confirmTripDate(date.startDate, date.endDate), child: const Text('선택')),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmTripDate(String startDate, String endDate) async {
    try {
      await TripService().confirmDate(widget.tripId, startDate, endDate);
      _loadDateStatus();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildMemberDatesSection(List<MemberDateStatus> members) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('멤버별 가능 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
            ...members.map((member) => ListTile(
                  title: Text(member.name),
                  subtitle: Text(member.availableDates.join('\n')),
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
    if (index == 0) return;
    Widget? destination;
    switch (index) {
      case 1: destination = TripPlanCandidatesScreen(tripId: widget.tripId); break;
      case 2: destination = TripPlanScheduleScreen(tripId: widget.tripId); break;
      case 3: destination = TripPlanBudgetScreen(tripId: widget.tripId); break;
      case 4: destination = TripPlanChecklistScreen(tripId: widget.tripId); break;
    }
    if (destination != null) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
    }
  }
}
