import 'package:core/core.dart' show Equatable;
import 'package:flutter/foundation.dart';

/// Represents a range of dates, inclusive of the start and end dates.
///
/// This class provides factory constructors for common ranges (e.g., current month,
/// last 30 days) and utility methods for calculations and comparisons.
@immutable
class DateRange extends Equatable {
  /// The starting date of the range (inclusive).
  final DateTime startDate;

  /// The ending date of the range (inclusive).
  final DateTime endDate;

  /// Creates a new [DateRange].
  ///
  /// Throws an [AssertionError] in debug mode if [endDate] is before [startDate].
  const DateRange({required this.startDate, required this.endDate})
      : assert(!endDate.isBefore(startDate), 'endDate cannot be before startDate');

  /// Creates a date range for the current month.
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    // Setting day to 0 in the next month gives the last day of the current month.
    final end = DateTime(now.year, now.month + 1, 0);
    return DateRange(startDate: start, endDate: end);
  }

  /// Creates a date range for the current year.
  factory DateRange.currentYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    return DateRange(startDate: start, endDate: end);
  }

  /// Creates a date range for the last N days, ending today.
  ///
  /// For example, `lastDays(7)` includes today and the 6 previous days.
  factory DateRange.lastDays(int days) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(Duration(days: days - 1));
    return DateRange(startDate: start, endDate: end);
  }

  /// Creates a date range for a specific month and year.
  factory DateRange.month(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return DateRange(startDate: start, endDate: end);
  }

  /// The duration between the start and end dates.
  Duration get duration => endDate.difference(startDate);

  /// The total number of days in the range, inclusive.
  int get dayCount => duration.inDays + 1;

  /// Checks if a given [date] falls within this range (inclusive).
  ///
  /// This method normalizes the time part of the dates to ensure accurate
  /// day-based comparison.
  bool contains(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return !normalizedDate.isBefore(normalizedStart) && !normalizedDate.isAfter(normalizedEnd);
  }

  /// Checks if this range overlaps with another [DateRange].
  bool overlaps(DateRange other) {
    // Two ranges overlap if range A's start is not after range B's end,
    // AND range A's end is not before range B's start.
    return !startDate.isAfter(other.endDate) && !endDate.isBefore(other.startDate);
  }

  /// Formats the date range as a string (e.g., "01/01/2023 - 31/01/2023").
  ///
  /// TODO: Use the `intl` package for more robust and localized formatting.
  String format([String separator = ' - ']) {
    final startStr =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final endStr =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    return '$startStr$separator$endStr';
  }

  /// Returns a user-friendly description of the date range.
  ///
  /// These strings should be localized in a real application.
  String get description {
    final now = DateTime.now();
    if (startDate.year == now.year &&
        startDate.month == now.month &&
        endDate.year == now.year &&
        endDate.month == now.month &&
        startDate.day == 1 &&
        endDate.day == DateTime(now.year, now.month + 1, 0).day) {
      return 'This month'; // l10n
    }

    if (startDate.year == now.year &&
        endDate.year == now.year &&
        startDate.month == 1 &&
        startDate.day == 1 &&
        endDate.month == 12 &&
        endDate.day == 31) {
      return 'This year'; // l10n
    }

    if (dayCount == 1) {
      return format();
    }

    if (dayCount <= 7) {
      return 'Last $dayCount days'; // l10n
    }

    if (dayCount <= 31) {
      return 'Last ${(dayCount / 7).round()} weeks'; // l10n
    }

    return format();
  }

  /// Creates a copy of this [DateRange] but with the given fields replaced
  /// with the new values.
  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate];
}