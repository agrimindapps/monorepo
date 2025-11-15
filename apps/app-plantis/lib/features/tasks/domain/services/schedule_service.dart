import 'package:flutter/foundation.dart';

/// ScheduleService - Handles recurring task and reminder calculations
///
/// Responsibilities (SRP - <250 lines):
/// - Calculate next due dates for recurring tasks
/// - Determine reminder times
/// - Handle task scheduling logic
/// - Compute overdue task lists
/// - Generate upcoming task schedules
///
/// This service is injected via Riverpod (DIP)
abstract class IScheduleService {
  /// Calculate next due date for recurring task
  DateTime? calculateNextDueDate(
    DateTime currentDueDate,
    String interval,
    DateTime? endDate,
  );

  /// Determine if task is overdue
  bool isOverdue(DateTime? dueDate);

  /// Calculate days until due
  int daysUntilDue(DateTime? dueDate);

  /// Format due date for display
  String formatDueDate(DateTime? dueDate);
}

class ScheduleService implements IScheduleService {
  @override
  DateTime? calculateNextDueDate(
    DateTime currentDueDate,
    String interval,
    DateTime? endDate,
  ) {
    DateTime nextDate;

    switch (interval.toLowerCase()) {
      case 'daily':
        nextDate = currentDueDate.add(const Duration(days: 1));
        break;
      case 'weekly':
        nextDate = currentDueDate.add(const Duration(days: 7));
        break;
      case 'biweekly':
        nextDate = currentDueDate.add(const Duration(days: 14));
        break;
      case 'monthly':
        nextDate = DateTime(
          currentDueDate.year,
          currentDueDate.month + 1,
          currentDueDate.day,
        );
        break;
      case 'quarterly':
        nextDate = DateTime(
          currentDueDate.year,
          currentDueDate.month + 3,
          currentDueDate.day,
        );
        break;
      case 'yearly':
        nextDate = DateTime(
          currentDueDate.year + 1,
          currentDueDate.month,
          currentDueDate.day,
        );
        break;
      default:
        debugPrint('Unknown interval: $interval');
        return null;
    }

    // Check if recurring should end
    if (endDate != null && nextDate.isAfter(endDate)) {
      return null;
    }

    return nextDate;
  }

  @override
  bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  @override
  int daysUntilDue(DateTime? dueDate) {
    if (dueDate == null) return -1;
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  @override
  String formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay == today) {
      return 'Today';
    } else if (dueDay == tomorrow) {
      return 'Tomorrow';
    } else if (dueDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }
}
