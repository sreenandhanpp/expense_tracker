import 'package:home_widget/home_widget.dart';
import '../data/expense_repository.dart';

class WidgetSyncService {
  WidgetSyncService._();

  static const String _androidWidgetName = 'TodayWidgetProvider';

  /// Calculate current-day spending and sync to the native Android widget
  static Future<void> syncTodayWidget(ExpenseRepository repository) async {
    try {
      final now = DateTime.now();
      final todayExpenses = repository.expenses.where((e) {
        return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
      }).toList();

      final totalToday = todayExpenses.fold(0.0, (sum, item) => sum + item.amount);
      final count = todayExpenses.length;
      final countText = count == 0
          ? 'No expenses today'
          : '$count ${count == 1 ? 'expense' : 'expenses'} today';

      await HomeWidget.saveWidgetData<String>('today_spending', '₹${totalToday.toStringAsFixed(2)}');
      await HomeWidget.saveWidgetData<String>('today_count', countText);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (_) {
      // Gracefully handle widget sync platform exceptions if any
    }
  }
}
