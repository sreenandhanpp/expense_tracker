import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../services/widget_sync_service.dart';

class ExpenseRepository extends ChangeNotifier {
  final ApiService _apiService;
  final List<Expense> _expenses = [];
  Summary? _summary;
  SpendingTrend? _spendingTrend;
  DateTime _selectedWeekDate = DateTime.now();
  int? _selectedDayIndex;
  bool _isLoading = false;
  String? _errorMessage;

  ExpenseRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    refreshAll();
  }

  List<Expense> get expenses => List.unmodifiable(_expenses..sort((a, b) => b.date.compareTo(a.date)));
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Summary? get summary => _summary;
  SpendingTrend? get spendingTrend => _spendingTrend;
  DateTime get selectedWeekDate => _selectedWeekDate;
  int? get selectedDayIndex => _selectedDayIndex;

  /// Start of the currently selected week (Monday 00:00:00)
  DateTime get startOfWeekMonday {
    final d = DateTime(_selectedWeekDate.year, _selectedWeekDate.month, _selectedWeekDate.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Refresh expenses, summary, and trends
  Future<void> refreshAll() async {
    await fetchExpenses();
    await fetchSummary();
    await fetchTrends();
  }

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
      WidgetSyncService.syncTodayWidget(this);
    }
  }

  /// Fetch spending summary from backend for selected week date
  Future<void> fetchSummary() async {
    try {
      final isoDate = '${_selectedWeekDate.year}-${_selectedWeekDate.month.toString().padLeft(2, '0')}-${_selectedWeekDate.day.toString().padLeft(2, '0')}';
      _summary = await _apiService.getSummary(refDate: isoDate);
      notifyListeners();
    } catch (_) {}
  }

  /// Fetch spending trends from backend for selected week date
  Future<void> fetchTrends() async {
    try {
      final isoDate = '${_selectedWeekDate.year}-${_selectedWeekDate.month.toString().padLeft(2, '0')}-${_selectedWeekDate.day.toString().padLeft(2, '0')}';
      _spendingTrend = await _apiService.getSpendingTrends(refDate: isoDate);
      notifyListeners();
    } catch (_) {}
  }

  /// Set selected week date and reload summary & trends
  Future<void> selectWeekDate(DateTime date) async {
    _selectedWeekDate = date;
    _selectedDayIndex = null;
    notifyListeners();
    await fetchSummary();
    await fetchTrends();
  }

  /// Navigate to previous week
  Future<void> previousWeek() async {
    await selectWeekDate(_selectedWeekDate.subtract(const Duration(days: 7)));
  }

  /// Navigate to next week
  Future<void> nextWeek() async {
    await selectWeekDate(_selectedWeekDate.add(const Duration(days: 7)));
  }

  /// Reset to current week
  Future<void> resetToCurrentWeek() async {
    await selectWeekDate(DateTime.now());
  }

  /// Toggle or select a day bar in the weekly graph (0 = Mon, ..., 6 = Sun)
  void selectDayIndex(int? index) {
    if (_selectedDayIndex == index) {
      _selectedDayIndex = null;
    } else {
      _selectedDayIndex = index;
    }
    notifyListeners();
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
    WidgetSyncService.syncTodayWidget(this);
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
    WidgetSyncService.syncTodayWidget(this);
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
    WidgetSyncService.syncTodayWidget(this);
  }

  /// Total spending across current selected week
  double get totalSpendingThisWeek {
    if (_summary != null) {
      return _summary!.thisWeek;
    }
    final startOfWeek = startOfWeekMonday;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _expenses.where((e) {
      return !e.date.isBefore(startOfWeek) && e.date.isBefore(endOfWeek);
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Displayed total spending (either selected day total or week total)
  double get displayedSpending {
    if (_selectedDayIndex != null) {
      final totals = weeklyDailyTotals;
      if (_selectedDayIndex! >= 0 && _selectedDayIndex! < totals.length) {
        return totals[_selectedDayIndex!];
      }
    }
    return totalSpendingThisWeek;
  }

  /// Total spending for current month
  double get totalSpendingThisMonth {
    if (_summary != null) {
      return _summary!.thisMonth;
    }
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total spending for year
  double get totalSpendingThisYear {
    if (_summary != null) {
      return _summary!.thisYear;
    }
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Daily spending breakdown for the weekly bar chart (Monday to Sunday)
  List<double> get weeklyDailyTotals {
    if (_spendingTrend != null && _spendingTrend!.values.length == 7) {
      return _spendingTrend!.values.map((v) => v.amount).toList();
    }
    final totals = List<double>.filled(7, 0.0);
    final startOfWeek = startOfWeekMonday;

    for (var expense in _expenses) {
      final expDay = DateTime(expense.date.year, expense.date.month, expense.date.day);
      final difference = expDay.difference(startOfWeek).inDays;
      if (difference >= 0 && difference < 7) {
        totals[difference] += expense.amount;
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

  /// Fetch suggestions from backend
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

  /// Synchronous fallback suggestions from fetched dynamic expenses
  List<Expense> getSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.trim().toLowerCase();
    final Set<String> seenTitles = {};
    final List<Expense> result = [];

    for (var candidate in _expenses) {
      if (candidate.title.toLowerCase().contains(lower) && !seenTitles.contains(candidate.title.toLowerCase())) {
        seenTitles.add(candidate.title.toLowerCase());
        result.add(candidate);
      }
    }
    return result.take(5).toList();
  }
}
