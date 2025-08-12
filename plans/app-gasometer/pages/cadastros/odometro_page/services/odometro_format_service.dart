// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../models/odometro_page_constants.dart';

/// Service responsible for all data formatting operations in the Odometro module
class OdometroFormatService extends GetxService {
  /// Format month for display using locale-specific formatting
  String formatMonth(DateTime date) {
    final formatted = DateFormat(
      OdometroPageConstants.monthYearFormat,
      OdometroPageConstants.locale,
    ).format(date);
    return _capitalizeString(formatted);
  }

  /// Format current month for display
  String formatCurrentMonth() {
    return formatMonth(DateTime.now());
  }

  /// Format date header for monthly navigation
  String formatDateHeader(DateTime date) {
    return DateFormat('MMM yy', 'pt_BR').format(date);
  }

  /// Format odometer reading with proper localization
  String formatOdometerReading(double reading) {
    final formatter = NumberFormat('#,##0', OdometroPageConstants.locale);
    return '${formatter.format(reading)} km';
  }

  /// Format distance difference between readings
  String formatDistanceDifference(double difference) {
    if (difference <= 0) return '--';

    final formatter = NumberFormat('#,##0.0', OdometroPageConstants.locale);
    return '${formatter.format(difference)} km';
  }

  /// Format statistics values for display
  Map<String, String> formatStatistics(Map<String, dynamic> stats) {
    final formatter = NumberFormat('#,##0.0', OdometroPageConstants.locale);

    return {
      'totalRecords': stats['totalRecords']?.toString() ?? '0',
      'totalDistance': stats['totalDistance'] != null
          ? '${formatter.format(stats['totalDistance'])} km'
          : '0 km',
      'averagePerDay': stats['averagePerDay'] != null
          ? '${formatter.format(stats['averagePerDay'])} km/dia'
          : '0 km/dia',
      'maxOdometer': stats['maxOdometer'] != null
          ? '${formatter.format(stats['maxOdometer'])} km'
          : '0 km',
      'minOdometer': stats['minOdometer'] != null
          ? '${formatter.format(stats['minOdometer'])} km'
          : '0 km',
    };
  }

  /// Format date range for display
  String formatDateRange(DateTime start, DateTime end) {
    final startFormatted =
        DateFormat('dd/MM/yyyy', OdometroPageConstants.locale).format(start);
    final endFormatted =
        DateFormat('dd/MM/yyyy', OdometroPageConstants.locale).format(end);
    return '$startFormatted - $endFormatted';
  }

  /// Format relative time (e.g., "2 dias atrás")
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 ano atrás' : '$years anos atrás';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mês atrás' : '$months meses atrás';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 dia atrás'
          : '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hora atrás'
          : '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minuto atrás'
          : '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  /// Format duration in a human-readable way
  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return duration.inDays == 1 ? '1 dia' : '${duration.inDays} dias';
    } else if (duration.inHours > 0) {
      return duration.inHours == 1 ? '1 hora' : '${duration.inHours} horas';
    } else if (duration.inMinutes > 0) {
      return duration.inMinutes == 1
          ? '1 minuto'
          : '${duration.inMinutes} minutos';
    } else {
      return 'Menos de 1 minuto';
    }
  }

  /// Format percentage values
  String formatPercentage(double value) {
    final formatter = NumberFormat('#,##0.0%', OdometroPageConstants.locale);
    return formatter.format(value / 100);
  }

  /// Format fuel efficiency (km per liter)
  String formatFuelEfficiency(double kmPerLiter) {
    final formatter = NumberFormat('#,##0.0', OdometroPageConstants.locale);
    return '${formatter.format(kmPerLiter)} km/L';
  }

  /// Validate and format user input for odometer readings
  String? validateOdometerInput(String input) {
    if (input.isEmpty) {
      return 'Campo obrigatório';
    }

    // Remove non-numeric characters except comma and dot
    final cleanInput = input.replaceAll(RegExp(r'[^\d,.]'), '');

    // Replace comma with dot for parsing
    final normalizedInput = cleanInput.replaceAll(',', '.');

    final value = double.tryParse(normalizedInput);
    if (value == null) {
      return 'Digite apenas números';
    }

    if (value < 0) {
      return 'O valor deve ser positivo';
    }

    if (value > 9999999) {
      return 'Valor muito alto';
    }

    return null; // Valid input
  }

  /// Helper method to capitalize first letter of a string
  String _capitalizeString(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  /// Get formatted month list for navigation
  List<String> getFormattedMonthsList(List<DateTime> months) {
    return months.map((month) => formatMonth(month)).toList();
  }

  /// Format file name for exports
  String formatExportFileName(String prefix, DateTime date) {
    final dateFormatted = DateFormat('yyyy-MM-dd_HH-mm-ss').format(date);
    return '${prefix}_$dateFormatted';
  }

  /// Format file size in human readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
