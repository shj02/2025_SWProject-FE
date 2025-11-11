import '../models/budget_models.dart';

class TripPlanBudgetStateService {
  TripPlanBudgetStateService._internal() {
    _initialise();
  }

  static final TripPlanBudgetStateService _instance = TripPlanBudgetStateService._internal();

  factory TripPlanBudgetStateService() => _instance;

  bool _initialised = false;

  final List<PersonalBudget> personalBudgets = [];
  final List<ExpenseEntry> expenses = [];

  void _initialise() {
    if (_initialised) return;
    _initialised = true;

    personalBudgets.addAll([
      PersonalBudget(memberName: '홍길동', total: 650000),
      PersonalBudget(memberName: '이순신', total: 650000),
      PersonalBudget(memberName: '김개똥', total: 650000),
      PersonalBudget(memberName: '박영희', total: 650000),
    ]);

    expenses.addAll([
      ExpenseEntry(
        id: 'exp_shared_1',
        title: '숙소 예약',
        amount: 300000,
        category: ExpenseCategory.shared,
        memo: '어디어디리조트',
        payer: '홍길동',
        participants: ['홍길동', '이순신', '김개똥', '박영희'],
      ),
      ExpenseEntry(
        id: 'exp_shared_2',
        title: '항공료',
        amount: 250000,
        category: ExpenseCategory.shared,
        memo: '00항공',
        payer: '이순신',
        participants: ['홍길동', '이순신', '김개똥', '박영희'],
      ),
      ExpenseEntry(
        id: 'exp_personal_1',
        title: '아르떼 뮤지엄 입장권',
        amount: 18000,
        category: ExpenseCategory.personal,
        memo: '성인 18,000원',
        participants: ['홍길동'],
      ),
    ]);
  }

  void upsertPersonalBudget(String memberName, double total) {
    final int index =
        personalBudgets.indexWhere((budget) => budget.memberName == memberName.trim());
    if (index >= 0) {
      personalBudgets[index].total = total;
    } else {
      personalBudgets.add(PersonalBudget(memberName: memberName.trim(), total: total));
    }
  }

  void addExpense(ExpenseEntry entry) {
    expenses.insert(0, entry);
  }
}

