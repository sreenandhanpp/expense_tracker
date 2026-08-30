import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import 'mock_expenses.dart';

class ExpenseRepository extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Expense> _expenses = [];
  Summary? _summary;
  SpendingTrend? _spendingTrend;
  bool _isLoading = false;
  String? _errorMessage;

  ExpenseRepository() {
    _expenses.addAll(initialMockExpenses);
    fetchExpenses();
    fetchSummary();
    fetchTrends();
  }

  List<Expense> get expenses => List.unmodifiable(_expenses..sort((a, b) => b.date.compareTo(a.date)));
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Summary? get summary => _summary;
  SpendingTrend? get spendingTrend => _spendingTrend;

  /// Fetch all expenses from backend
  Future<void> fetchExpenses({
    String? search,
    ExpenseCategory? categoryFilter,
    PaymentMethod? paymentFilter,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getExpenses(
        search: search,
        category: categoryFilter?.label,
        payment: paymentFilter?.label,
      );
      _expenses.clear();
      _expenses.addAll(fetched);
    } catch (e) {
      _errorMessage = 'Couldn\'t load expenses. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch spending summary from backend
  Future<void> fetchSummary() async {
    try {
      _summary = await _apiService.getSummary();
      notifyListeners();
    } catch (_) {}
  }

  /// Fetch spending trends from backend
  Future<void> fetchTrends() async {
    try {
      _spendingTrend = await _apiService.getSpendingTrends();
      notifyListeners();
    } catch (_) {}
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    try {
      final created = await _apiService.createExpense(expense);
      _expenses.insert(0, created);
    } catch (e) {
      _expenses.insert(0, expense);
    }
    notifyListeners();
    await fetchSummary();
    await fetchTrends();
    notifyListeners();
  }

  /// Update an existing expense
  Future<void> updateExpense(Expense updated) async {
    try {
      final res = await _apiService.updateExpense(updated.id, updated);
      final index = _expenses.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _expenses[index] = res;
      }
    } catch (_) {
      final index = _expenses.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _expenses[index] = updated;
      }
    }
    notifyListeners();
    await fetchSummary();
    await fetchTrends();
    notifyListeners();
  }

  /// Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    try {
      await _apiService.deleteExpense(id);
    } catch (_) {}
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await fetchSummary();
    await fetchTrends();
    notifyListeners();
  }

  /// Total spending across current week
  double get totalSpendingThisWeek {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final localSum = _expenses.where((e) {
      return !e.date.isBefore(startOfWeek) && e.date.isBefore(endOfWeek);
    }).fold(0.0, (sum, item) => sum + item.amount);

    if (_summary != null) {
      return localSum > _summary!.thisWeek ? localSum : _summary!.thisWeek;
    }
    return localSum;
  }

  /// Total spending for current month
  double get totalSpendingThisMonth {
    final now = DateTime.now();
    final localSum = _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);

    if (_summary != null) {
      return localSum > _summary!.thisMonth ? localSum : _summary!.thisMonth;
    }
    return localSum;
  }

  /// Total spending for year
  double get totalSpendingThisYear {
    final now = DateTime.now();
    final localSum = _expenses
        .where((e) => e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);

    if (_summary != null) {
      return localSum > _summary!.thisYear ? localSum : _summary!.thisYear;
    }
    return localSum;
  }

  /// Daily spending breakdown for the weekly bar chart
  List<double> get weeklyDailyTotals {
    final totals = List<double>.filled(7, 0.0);
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));

    for (var expense in _expenses) {
      final expDay = DateTime(expense.date.year, expense.date.month, expense.date.day);
      final difference = expDay.difference(startOfWeek).inDays;
      if (difference >= 0 && difference < 7) {
        totals[difference] += expense.amount;
      }
    }

    if (_spendingTrend != null && _spendingTrend!.values.length == 7) {
      final backendTotals = _spendingTrend!.values.map((v) => v.amount).toList();
      for (int i = 0; i < 7; i++) {
        if (backendTotals[i] > totals[i]) {
          totals[i] = backendTotals[i];
        }
      }
    }
    return totals;
  }

  /// Top spending category
  ExpenseCategory? get topCategory {
    if (_summary?.topCategory != null) {
      return _summary!.topCategory!.category;
    }
    if (_expenses.isEmpty) return null;
    final map = <ExpenseCategory, double>{};
    for (var e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    ExpenseCategory? top;
    double maxAmount = -1;
    map.forEach((cat, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        top = cat;
      }
    });
    return top;
  }

  /// Search and filter expenses
  List<Expense> search(String query, ExpenseCategory? categoryFilter) {
    return expenses.where((e) {
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query.toLowerCase()) ||
          e.category.label.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = categoryFilter == null || e.category == categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  /// Fetch suggestions from backend with fallback
  Future<List<Expense>> getSuggestionsAsync(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final apiSuggestions = await _apiService.getSuggestions(query);
      if (apiSuggestions.isNotEmpty) {
        return apiSuggestions.map((s) => s.toExpense()).toList();
      }
    } catch (_) {}
    return getSuggestions(query);
  }

  /// Synchronous fallback suggestions
  List<Expense> getSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.trim().toLowerCase();
    final candidates = [...smartSuggestionTemplates, ..._expenses];
    final Set<String> seenTitles = {};
    final List<Expense> result = [];

    for (var candidate in candidates) {
      if (candidate.title.toLowerCase().contains(lower) && !seenTitles.contains(candidate.title.toLowerCase())) {
        seenTitles.add(candidate.title.toLowerCase());
        result.add(candidate);
      }
    }
    return result.take(5).toList();
  }
}
