import '../models/expense.dart';

final List<Expense> initialMockExpenses = [
  Expense(
    id: 'exp_1',
    title: 'Spotify',
    amount: 20.98,
    category: ExpenseCategory.entertainment,
    paymentMethod: PaymentMethod.card,
    date: DateTime(2026, 3, 10), // Tuesday
  ),
  Expense(
    id: 'exp_2',
    title: 'Groceries',
    amount: 56.80,
    category: ExpenseCategory.foodAndDrinks,
    paymentMethod: PaymentMethod.upi,
    date: DateTime(2026, 3, 10), // Tuesday
  ),
  Expense(
    id: 'exp_3',
    title: 'Uber',
    amount: 26.40,
    category: ExpenseCategory.transportation,
    paymentMethod: PaymentMethod.card,
    date: DateTime(2026, 3, 9), // Monday
  ),
  Expense(
    id: 'exp_4',
    title: 'Dining out',
    amount: 16.20,
    category: ExpenseCategory.foodAndDrinks,
    paymentMethod: PaymentMethod.cash,
    date: DateTime(2026, 3, 9), // Monday
  ),
  Expense(
    id: 'exp_5',
    title: 'Netflix',
    amount: 199.00,
    category: ExpenseCategory.entertainment,
    paymentMethod: PaymentMethod.card,
    date: DateTime(2026, 3, 5),
  ),
  Expense(
    id: 'exp_6',
    title: 'Pharmacy',
    amount: 29.00,
    category: ExpenseCategory.health,
    paymentMethod: PaymentMethod.upi,
    date: DateTime(2026, 3, 2),
  ),
];

/// Dataset for Smart Suggestions feature
final List<Expense> smartSuggestionTemplates = [
  Expense(
    id: 'sugg_1',
    title: 'Spotify',
    amount: 20.98,
    category: ExpenseCategory.entertainment,
    paymentMethod: PaymentMethod.card,
    date: DateTime.now(),
  ),
  Expense(
    id: 'sugg_2',
    title: 'Uber',
    amount: 26.40,
    category: ExpenseCategory.transportation,
    paymentMethod: PaymentMethod.card,
    date: DateTime.now(),
  ),
  Expense(
    id: 'sugg_3',
    title: 'Groceries',
    amount: 56.80,
    category: ExpenseCategory.foodAndDrinks,
    paymentMethod: PaymentMethod.upi,
    date: DateTime.now(),
  ),
  Expense(
    id: 'sugg_4',
    title: 'Netflix',
    amount: 199.00,
    category: ExpenseCategory.entertainment,
    paymentMethod: PaymentMethod.card,
    date: DateTime.now(),
  ),
  Expense(
    id: 'sugg_5',
    title: 'Starbucks Coffee',
    amount: 350.00,
    category: ExpenseCategory.foodAndDrinks,
    paymentMethod: PaymentMethod.upi,
    date: DateTime.now(),
  ),
];
