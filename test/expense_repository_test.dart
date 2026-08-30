import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/expense_repository.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  group('ExpenseRepository Tests', () {
    late ExpenseRepository repository;

    setUp(() {
      repository = ExpenseRepository();
    });

    test('Initial mock expenses are loaded', () {
      expect(repository.expenses, isNotEmpty);
      expect(repository.expenses.length, greaterThanOrEqualTo(5));
    });

    test('Adding a new expense increases count and updates totals', () async {
      final initialCount = repository.expenses.length;
      final initialTotal = repository.totalSpendingThisWeek;

      final newExpense = Expense(
        id: 'test_100',
        title: 'Book Purchase',
        amount: 50.00,
        category: ExpenseCategory.other,
        paymentMethod: PaymentMethod.upi,
        date: DateTime(2026, 3, 10),
      );

      await repository.addExpense(newExpense);

      expect(repository.expenses.length, equals(initialCount + 1));
      expect(repository.totalSpendingThisWeek, equals(initialTotal + 50.00));
    });

    test('Smart suggestions filter matching templates', () {
      final suggestions = repository.getSuggestions('Spot');
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.title, contains('Spotify'));
    });

    test('Deleting an expense removes it', () async {
      final target = repository.expenses.first;
      await repository.deleteExpense(target.id);
      expect(repository.expenses.any((e) => e.id == target.id), isFalse);
    });
  });
}
