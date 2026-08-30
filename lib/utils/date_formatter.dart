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
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  /// Format date as "10 Mar 2026"
  static String formatShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
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

  /// Get 3-letter weekday abbreviation (Sun, Mon, etc.)
  static String getWeekdayAbbr(int weekdayIndex) {
    // weekdayIndex 0..6 where 0 = Sun or 1 = Mon depending on standard.
    // Let's standardise 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
    return _shortWeekdays[weekdayIndex % 7];
  }
}
