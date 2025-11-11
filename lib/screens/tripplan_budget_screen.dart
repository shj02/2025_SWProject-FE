import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/budget_models.dart';
import '../models/trip_room.dart';
import '../services/trip_room_service.dart';
import '../services/trip_plan_budget_state_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/tab_navigation.dart';
import '../widgets/top_tab.dart';
import 'main_menu_screen.dart';
import 'tripplan_candidates_screen.dart';
import 'tripplan_checklist_screen.dart';
import 'tripplan_date_screen.dart';
import 'tripplan_schedule_screen.dart';
import 'community_screen.dart';
import 'mypage_screen.dart';

class TripPlanBudgetScreen extends StatefulWidget {
  const TripPlanBudgetScreen({super.key});

  @override
  State<TripPlanBudgetScreen> createState() => _TripPlanBudgetScreenState();
}

class _TripPlanBudgetScreenState extends State<TripPlanBudgetScreen> {
  static const double _designWidth = 402.0;

  int _currentNavbarIndex = 1;
  int _selectedSubTabIndex = 3;

  late final TripRoomService _tripRoomService;
  late final TripPlanBudgetStateService _budgetStateService;
  late final UserService _userService;
  TripRoom? _currentTripRoom;

  late List<PersonalBudget> _personalBudgets;
  late List<ExpenseEntry> _expenses;
  Map<String, double> _usedByMember = {};
  double _totalBudgetAmount = 0;
  double _totalUsedAmount = 0;

  @override
  void initState() {
    super.initState();
    _tripRoomService = TripRoomService();
    _budgetStateService = TripPlanBudgetStateService();
    _userService = UserService();
    _currentTripRoom = _tripRoomService.currentTripRoom;

    if (_currentTripRoom != null) {
      _tripRoomService.updateDDay();
    }

    _personalBudgets = _budgetStateService.personalBudgets;
    _expenses = _budgetStateService.expenses;
    _recalculateUsage();
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
          child: Column(
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 17 * scale, vertical: 16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBudgetSummary(scale),
                      SizedBox(height: 16 * scale),
                      _buildPersonalBudgetSection(scale),
                      SizedBox(height: 16 * scale),
                      _buildExpenseSection(scale),
                      SizedBox(height: 16 * scale),
                      _buildSettlementSection(scale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(double scale) {
    final double progress = _totalBudgetAmount <= 0
        ? 0
        : (_totalUsedAmount / _totalBudgetAmount).clamp(0, 1);
    final double usedPercent =
        _totalBudgetAmount <= 0 ? 0 : (_totalUsedAmount / _totalBudgetAmount * 100);
    final double remaining = _totalBudgetAmount - _totalUsedAmount;

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 22 * scale, color: const Color(0xFF1A0802)),
              SizedBox(width: 10 * scale),
              Text(
                '전체 예산 현황',
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Center(
            child: Column(
              children: [
                Text(
                  '₩${_formatCurrency(_totalUsedAmount)} / ₩${_formatCurrency(_totalBudgetAmount)}',
                  style: TextStyle(
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  '멤버 지출 합 / 전체 예산',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          ClipRRect(
            borderRadius: BorderRadius.circular(8 * scale),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 15 * scale,
              backgroundColor: const Color(0xFFF0F3F8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8282)),
            ),
          ),
          SizedBox(height: 10 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${usedPercent.toStringAsFixed(1)}% 사용',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                remaining >= 0
                    ? '₩${_formatCurrency(remaining)} 남음'
                    : '₩${_formatCurrency(remaining.abs())} 초과',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBudgetSection(double scale) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, size: 20 * scale, color: const Color(0xFF1A0802)),
                  SizedBox(width: 10 * scale),
                  Text(
                    '개인별 예산',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _openAddPersonalBudget,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                ),
                icon: Icon(Icons.add_circle_outline, size: 16 * scale, color: const Color(0xFF1A0802)),
                label: Text(
                  '내 예산 추가',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A0802),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          ..._personalBudgets.map(
            (budget) {
              final double used = _usedByMember[budget.memberName] ?? 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 12 * scale),
                child: _PersonalBudgetTile(
                  budget: budget,
                  used: used,
                  scale: scale,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseSection(double scale) {
    final String currentUserName = _userService.userName ?? '나';
    final List<ExpenseEntry> visibleExpenses = _expenses
        .where(
          (expense) =>
              expense.category == ExpenseCategory.shared ||
              expense.participants.contains(currentUserName),
        )
        .toList();

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, size: 20 * scale, color: const Color(0xFF1A0802)),
                  SizedBox(width: 10 * scale),
                  Text(
                    '지출 기록',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _openAddExpense,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8282),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6 * scale),
                  ),
                ),
                icon: Icon(Icons.add_circle_outline, size: 16 * scale, color: Colors.white),
                label: Text(
                  '지출 추가',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          if (visibleExpenses.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4 * scale, bottom: 4 * scale),
              child: Text(
                '표시할 지출이 없습니다.',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5D6470),
                ),
              ),
            )
          else
            ...visibleExpenses.map(
              (expense) => Padding(
                padding: EdgeInsets.only(bottom: 12 * scale),
                child: _ExpenseTile(
                  expense: expense,
                  scale: scale,
                  currentUserName: currentUserName,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettlementSection(double scale) {
    final List<ExpenseEntry> sharedExpenses =
        _expenses.where((expense) => expense.isShared).toList();
    final double sharedTotal =
        sharedExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final Set<String> sharedParticipants = {
      for (final expense in sharedExpenses) ...expense.participants,
    };
    final double perPerson =
        sharedParticipants.isEmpty ? 0 : sharedTotal / sharedParticipants.length;

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x801A0802), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 20 * scale, color: const Color(0xFF1A0802)),
              SizedBox(width: 10 * scale),
              Text(
                '정산하기',
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '정산 대기 중인 공용 지출',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6 * scale),
                        border: Border.all(color: const Color(0xFFFC5858), width: 1),
                      ),
                      child: Text(
                        '${sharedExpenses.length}건',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A0802),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * scale),
                Text(
                  '₩${_formatCurrency(sharedTotal)}',
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  '1인당 ₩${_formatCurrency(perPerson)}',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5D6470),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  sharedExpenses.isEmpty ? null : () => _openSettlementDialog(sharedExpenses),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFD9797), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
                textStyle: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: Icon(Icons.receipt, size: 20 * scale, color: const Color(0xFF1A0802)),
              label: const Text('정산 계산하기'),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddPersonalBudget() {
    final String userName = _userService.userName ?? '나';
    PersonalBudget? existingBudget;
    try {
      existingBudget = _personalBudgets
          .firstWhere((budget) => budget.memberName == userName);
    } catch (_) {
      existingBudget = null;
    }

    showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PersonalBudgetSheet(
        userName: userName,
        initialTotal: existingBudget?.total,
      ),
    ).then((total) {
      if (total == null) return;
      setState(() {
        _budgetStateService.upsertPersonalBudget(userName, total);
        _recalculateUsage();
      });
    });
  }

  void _openAddExpense() {
    final List<String> participants =
        (_currentTripRoom?.participants ?? []).toSet().toList();
    if (!participants.contains(_userService.userName ?? '나')) {
      participants.add(_userService.userName ?? '나');
    }

    showModalBottomSheet<ExpenseEntry?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseEditorSheet(
        participants: participants,
        currentUserName: _userService.userName ?? '나',
      ),
    ).then((result) {
      if (result == null) return;
      setState(() {
        _budgetStateService.addExpense(result);
        _recalculateUsage();
      });
    });
  }

  void _openSettlementDialog(List<ExpenseEntry> sharedExpenses) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettlementSheet(
        expenses: sharedExpenses,
        participants: _currentTripRoom?.participants ?? [],
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
        _replaceWith(const TripPlanCandidatesScreen());
        break;
      case 2:
        _replaceWith(const TripPlanScheduleScreen());
        break;
      case 3:
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
                  final TripRoom room = _tripRoomService.tripRooms[index];
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

  void _recalculateUsage() {
    final Set<String> allMembers = {
      for (final budget in _personalBudgets) budget.memberName,
      ...(_currentTripRoom?.participants ?? const []),
    };

    final Map<String, double> usage = {
      for (final member in allMembers) member: 0,
    };

    for (final expense in _expenses) {
      if (expense.isShared) {
        final List<String> participants =
            expense.participants.isNotEmpty ? expense.participants : allMembers.toList();
        if (participants.isEmpty) continue;
        final double share = expense.amount / participants.length;
        for (final participant in participants) {
          usage.update(participant, (value) => value + share, ifAbsent: () => share);
        }
      } else {
        final String? owner = expense.personalOwner ??
            (expense.participants.isNotEmpty ? expense.participants.first : null);
        if (owner != null) {
          usage.update(owner, (value) => value + expense.amount, ifAbsent: () => expense.amount);
        }
      }
    }

    _usedByMember = usage;
    _personalBudgets.sort((a, b) => a.memberName.compareTo(b.memberName));
    _totalBudgetAmount =
        _personalBudgets.fold(0.0, (sum, budget) => sum + budget.total);
    _totalUsedAmount = _personalBudgets.fold(
      0.0,
      (sum, budget) => sum + (usage[budget.memberName] ?? 0),
    );
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _PersonalBudgetTile extends StatelessWidget {
  const _PersonalBudgetTile({
    required this.budget,
    required this.used,
    required this.scale,
  });

  final PersonalBudget budget;
  final double used;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double progress =
        budget.total <= 0 ? 0 : (used / budget.total).clamp(0, 1);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget.memberName,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10 * scale),
          ClipRRect(
            borderRadius: BorderRadius.circular(4 * scale),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6 * scale,
              backgroundColor: const Color(0xFFF0F3F8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2564DF)),
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '₩${_formatCurrency(used)} / ₩${_formatCurrency(budget.total)}',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.scale,
    required this.currentUserName,
  });

  final ExpenseEntry expense;
  final double scale;
  final String currentUserName;

  @override
  Widget build(BuildContext context) {
    final bool isShared = expense.isShared;
    final String? payer = expense.payer;
    final List<String> participants = expense.participants;
    final String? owner = expense.personalOwner;

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6 * scale),
                            border: Border.all(color: const Color(0xFFFC5858), width: 1),
                            color: isShared ? Colors.white : const Color(0xFFFFE6E6),
                          ),
                          child: Text(
                            isShared ? '공용' : '개인',
                            style: TextStyle(
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A0802),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    if (isShared && participants.isNotEmpty) ...[
                      Text(
                        '참여자: ${participants.join(', ')}',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5D6470),
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                    ] else if (!isShared && owner != null) ...[
                      Text(
                        '개인 지출: $owner',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5D6470),
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                    ],
                    if (expense.memo.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note_outlined, size: 14 * scale, color: const Color(0xFF1A0802)),
                          SizedBox(width: 6 * scale),
                          Expanded(
                            child: Text(
                              expense.memo,
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A0802),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₩${_formatCurrency(expense.amount)}',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  if (isShared && payer != null)
                    Text(
                      '$payer님 결제',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5D6470),
                      ),
                    )
                  else if (!isShared && owner != null)
                    Text(
                      owner == currentUserName ? '내 개인 지출' : '$owner 개인 지출',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5D6470),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class PersonalBudgetSheet extends StatefulWidget {
  const PersonalBudgetSheet({
    super.key,
    required this.userName,
    this.initialTotal,
  });

  final String userName;
  final double? initialTotal;

  @override
  State<PersonalBudgetSheet> createState() => _PersonalBudgetSheetState();
}

class _PersonalBudgetSheetState extends State<PersonalBudgetSheet> {
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    final double? initial = widget.initialTotal;
    _totalController = TextEditingController(
      text: initial != null && initial > 0 ? initial.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / _TripPlanBudgetScreenState._designWidth;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20 * scale,
        right: 20 * scale,
        top: 20 * scale,
        bottom: 20 * scale + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              '내 예산 추가',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('이름', scale),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 14 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: const Color(0xFFE1E1E1)),
              ),
              child: Text(
                widget.userName,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('전체 예산 (원)', scale),
            _buildTextField(
              _totalController,
              '예) 650000',
              scale,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24 * scale),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5858),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  textStyle: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_totalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예산 금액을 입력해주세요.')),
      );
      return;
    }

    final double total =
        double.tryParse(_totalController.text.replaceAll(',', '')) ?? 0;

    Navigator.pop(context, total);
  }

  Widget _buildLabel(String text, double scale) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    double scale, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0x801A0802)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFFC5858), width: 2),
        ),
      ),
    );
  }
}

class ExpenseEditorSheet extends StatefulWidget {
  const ExpenseEditorSheet({
    super.key,
    required this.participants,
    required this.currentUserName,
  });

  final List<String> participants;
  final String currentUserName;

  @override
  State<ExpenseEditorSheet> createState() => _ExpenseEditorSheetState();
}

class _ExpenseEditorSheetState extends State<ExpenseEditorSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.shared;
  late List<String> _allParticipants;
  late Set<String> _selectedSharedParticipants;
  String? _selectedPayer;

  @override
  void initState() {
    super.initState();
    _allParticipants = widget.participants.isEmpty
        ? [widget.currentUserName]
        : widget.participants.toSet().toList();
    if (!_allParticipants.contains(widget.currentUserName)) {
      _allParticipants.add(widget.currentUserName);
    }
    _allParticipants.sort();
    _selectedSharedParticipants = _allParticipants.toSet();
    _selectedPayer = _allParticipants.contains(widget.currentUserName)
        ? widget.currentUserName
        : (_allParticipants.isNotEmpty ? _allParticipants.first : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / _TripPlanBudgetScreenState._designWidth;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20 * scale,
        right: 20 * scale,
        top: 20 * scale,
        bottom: 20 * scale + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              '지출 추가',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildLabel('지출 항목', scale),
            _buildTextField(_titleController, '예) 숙소 예약', scale),
            SizedBox(height: 16 * scale),
            _buildLabel('금액 (원)', scale),
            _buildTextField(_amountController, '300000', scale, keyboardType: TextInputType.number),
            SizedBox(height: 16 * scale),
            _buildLabel('구분', scale),
            ToggleButtons(
              borderRadius: BorderRadius.circular(12 * scale),
              isSelected: [
                _selectedCategory == ExpenseCategory.shared,
                _selectedCategory == ExpenseCategory.personal,
              ],
              onPressed: (index) {
                setState(() {
                  final ExpenseCategory newCategory = ExpenseCategory.values[index];
                  if (_selectedCategory == newCategory) return;
                  _selectedCategory = newCategory;
                  if (_selectedCategory == ExpenseCategory.shared) {
                    _selectedSharedParticipants = _allParticipants.toSet();
                    _selectedPayer = _allParticipants.contains(widget.currentUserName)
                        ? widget.currentUserName
                        : (_allParticipants.isNotEmpty ? _allParticipants.first : null);
                  } else {
                    _selectedSharedParticipants = {widget.currentUserName};
                    _selectedPayer = null;
                  }
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                  child: const Text('공용'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                  child: const Text('개인'),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            if (_selectedCategory == ExpenseCategory.shared) ...[
              _buildLabel('결제자', scale),
              DropdownButtonFormField<String>(
                value: _selectedPayer,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 12 * scale,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                    borderSide: const BorderSide(color: Color(0x801A0802)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                    borderSide: const BorderSide(color: Color(0xFFFC5858), width: 2),
                  ),
                ),
                items: _allParticipants
                    .map(
                      (member) => DropdownMenuItem<String>(
                        value: member,
                        child: Text(member),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedPayer = value;
                    _selectedSharedParticipants.add(value);
                  });
                },
              ),
              SizedBox(height: 16 * scale),
              _buildLabel('참여자', scale),
              Column(
                children: _allParticipants.map((member) {
                  final bool checked = _selectedSharedParticipants.contains(member);
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checked,
                    title: Text(
                      member,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedSharedParticipants.add(member);
                        } else {
                          if (_selectedSharedParticipants.length <= 1) return;
                          _selectedSharedParticipants.remove(member);
                          if (_selectedPayer != null &&
                              !_selectedSharedParticipants.contains(_selectedPayer)) {
                            _selectedPayer = _selectedSharedParticipants.isNotEmpty
                                ? _selectedSharedParticipants.first
                                : null;
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16 * scale),
            ] else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Text(
                  '개인 지출은 ${widget.currentUserName}님의 예산에만 반영됩니다.',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5D6470),
                  ),
                ),
              ),
              SizedBox(height: 16 * scale),
            ],
            _buildLabel('메모', scale),
            _buildTextField(_memoController, '내용을 입력하세요', scale, maxLines: 2),
            SizedBox(height: 24 * scale),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5858),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  textStyle: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('추가하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 값을 입력해주세요.')),
      );
      return;
    }

    final double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액을 올바르게 입력해주세요.')),
      );
      return;
    }

    List<String> participants;
    String? payer;

    if (_selectedCategory == ExpenseCategory.shared) {
      if (_selectedSharedParticipants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('참여자를 한 명 이상 선택해주세요.')),
        );
        return;
      }
      if (_selectedPayer == null || !_selectedSharedParticipants.contains(_selectedPayer)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제자를 선택해주세요.')),
        );
        return;
      }
      participants = _selectedSharedParticipants.toList();
      payer = _selectedPayer;
    } else {
      participants = [widget.currentUserName];
      payer = null;
    }
    participants = participants.toSet().toList();

    Navigator.pop(
      context,
      ExpenseEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        memo: _memoController.text.trim(),
        category: _selectedCategory,
        participants: participants,
        payer: payer,
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    double scale, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0x801A0802)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Color(0xFFFC5858), width: 2),
        ),
      ),
    );
  }
}

class SettlementSheet extends StatelessWidget {
  const SettlementSheet({
    super.key,
    required this.expenses,
    required this.participants,
  });

  final List<ExpenseEntry> expenses;
  final List<String> participants;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / _TripPlanBudgetScreenState._designWidth;
    final double total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final _SettlementResult settlementResult = _calculateSettlement();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20 * scale,
        right: 20 * scale,
        top: 20 * scale,
        bottom: 20 * scale + MediaQuery.of(context).padding.bottom,
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
            Text(
              '정산 계산하기',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              '공용 지출 ${expenses.length}건',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10 * scale),
            ...expenses.map(
              (expense) => Padding(
                padding: EdgeInsets.only(bottom: 12 * scale),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: TextStyle(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            '결제자: ${expense.payer ?? '-'}',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              color: const Color(0xFF5D6470),
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            '참여자: ${(expense.participants.isNotEmpty ? expense.participants : participants).join(', ')}',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              color: const Color(0xFF5D6470),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Text(
                      '₩${_formatCurrency(expense.amount)}',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 24 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 공용 지출',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '₩${_formatCurrency(total)}',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
            Text(
              '정산 요약',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10 * scale),
            if (settlementResult.entries.isEmpty)
              Text(
                '정산할 금액이 없습니다.',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: const Color(0xFF5D6470),
                ),
              )
            else
              ...settlementResult.entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.from} → ${entry.to}',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '₩${_formatCurrency(entry.amount)}',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFC5858),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 24 * scale),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _SettlementResult _calculateSettlement() {
    final Map<String, Map<String, double>> owed = {};
    final Set<String> fallbackParticipants = participants.toSet();

    for (final expense in expenses) {
      final String? payer = expense.payer;
      if (payer == null) continue;
      final List<String> involved = expense.participants.isNotEmpty
          ? expense.participants
          : fallbackParticipants.toList();
      if (involved.isEmpty) continue;
      final double share = expense.amount / involved.length;
      for (final participant in involved) {
        if (participant == payer) continue;
        owed.putIfAbsent(participant, () => <String, double>{});
        owed[participant]![payer] =
            (owed[participant]![payer] ?? 0) + share;
      }
    }

    final List<_SettlementEntry> entries = [];
    owed.forEach((from, payers) {
      payers.forEach((to, amount) {
        if (amount <= 0) return;
        entries.add(_SettlementEntry(from: from, to: to, amount: amount));
      });
    });

    entries.sort((a, b) => b.amount.compareTo(a.amount));

    return _SettlementResult(entries: entries);
  }

  String _formatCurrency(double value) {
    final double rounded = double.parse(value.toStringAsFixed(0));
    return rounded.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _SettlementResult {
  _SettlementResult({required this.entries});

  final List<_SettlementEntry> entries;
}

class _SettlementEntry {
  _SettlementEntry({
    required this.from,
    required this.to,
    required this.amount,
  });

  final String from;
  final String to;
  final double amount;
}
