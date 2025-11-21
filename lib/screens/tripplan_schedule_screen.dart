import 'package:flutter/material.dart';
import 'package:sw_project_fe/models/itinerary.dart';
import 'package:sw_project_fe/services/trip_api.dart';
import 'package:sw_project_fe/widgets/custom_navbar.dart';
import 'package:sw_project_fe/widgets/tab_navigation.dart';
import 'main_menu_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_checklist_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';

class TripPlanScheduleScreen extends StatefulWidget {
  final int tripId;

  const TripPlanScheduleScreen({super.key, required this.tripId});

  @override
  State<TripPlanScheduleScreen> createState() => _TripPlanScheduleScreenState();
}

class _TripPlanScheduleScreenState extends State<TripPlanScheduleScreen> {
  late Future<List<Itinerary>> _itineraryFuture;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  void _loadItinerary() {
    setState(() {
      _itineraryFuture = TripService().getItinerary(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('일정표 (Trip ID: ${widget.tripId})')),
      bottomNavigationBar: CustomNavbar(currentIndex: 1, onTap: (index) => _onNavbarTap(context, index)),
      body: Column(
        children: [
          TabNavigation(selectedIndex: 2, onTap: (index) => _onSubNavbarTap(context, index)),
          Expanded(
            child: FutureBuilder<List<Itinerary>>(
              future: _itineraryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('아직 작성된 일정이 없어요.'));
                }
                final itineraries = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async => _loadItinerary(),
                  child: ListView.builder(
                    itemCount: itineraries.length,
                    itemBuilder: (context, index) {
                      return _buildDaySection(itineraries[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* TODO: 새 일정 추가 모달 */ },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaySection(Itinerary dayItinerary) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Day ${dayItinerary.day} (${dayItinerary.date})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ...dayItinerary.items.map((item) => ListTile(
                  title: Text(item.title),
                  subtitle: Text('${item.time} @ ${item.location}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}), // TODO
                      IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () {}), // TODO
                    ],
                  ),
                ))
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
    if (index == 2) return;
    Widget? destination;
    switch (index) {
      case 0: destination = TripPlanDateScreen(tripId: widget.tripId); break;
      case 1: destination = TripPlanCandidatesScreen(tripId: widget.tripId); break;
      case 3: destination = TripPlanBudgetScreen(tripId: widget.tripId); break;
      case 4: destination = TripPlanChecklistScreen(tripId: widget.tripId); break;
    }
    if (destination != null) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => destination!, transitionDuration: Duration.zero));
  }
}
