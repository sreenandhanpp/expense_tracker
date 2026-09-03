class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _shortWeekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  /// Format date as "10 Mar 2026"
  static String formatShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }

  /// Format date as "10 Mar"
  static String formatDayMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month';
  }

  /// Format ISO date string "YYYY-MM-DD"
  static String formatIsoDate(DateTime date) {
    final yyyy = date.year;
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  /// Format week range string e.g. "10 Aug – 16 Aug 2026"
  static String formatWeekRange(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    if (monday.year == sunday.year) {
      return '${formatDayMonth(monday)} – ${formatDayMonth(sunday)} ${monday.year}';
    } else {
      return '${formatShort(monday)} – ${formatShort(sunday)}';
    }
  }

  /// Format relative day like "TODAY", "YESTERDAY", or "Monday"
  static String formatGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7 && difference > 1) {
      return _weekdays[date.weekday - 1];
    } else {
      return formatShort(date);
    }
  }

  /// Get 3-letter weekday abbreviation (0 = Mon, 1 = Tue, ..., 6 = Sun)
  static String getWeekdayAbbr(int index) {
    return _shortWeekdays[index % 7];
  }

  /// Get full weekday name (0 = Mon, 1 = Tue, ..., 6 = Sun)
  static String getWeekdayName(int index) {
    return _weekdays[index % 7];
  }
}
