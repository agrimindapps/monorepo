import '../../domain/entities/odometer_entity.dart';

/// Service responsible for odometer data formatting
///
/// Follows SRP by handling only formatting concerns
class OdometerFormatterService {
  /// Formats odometer value with unit
  String formatValue(double value) {
    return '${value.toStringAsFixed(0)} km';
  }

  /// Formats odometer value in short format (K for thousands)
  String formatValueShort(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K km';
    }
    return '${value.toStringAsFixed(0)} km';
  }

  /// Formats odometer type for display
  String formatType(OdometerType type) {
    return type.displayName;
  }

  /// Formats registration date
  String formatRegistrationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }

  /// Formats distance between two readings
  String formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}K km';
    }
    return '${distance.toStringAsFixed(0)} km';
  }

  /// Formats reading summary for list display
  String formatReadingSummary(OdometerEntity reading) {
    final parts = <String>[
      formatValue(reading.value),
      reading.type.displayName,
    ];

    if (reading.description.isNotEmpty) {
      final shortDesc = reading.description.length > 30
          ? '${reading.description.substring(0, 30)}...'
          : reading.description;
      parts.add(shortDesc);
    }

    return parts.join(' • ');
  }

  /// Formats period description
  String formatPeriod(DateTime start, DateTime end) {
    final startStr = '${start.day}/${start.month}/${start.year}';
    final endStr = '${end.day}/${end.month}/${end.year}';
    return '$startStr - $endStr';
  }

  /// Formats average per day
  String formatAveragePerDay(double kmPerDay) {
    if (kmPerDay < 1) {
      return '${(kmPerDay * 1000).toStringAsFixed(0)}m/dia';
    }
    return '${kmPerDay.toStringAsFixed(1)} km/dia';
  }

  /// Formats average per month
  String formatAveragePerMonth(double kmPerMonth) {
    if (kmPerMonth >= 1000) {
      return '${(kmPerMonth / 1000).toStringAsFixed(1)}K km/mês';
    }
    return '${kmPerMonth.toStringAsFixed(0)} km/mês';
  }
}
