import 'package:core/core.dart' show Equatable;

/// Represents a date range with start and end dates
class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({required this.startDate, required this.endDate});

  /// Creates a date range for the current month
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateRange(startDate: startOfMonth, endDate: endOfMonth);
  }

  /// Creates a date range for the current year
  factory DateRange.currentYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    return DateRange(startDate: startOfYear, endDate: endOfYear);
  }

  /// Creates a date range for the last N days
  factory DateRange.lastDays(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return DateRange(startDate: startDate, endDate: now);
  }

  /// Creates a date range for a specific month
  factory DateRange.month(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);
    return DateRange(startDate: startOfMonth, endDate: endOfMonth);
  }

  /// Duration between start and end dates
  Duration get duration => endDate.difference(startDate);

  /// Number of days in the range
  int get dayCount => duration.inDays + 1;

  /// Check if a date falls within this range
  bool contains(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Check if this range overlaps with another range
  bool overlaps(DateRange other) {
    return startDate.isBefore(other.endDate.add(const Duration(days: 1))) &&
        endDate.isAfter(other.startDate.subtract(const Duration(days: 1)));
  }

  /// Format the date range as a string
  String format([String separator = ' - ']) {
    final startStr = '${startDate.day}/${startDate.month}/${startDate.year}';
    final endStr = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$startStr$separator$endStr';
  }

  /// Get a readable description of the range
  String get description {
    final now = DateTime.now();
    if (startDate.year == now.year &&
        startDate.month == now.month &&
        endDate.year == now.year &&
        endDate.month == now.month) {
      return 'Este mês';
    }

    if (startDate.year == now.year && endDate.year == now.year) {
      return 'Este ano';
    }

    if (dayCount == 1) {
      return '${startDate.day}/${startDate.month}/${startDate.year}';
    }

    if (dayCount <= 7) {
      return 'Últimos $dayCount dias';
    }

    if (dayCount <= 31) {
      return 'Últimas ${(dayCount / 7).round()} semanas';
    }

    return format();
  }

  @override
  List<Object?> get props => [startDate, endDate];
}
