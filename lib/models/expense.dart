import 'package:flutter/material.dart';

enum ExpenseCategory {
  foodAndDrinks('Food & Drinks', Icons.restaurant),
  transportation('Transportation', Icons.directions_car),
  shopping('Shopping', Icons.shopping_bag),
  entertainment('Entertainment', Icons.music_note),
  bills('Bills', Icons.receipt_long),
  health('Health', Icons.local_hospital),
  other('Other', Icons.more_horiz);

  final String label;
  final IconData icon;

  const ExpenseCategory(this.label, this.icon);

  static ExpenseCategory fromString(String? value) {
    if (value == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}

enum PaymentMethod {
  cash('Cash', Icons.payments),
  card('Card', Icons.credit_card),
  upi('UPI', Icons.qr_code),
  bankTransfer('Bank Transfer', Icons.account_balance);

  final String label;
  final IconData icon;

  const PaymentMethod(this.label, this.icon);

  static PaymentMethod fromString(String? value) {
    if (value == null) return PaymentMethod.card;
    return PaymentMethod.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentMethod.card,
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    PaymentMethod? paymentMethod,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.fromString(json['category'] as String?),
      paymentMethod: PaymentMethod.fromString(json['payment'] as String? ?? json['paymentMethod'] as String?),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category.label,
      'payment': paymentMethod.label,
      'date': date.toIso8601String(),
    };
  }
}

class TopCategory {
  final String name;
  final double amount;
  final ExpenseCategory category;

  TopCategory({
    required this.name,
    required this.amount,
    required this.category,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return TopCategory(
      name: name,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.fromString(name),
    );
  }
}

class Summary {
  final double totalSpending;
  final double thisWeek;
  final double thisMonth;
  final double thisYear;
  final TopCategory? topCategory;

  Summary({
    required this.totalSpending,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    this.topCategory,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalSpending: (json['totalSpending'] as num?)?.toDouble() ?? 0.0,
      thisWeek: (json['thisWeek'] as num?)?.toDouble() ?? 0.0,
      thisMonth: (json['thisMonth'] as num?)?.toDouble() ?? 0.0,
      thisYear: (json['thisYear'] as num?)?.toDouble() ?? 0.0,
      topCategory: json['topCategory'] != null && json['topCategory']['name'] != null
          ? TopCategory.fromJson(json['topCategory'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TrendValue {
  final String date;
  final double amount;

  TrendValue({required this.date, required this.amount});

  factory TrendValue.fromJson(Map<String, dynamic> json) {
    return TrendValue(
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SpendingTrend {
  final String period;
  final List<TrendValue> values;

  SpendingTrend({required this.period, required this.values});

  factory SpendingTrend.fromJson(Map<String, dynamic> json) {
    final list = json['values'] as List? ?? [];
    return SpendingTrend(
      period: json['period'] as String? ?? 'week',
      values: list.map((item) => TrendValue.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class ExpenseSuggestion {
  final String title;
  final double amount;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;

  ExpenseSuggestion({
    required this.title,
    required this.amount,
    required this.category,
    required this.paymentMethod,
  });

  factory ExpenseSuggestion.fromJson(Map<String, dynamic> json) {
    return ExpenseSuggestion(
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.fromString(json['category'] as String?),
      paymentMethod: PaymentMethod.fromString(json['payment'] as String? ?? json['paymentMethod'] as String?),
    );
  }

  Expense toExpense() {
    return Expense(
      id: '',
      title: title,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      date: DateTime.now(),
    );
  }
}
