import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String toDisplayDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toMonthYear() {
    return DateFormat('MMM yyyy').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  String toRelativeDate() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays == 0) {
      if (isSameDay(now)) return 'Today';
      return 'Yesterday';
    } else if (difference.inDays == 1 && now.day != day) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return toDisplayDate();
  }
}
