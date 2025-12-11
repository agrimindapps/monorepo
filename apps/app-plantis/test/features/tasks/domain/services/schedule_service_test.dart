import 'package:app_plantis/features/tasks/domain/services/schedule_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IScheduleService scheduleService;

  setUp(() {
    scheduleService = ScheduleService();
  });

  group('ScheduleService', () {
    test('calculateNextDueDate with daily interval', () {
      final currentDate = DateTime(2024, 11, 15);
      final nextDate = scheduleService.calculateNextDueDate(
        currentDate,
        'daily',
        null,
      );

      expect(nextDate, DateTime(2024, 11, 16));
    });

    test('calculateNextDueDate with weekly interval', () {
      final currentDate = DateTime(2024, 11, 15);
      final nextDate = scheduleService.calculateNextDueDate(
        currentDate,
        'weekly',
        null,
      );

      expect(nextDate, DateTime(2024, 11, 22));
    });

    test('calculateNextDueDate with biweekly interval', () {
      final currentDate = DateTime(2024, 11, 15);
      final nextDate = scheduleService.calculateNextDueDate(
        currentDate,
        'biweekly',
        null,
      );

      expect(nextDate, DateTime(2024, 11, 29));
    });

    test('calculateNextDueDate with monthly interval', () {
      final currentDate = DateTime(2024, 11, 15);
      final nextDate = scheduleService.calculateNextDueDate(
        currentDate,
        'monthly',
        null,
      );

      expect(nextDate, DateTime(2024, 12, 15));
    });

    test('calculateNextDueDate returns null for invalid interval', () {
      final currentDate = DateTime(2024, 11, 15);
      final nextDate = scheduleService.calculateNextDueDate(
        currentDate,
        'invalid',
        null,
      );

      expect(nextDate, isNull);
    });

    test('calculateNextDueDate respects end date', () {
      final currentDate = DateTime(2024, 11, 15);
      final endDate = DateTime(2024, 11, 20);
      final nextDate = scheduleService.calculateNextDueDate(
        currentDate,
        'daily',
        endDate,
      );

      // Next date is after end date, should return null
      expect(nextDate, isNull);
    });

    test('isOverdue returns true for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      expect(scheduleService.isOverdue(pastDate), true);
    });

    test('isOverdue returns false for future dates', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      expect(scheduleService.isOverdue(futureDate), false);
    });

    test('isOverdue returns false for null date', () {
      expect(scheduleService.isOverdue(null), false);
    });

    test('daysUntilDue returns positive for future dates', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final days = scheduleService.daysUntilDue(futureDate);

      expect(days, greaterThanOrEqualTo(4)); // At least 4 days
      expect(days, lessThanOrEqualTo(5)); // At most 5 days
    });

    test('daysUntilDue returns negative for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final days = scheduleService.daysUntilDue(pastDate);

      expect(days, lessThanOrEqualTo(-2)); // At most -2 days
      expect(days, greaterThanOrEqualTo(-4)); // At least -4 days
    });

    test('daysUntilDue returns 0 for null date', () {
      expect(scheduleService.daysUntilDue(null), 0);
    });

    test('formatDueDate formats date correctly', () {
      final date = DateTime(2024, 11, 15, 14, 30);
      final formatted = scheduleService.formatDueDate(date);

      expect(formatted, isNotEmpty);
      expect(formatted, contains('15')); // Day
    });

    test('formatDueDate handles null date', () {
      final formatted = scheduleService.formatDueDate(null);
      expect(formatted, isNotEmpty);
    });

    test('calculateNextDueDate case-insensitive interval matching', () {
      final currentDate = DateTime(2024, 11, 15);

      final nextDaily = scheduleService.calculateNextDueDate(
        currentDate,
        'DAILY',
        null,
      );

      final nextWeekly = scheduleService.calculateNextDueDate(
        currentDate,
        'WeEkLy',
        null,
      );

      expect(nextDaily, DateTime(2024, 11, 16));
      expect(nextWeekly, DateTime(2024, 11, 22));
    });

    test('calculateNextDueDate handles month boundaries', () {
      final dateEndOfMonth = DateTime(2024, 1, 31);
      final nextDate = scheduleService.calculateNextDueDate(
        dateEndOfMonth,
        'monthly',
        null,
      );

      // February doesn't have 31st, should handle gracefully
      expect(nextDate, isNotNull);
    });
  });
}
