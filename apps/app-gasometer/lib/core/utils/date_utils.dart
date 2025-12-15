
/// Utility class for date-related calculations and formatting
/// 
/// Provides reusable date manipulation methods to avoid code duplication
/// across the application.
library;

class DateUtils {
  /// Generates a consistent month key in YYYY-MM format for date grouping
  /// 
  /// This method optimizes string generation for monthly data aggregation
  /// by providing a centralized way to create month keys.
  /// 
  /// [date] The date to generate a month key for
  /// 
  /// Returns a string in the format 'YYYY-MM' (e.g., '2024-03')
  String generateMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Safely calculates a start date by subtracting months from an end date
  /// 
  /// Handles edge cases like leap years, different month lengths, and overflow scenarios.
  /// 
  /// [endDate] The reference end date
  /// [months] Number of months to subtract (must be positive)
  /// 
  /// Returns a DateTime representing the calculated start date
  DateTime calculateSafeStartDate(DateTime endDate, int months) {
    if (months <= 0) {
      return endDate;
    }

    int targetYear = endDate.year;
    int targetMonth = endDate.month;
    int targetDay = endDate.day;

    targetMonth -= months;

    while (targetMonth <= 0) {
      targetYear--;
      targetMonth += 12;
    }

    final lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > lastDayOfTargetMonth) {
      targetDay = lastDayOfTargetMonth;
    }

    try {
      return DateTime(targetYear, targetMonth, targetDay, endDate.hour, endDate.minute, endDate.second);
    } catch (e) {
      return DateTime(targetYear, targetMonth, 1, endDate.hour, endDate.minute, endDate.second);
    }
  }

  /// Generates a list of months between the oldest and newest date in the list.
  /// Returns months in descending order (most recent first).
  /// If the list is empty, returns a list containing only the current month.
  List<DateTime> generateMonthRange(List<DateTime> dates) {
    if (dates.isEmpty) {
      final now = DateTime.now();
      return [DateTime(now.year, now.month)];
    }

    DateTime minDate = dates.first;
    DateTime maxDate = dates.first;

    for (final date in dates) {
      if (date.isBefore(minDate)) minDate = date;
      if (date.isAfter(maxDate)) maxDate = date;
    }

    // Normalize to start of month
    minDate = DateTime(minDate.year, minDate.month);
    maxDate = DateTime(maxDate.year, maxDate.month);

    final months = <DateTime>[];
    var current = maxDate; // Começar do mais recente

    // Iterar do mais recente para o mais antigo
    while (current.isAfter(minDate) || current.isAtSameMomentAs(minDate)) {
      months.add(current);
      // Move to previous month
      if (current.month == 1) {
        current = DateTime(current.year - 1, 12);
      } else {
        current = DateTime(current.year, current.month - 1);
      }
    }

    return months;
  }
}
