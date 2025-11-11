import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trip_room.dart';
import '../services/trip_plan_state_service.dart';
import '../services/trip_room_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/top_tab.dart';
import 'community_screen.dart';
import 'main_menu_screen.dart';
import 'mypage_screen.dart';
import 'tripplan_budget_screen.dart';
import 'tripplan_checklist_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_schedule_screen.dart';

class TripPlanCandidatesScreen extends StatefulWidget {
  const TripPlanCandidatesScreen({super.key});

  @override
  State<TripPlanCandidatesScreen> createState() => _TripPlanCandidatesScreenState();
}

class _TripPlanCandidatesScreenState extends State<TripPlanCandidatesScreen> {
  static const double _designWidth = 402.0;

  int _currentNavbarIndex = 1; // TripPlan 탭이 선택된 상태
  int _selectedSubTabIndex = 1; // 후보지 탭 기본 선택
  bool _showAddPlaceModal = false;

  late final TripRoomService _tripRoomService;
  late final TripPlanStateService _stateService;
  TripRoom? _currentTripRoom;

  late final List<Map<String, dynamic>> _aiRecommendedPlaces;
  late final List<Map<String, dynamic>> _friendSuggestedPlaces;

  @override
  void initState() {
    super.initState();
    _tripRoomService = TripRoomService();
    _stateService = TripPlanStateService();
    _aiRecommendedPlaces = _stateService.aiRecommendedPlaces;
    _friendSuggestedPlaces = _stateService.friendSuggestedPlaces;
    _currentTripRoom = _tripRoomService.currentTripRoom;

    if (_currentTripRoom != null) {
      _tripRoomService.updateDDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = screenSize.width / _designWidth;

    if (_tripRoomService.tripRooms.isEmpty || _currentTripRoom == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFFF5F5),
          systemNavigationBarColor: Color(0xFFFFFCFC),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFCFC),
          bottomNavigationBar: CustomNavbar(
            currentIndex: _currentNavbarIndex,
            onTap: _handleNavbarTap,
          ),
          body: SafeArea(
            child: Center(
              child: Text(
                '계획중인 여행이 없습니다.',
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A0802),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final double buttonBottomSpacing = 12 * scale;
    final double buttonHeight = 55 * scale;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFF5F5),
        systemNavigationBarColor: Color(0xFFFFFCFC),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFCFC),
        bottomNavigationBar: _showAddPlaceModal
            ? null
            : CustomNavbar(
                currentIndex: _currentNavbarIndex,
                onTap: _handleNavbarTap,
              ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: _showTripRoomSelector,
                    child: TopTab(
                      title: _currentTripRoom?.title ?? '여행방을 선택해주세요',
                      participantCount: _currentTripRoom?.participantCount ?? 0,
                      dDay: _currentTripRoom?.dDay ?? 'D-?',
                    ),
                  ),
                  TabNavigation(
                    selectedIndex: _selectedSubTabIndex,
                    onTap: (index) {
                      if (_selectedSubTabIndex == index) return;
                      setState(() {
                        _selectedSubTabIndex = index;
                      });
                      _navigateToSubTab(index);
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            17 * scale,
                            14 * scale,
                            17 * scale,
                            buttonHeight + buttonBottomSpacing + 14 * scale,
                          ),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAIRecommendedSection(scale),
                              SizedBox(height: 14 * scale),
                              _buildFriendSuggestedSection(scale),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: buttonBottomSpacing,
                          child: Align(
                            alignment: Alignment.center,
                            child: _buildAddPlaceButton(context, scale, buttonHeight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showAddPlaceModal) _buildAddPlaceModal(scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendedSection(double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            iconPath: 'assets/icons/Favorites.png',
            title: 'AI 추천 관광지',
            scale: scale,
          ),
          SizedBox(height: 12 * scale),
          SizedBox(
            height: 180 * scale,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _aiRecommendedPlaces.length,
              separatorBuilder: (_, __) => SizedBox(width: 12 * scale),
              itemBuilder: (context, index) {
                final place = _aiRecommendedPlaces[index];
                return SizedBox(
                  width: 333 * scale,
                  child: _buildPlaceCard(
                    place,
                    scale,
                    badgeColor: const Color(0xFFD9D9D9),
                    highlightButton: true,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            '옆으로 넘겨 다음 추천을 확인하세요 →',
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5D6470),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendSuggestedSection(double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            iconPath: 'assets/icons/Favorites.png',
            title: '친구 제안 장소',
            scale: scale,
          ),
          SizedBox(height: 16 * scale),
          ..._friendSuggestedPlaces.map(
            (place) => Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: _buildPlaceCard(
                place,
                scale,
                badgeColor: const Color(0xFFFDDFCC),
                highlightButton: true,
                isFriendSuggestion: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddPlaceToSchedule(Map<String, dynamic> place) async {
    final String placeName = place['name'] as String? ?? '';
    if (placeName.isEmpty) {
      return;
    }

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TripPlanScheduleScreen(initialPlaceName: placeName),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (!mounted) return;

    setState(() {
      place['isAddedToSchedule'] = true;
    });
  }

  Widget _buildSectionHeader({
    required String iconPath,
    required String title,
    required double scale,
    Color? iconTint,
  }) {
    return Row(
      children: [
        _buildIcon(iconPath, scale, tint: iconTint),
        SizedBox(width: 8 * scale),
        Text(
          title,
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(
    Map<String, dynamic> place,
    double scale, {
    required Color badgeColor,
    required bool highlightButton,
    bool isFriendSuggestion = false,
  }) {
    final bool isAdded = place['isAddedToSchedule'] ?? false;
    final int voteCount = place['voteCount'] ?? 0;
    final bool hasVoted = place['hasVoted'] ?? false;

    final Color buttonBackgroundColor = isAdded
        ? const Color(0xFFD9D9D9) // 추가 완료 시 색상 (회색)
        : const Color(0xFFFFA0A0); // 추가 전 색상 (진한 핑크)

    final Color buttonForegroundColor = isAdded
        ? const Color(0xFF222222)  // 추가 완료 시 텍스트 색상 (검은색 계열)
        : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _showPlaceDetail(place, isFriendSuggestion: isFriendSuggestion),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFriendSuggestion) ...[
                  _buildPlaceImage(place['imageUrl'] as String?, scale),
                  SizedBox(width: 12 * scale),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              place['name'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildIcon(
                                'assets/icons/heart.png',
                                scale,
                                width: 16 * scale,
                                height: 16 * scale,
                                tint: const Color(0xFFFF8282),
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                '$voteCount',
                                style: TextStyle(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      _buildCategoryChip(place['category'] as String? ?? '', scale),
                      SizedBox(height: 6 * scale),
                      if (isFriendSuggestion)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4 * scale),
                          child: Text(
                            '${place['suggestedBy']}님 제안',
                            style: TextStyle(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5D6470),
                            ),
                          ),
                        ),
                      Text(
                        place['description'] as String? ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A0802),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (hasVoted) {
                          final int newCount = voteCount > 0 ? voteCount - 1 : 0;
                          place['voteCount'] = newCount;
                          place['hasVoted'] = false;
                        } else {
                          place['voteCount'] = voteCount + 1;
                          place['hasVoted'] = true;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    ),
                    child: Text(
                      hasVoted ? '투표 완료' : '투표',
                      style: TextStyle(
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isAdded ? null : () => _handleAddPlaceToSchedule(place),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      foregroundColor: buttonForegroundColor,
                      disabledBackgroundColor: const Color(0xFFD9D9D9),
                    disabledForegroundColor: const Color(0xFF222222),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    ),
                    child: Text(
                      isAdded ? '일정 추가 완료' : '일정에 추가',
                      style: TextStyle(
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceDetail(
    Map<String, dynamic> place, {
    bool isFriendSuggestion = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final double scale = MediaQuery.of(modalContext).size.width / _designWidth;
        final bool isAdded = place['isAddedToSchedule'] ?? false;
        final int voteCount = place['voteCount'] ?? 0;
        final Color buttonBackgroundColor =
            isAdded ? const Color(0xFFD9D9D9) : const Color(0xFFFFA0A0);
        final Color buttonForegroundColor = isAdded ? const Color(0xFF222222) : Colors.white;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20 * scale,
            right: 20 * scale,
            top: 16 * scale,
            bottom: 20 * scale + MediaQuery.of(modalContext).padding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 48 * scale,
                    height: 4 * scale,
                    margin: EdgeInsets.only(bottom: 16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2 * scale),
                    ),
                  ),
                ),
                if (!isFriendSuggestion)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16 * scale),
                    child: _buildPlaceImage(place['imageUrl'] as String?, scale),
                  ),
                Text(
                  place['name'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12 * scale),
                _buildCategoryChip(place['category'] as String? ?? '', scale),
                SizedBox(height: 12 * scale),
                if (isFriendSuggestion && place['suggestedBy'] != null)
                  Text(
                    '${place['suggestedBy']}님 제안',
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5D6470),
                    ),
                  ),
                if (isFriendSuggestion && place['suggestedBy'] != null)
                  SizedBox(height: 12 * scale),
                Text(
                  place['description'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A0802),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Row(
                  children: [
                    _buildIcon(
                      'assets/icons/heart.png',
                      scale,
                      width: 18 * scale,
                      height: 18 * scale,
                      tint: const Color(0xFFFF8282),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      '$voteCount명이 투표했어요',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * scale),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isAdded
                        ? null
                        : () {
                            Navigator.pop(modalContext);
                            _handleAddPlaceToSchedule(place);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      foregroundColor: buttonForegroundColor,
                      disabledBackgroundColor: const Color(0xFFD9D9D9),
                      disabledForegroundColor: const Color(0xFF222222),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12 * scale),
                    ),
                    child: Text(
                      isAdded ? '일정 추가 완료' : '일정에 추가',
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12 * scale),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(modalContext),
                    child: Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5D6470),
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

  Widget _buildCategoryChip(String category, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildPlaceImage(String? imageUrl, double scale) {
    return Container(
      width: 80 * scale,
      height: 80 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8 * scale),
        child: imageUrl != null
            ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFD9D9D9)),
              )
            : null,
      ),
    );
  }

  Widget _buildIcon(
    String assetPath,
    double scale, {
    Color? tint,
    double? width,
    double? height,
  }) {
    return Image.asset(
      assetPath,
      width: width ?? 24 * scale,
      height: height ?? 24 * scale,
      color: tint,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.favorite,
        size: width ?? 24 * scale,
        color: tint ?? Colors.black,
      ),
    );
  }

  Widget _buildAddPlaceButton(BuildContext context, double scale, double height) {
    return SizedBox(
      width: 211 * scale,
      height: height,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showAddPlaceModal = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8282),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          textStyle: TextStyle(
            fontSize: 22 * scale,
            fontWeight: FontWeight.w600,
            fontFamily: Theme.of(context).textTheme.titleMedium?.fontFamily ??
                Theme.of(context).textTheme.bodyMedium?.fontFamily ??
                'YeongdeokSea',
          ),
        ),
        child: const Text('새로운 장소 제안하기'),
      ),
    );
  }

  Widget _buildAddPlaceModal(double scale) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: SizedBox(
          width: 366 * scale,
          child: Material(
            color: const Color(0xFFFFFCFC),
            borderRadius: BorderRadius.circular(25 * scale),
            child: _AddPlaceModalContent(
              scale: scale,
              onClose: () {
                setState(() {
                  _showAddPlaceModal = false;
                });
              },
              onSubmit: (placeName, category, description) {
                setState(() {
                  _friendSuggestedPlaces.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': placeName,
                    'category': category,
                    'description': description,
                    'suggestedBy': UserService().userName ?? '나',
                    'voteCount': 0,
                    'isAddedToSchedule': false,
                    'hasVoted': false,
                  });
                  _showAddPlaceModal = false;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavbarTap(int index) {
    if (_currentNavbarIndex == index) return;

    setState(() {
      _currentNavbarIndex = index;
    });

    switch (index) {
      case 0:
        _replaceWith(const MainMenuScreen());
        break;
      case 1:
        _replaceWith(const TripPlanDateScreen());
        break;
      case 2:
        _replaceWith(const CommunityScreen());
        break;
      case 3:
        _replaceWith(const MypageScreen());
        break;
    }
  }

  void _navigateToSubTab(int index) {
    switch (index) {
      case 0:
        _replaceWith(const TripPlanDateScreen());
        break;
      case 1:
        break;
      case 2:
        _replaceWith(const TripPlanScheduleScreen());
        break;
      case 3:
        _replaceWith(const TripPlanBudgetScreen());
        break;
      case 4:
        _replaceWith(const TripPlanChecklistScreen());
        break;
    }
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

  void _showTripRoomSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '여행방 선택',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tripRoomService.tripRooms.length,
                itemBuilder: (context, index) {
                  final room = _tripRoomService.tripRooms[index];
                  final bool isSelected = _currentTripRoom?.id == room.id;

                  return ListTile(
                    title: Text(
                      room.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFFFA0A0) : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${room.participantCount}명 • ${room.destination} • ${room.dDay}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    trailing:
                        isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFFA0A0)) : null,
                    onTap: () {
                      setState(() {
                        _tripRoomService.setCurrentTripRoom(room);
                        _currentTripRoom = room;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlaceModalContent extends StatefulWidget {
  const _AddPlaceModalContent({
    required this.scale,
    required this.onClose,
    required this.onSubmit,
  });

  final double scale;
  final VoidCallback onClose;
  final void Function(String placeName, String category, String description) onSubmit;

  @override
  State<_AddPlaceModalContent> createState() => _AddPlaceModalContentState();
}

class _AddPlaceModalContentState extends State<_AddPlaceModalContent> {
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = const [
    '자연/관광',
    '문화/역사',
    '액티비티',
    '맛집/카페',
    '쇼핑',
    '휴양/힐링',
    '사진명소',
    '기타',
  ];

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;
    final String defaultFontFamily =
        Theme.of(context).textTheme.titleMedium?.fontFamily ??
            Theme.of(context).textTheme.bodyMedium?.fontFamily ??
            'YeongdeokSea';

    return Padding(
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '새 장소 제안하기',
                style: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                iconSize: 20 * scale,
                splashRadius: 20 * scale,
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          _buildLabel('장소명', scale),
          _buildTextField(
            controller: _placeNameController,
            hintText: '장소명을 입력하세요.',
            scale: scale,
          ),
          SizedBox(height: 16 * scale),
          _buildLabel('카테고리', scale),
          LayoutBuilder(
            builder: (context, constraints) {
              final double spacing = 8 * scale;
              final double itemWidth = (constraints.maxWidth - spacing * 3) / 4;
              final double itemHeight = 44 * scale;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _categories.map((category) {
                  final bool isSelected = _selectedCategory == category;
                  return SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF8282) : const Color(0x801A0802),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 16 * scale),
          _buildLabel('설명', scale),
          _buildTextField(
            controller: _descriptionController,
            hintText: '장소에 대한 설명을 입력하세요.',
            scale: scale,
            maxLines: 3,
          ),
          SizedBox(height: 16 * scale),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0x801A0802), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Tip',
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  '구체적인 장소명을 입력하세요.\n왜 이 장소를 제안하는지 설명해주세요.\n예상 시간이나 비용 정보가 있다면 함께 적어주세요.',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A0802),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_placeNameController.text.isEmpty || _selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장소명과 카테고리를 선택해주세요.')),
                  );
                  return;
                }
                widget.onSubmit(
                  _placeNameController.text,
                  _selectedCategory!,
                  _descriptionController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8282),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
                textStyle: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w700,
                  fontFamily: defaultFontFamily,
                ),
              ),
              child: const Text('제안하기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required double scale,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 8 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: 15 * scale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

