import 'package:flutter/material.dart';

/// Helper for date and time picker operations in expense forms
///
/// Responsibilities:
/// - Date picker display and handling
/// - Time picker display and handling
/// - DateTime combination
class ExpenseDatePickerHelper {
  const ExpenseDatePickerHelper();

  /// Shows date picker and returns selected date
  Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365 * 10)),
      lastDate: lastDate ?? now,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && initialDate != null) {
      final time = TimeOfDay.fromDateTime(initialDate);
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    return date;
  }

  /// Shows time picker and returns updated DateTime
  Future<DateTime?> pickTime(
    BuildContext context, {
    DateTime? initialDateTime,
  }) async {
    final now = DateTime.now();
    final initial = initialDateTime ?? now;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      return DateTime(
        initial.year,
        initial.month,
        initial.day,
        time.hour,
        time.minute,
      );
    }

    return null;
  }
}
