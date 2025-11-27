import 'package:flutter/material.dart';
import '../../core/constants/maintenance_constants.dart';

/// Helper class for date/time picker operations in maintenance forms
///
/// Responsibilities:
/// - Service date picker
/// - Service time picker
/// - Next service date picker
/// - Date/time theme configuration
class MaintenanceDatePickerHelper {
  const MaintenanceDatePickerHelper();

  /// Opens date picker for service date
  Future<DateTime?> pickServiceDate(
    BuildContext context, {
    DateTime? currentDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * MaintenanceConstants.maxYearsBack),
      ),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: _buildDatePickerTheme,
    );

    if (date != null) {
      final currentTime = TimeOfDay.fromDateTime(currentDate ?? DateTime.now());
      return DateTime(
        date.year,
        date.month,
        date.day,
        currentTime.hour,
        currentTime.minute,
      );
    }
    return null;
  }

  /// Opens time picker for service time
  Future<DateTime?> pickServiceTime(
    BuildContext context, {
    DateTime? currentDate,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate ?? DateTime.now()),
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
      final currentDateTime = currentDate ?? DateTime.now();
      return DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        time.hour,
        time.minute,
      );
    }
    return null;
  }

  /// Opens date picker for next service date
  Future<DateTime?> pickNextServiceDate(
    BuildContext context, {
    DateTime? currentNextDate,
    DateTime? serviceDate,
  }) async {
    final baseDate = serviceDate ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: currentNextDate ?? baseDate.add(const Duration(days: 180)),
      firstDate: baseDate,
      lastDate: baseDate.add(
        const Duration(days: 365 * MaintenanceConstants.maxYearsForward),
      ),
      locale: const Locale('pt', 'BR'),
      builder: _buildDatePickerTheme,
    );

    return date;
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
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
  }
}
