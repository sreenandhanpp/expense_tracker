import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/expense_repository.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/api_service.dart';

class FakeApiService implements ApiService {
  final List<Expense> _store = [];

  @override
  Future<List<Expense>> getExpenses({String? search, String? category, String? payment, String? date}) async {
    return List.from(_store);
  }

  @override
  Future<Expense> getExpense(String id) async {
    return _store.firstWhere((e) => e.id == id);
  }

  @override
  Future<Expense> createExpense(Expense expense) async {
    _store.add(expense);
    return expense;
  }

  @override
  Future<Expense> updateExpense(String id, Expense expense) async {
    final index = _store.indexWhere((e) => e.id == id);
    if (index != -1) _store[index] = expense;
    return expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    _store.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<List<String>> getPaymentMethods() async => [];

  @override
  Future<Summary> getSummary() async {
    return Summary(
      totalSpending: _store.fold(0, (s, e) => s + e.amount),
      thisWeek: _store.fold(0, (s, e) => s + e.amount),
      thisMonth: _store.fold(0, (s, e) => s + e.amount),
      thisYear: _store.fold(0, (s, e) => s + e.amount),
    );
  }

  @override
  Future<SpendingTrend> getSpendingTrends() async {
    return SpendingTrend(
      period: 'week',
      values: List.generate(7, (i) => TrendValue(date: '2026-03-0$i', amount: 0)),
    );
  }

  @override
  Future<List<ExpenseSuggestion>> getSuggestions(String query) async => [];
}

void main() {
  group('ExpenseRepository Tests', () {
    late ExpenseRepository repository;

    setUp(() {
      repository = ExpenseRepository(apiService: FakeApiService());
    });

    test('Repository starts clean without static mock expenses', () {
      expect(repository.expenses, isEmpty);
    });

    test('Adding a new expense increases count and updates weekly totals', () async {
      final now = DateTime.now();
      final initialCount = repository.expenses.length;
      final initialTotal = repository.totalSpendingThisWeek;

      final newExpense = Expense(
        id: 'test_100',
        title: 'Book Purchase',
        amount: 50.00,
        category: ExpenseCategory.other,
        paymentMethod: PaymentMethod.upi,
        date: now,
      );

      await repository.addExpense(newExpense);

      expect(repository.expenses.length, equals(initialCount + 1));
      expect(repository.totalSpendingThisWeek, equals(initialTotal + 50.00));
    });

    test('Smart suggestions filter matching dynamic expenses', () async {
      final newExpense = Expense(
        id: 'test_101',
        title: 'Spotify Subscription',
        amount: 199.00,
        category: ExpenseCategory.entertainment,
        paymentMethod: PaymentMethod.card,
        date: DateTime.now(),
      );

      await repository.addExpense(newExpense);

      final suggestions = repository.getSuggestions('Spot');
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.title, contains('Spotify'));
    });

    test('Deleting an expense removes it', () async {
      final newExpense = Expense(
        id: 'test_102',
        title: 'Coffee',
        amount: 15.00,
        category: ExpenseCategory.foodAndDrinks,
        paymentMethod: PaymentMethod.cash,
        date: DateTime.now(),
      );

      await repository.addExpense(newExpense);
      expect(repository.expenses.any((e) => e.id == 'test_102'), isTrue);

      await repository.deleteExpense('test_102');
      expect(repository.expenses.any((e) => e.id == 'test_102'), isFalse);
    });
  });
}
