import 'package:injectable/injectable.dart';

/// Utility class for date-related calculations and formatting
/// 
/// Provides reusable date manipulation methods to avoid code duplication
/// across the application.
@lazySingleton
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
}
