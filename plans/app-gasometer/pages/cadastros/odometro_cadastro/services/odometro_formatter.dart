// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/odometro_constants.dart';

/// Centralized formatting service for odometer values and dates
class OdometroFormatter {
  // Private constructor to prevent instantiation
  OdometroFormatter._();

  /// Formats odometer values with proper decimal places and separator
  static String formatOdometer(double value) {
    return value.toStringAsFixed(OdometroConstants.decimalPlaces).replaceAll(
        OdometroConstants.dotSeparator, OdometroConstants.decimalSeparator);
  }

  /// Parses string odometer value to double
  static double parseOdometer(String value) {
    final cleanValue = value.replaceAll(
        OdometroConstants.decimalSeparator, OdometroConstants.dotSeparator);
    return double.tryParse(cleanValue) ?? OdometroConstants.defaultOdometro;
  }

  /// Cleans odometer value for parsing
  static String cleanOdometerValue(String value) {
    return value.replaceAll(
        OdometroConstants.decimalSeparator, OdometroConstants.dotSeparator);
  }

  /// Formats date as dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formats time as HH:mm
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formats complete date and time
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// Formats date for display in form fields
  static String formatDateForDisplay(DateTime date) {
    return formatDate(date);
  }

  /// Formats time for display in form fields
  static String formatTimeForDisplay(DateTime date) {
    return formatTime(date);
  }
}
