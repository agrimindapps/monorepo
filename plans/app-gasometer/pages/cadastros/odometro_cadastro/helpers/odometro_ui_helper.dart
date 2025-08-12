// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/odometro_constants.dart';
import '../services/odometro_formatter.dart';

/// Helper class responsible for UI interactions and dialogs
///
/// This class separates UI concerns from business logic,
/// making the controller testable without Flutter dependencies
class OdometroUIHelper {
  /// Shows date picker dialog
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context,
    DateTime initialDate,
  ) async {
    return await showDatePicker(
      context: context,
      cancelText: OdometroConstants.dateTimeLabels['cancelar'],
      confirmText: OdometroConstants.dateTimeLabels['confirmar'],
      helpText: OdometroConstants.dateTimeLabels['selecioneData'],
      currentDate: DateTime.now(),
      initialDate: initialDate,
      firstDate: OdometroConstants.minDate,
      lastDate: OdometroConstants.maxDate,
      locale: const Locale('pt', 'BR'),
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
  }

  /// Shows time picker dialog
  static Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context,
    DateTime initialTime,
  ) async {
    return await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      hourLabelText: OdometroConstants.dateTimeLabels['hora'],
      minuteLabelText: OdometroConstants.dateTimeLabels['minuto'],
      helpText: OdometroConstants.dateTimeLabels['selecioneHora'],
      cancelText: OdometroConstants.dateTimeLabels['cancelar'],
      confirmText: OdometroConstants.dateTimeLabels['confirmar'],
      initialTime: TimeOfDay(
        hour: initialTime.hour,
        minute: initialTime.minute,
      ),
    );
  }

  /// Shows error dialog
  static void showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(OdometroConstants.dialogMessages['ok']!),
          ),
        ],
      ),
    );
  }

  /// Shows error message with default title
  static void showErrorMessage(String? errorMessage) {
    final message =
        errorMessage ?? OdometroConstants.validationMessages['erroGenerico']!;
    showErrorDialog(
      OdometroConstants.dialogMessages['erro']!,
      message,
    );
  }

  /// Formats date for display
  static String formatDate(DateTime date) => OdometroFormatter.formatDate(date);

  /// Formats time for display
  static String formatTime(DateTime date) => OdometroFormatter.formatTime(date);
}
