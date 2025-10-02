import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for maintenance data formatting
///
/// Follows SRP by handling only formatting concerns
class MaintenanceFormatterService {
  /// Formats maintenance cost
  String formatCost(double cost) {
    return 'R\$ ${cost.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formats cost in short format (K for thousands)
  String formatCostShort(double cost) {
    if (cost >= 1000) {
      return 'R\$ ${(cost / 1000).toStringAsFixed(1)}K';
    }
    return 'R\$ ${cost.toStringAsFixed(0)}';
  }

  /// Formats odometer reading
  String formatOdometer(double odometer) {
    return '${odometer.toStringAsFixed(0)} km';
  }

  /// Formats maintenance type
  String formatType(MaintenanceType type) {
    return type.displayName;
  }

  /// Formats maintenance status
  String formatStatus(MaintenanceStatus status) {
    return status.displayName;
  }

  /// Formats service date
  String formatServiceDate(DateTime date) {
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

  /// Formats next service date
  String formatNextServiceDate(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays < 0) {
      return 'Vencida há ${(-difference.inDays)} dias';
    } else if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Amanhã';
    } else if (difference.inDays < 7) {
      return 'Em ${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Em $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Em $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Em $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  /// Formats workshop phone number
  String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    if (cleanPhone.length == 11) {
      // (99) 99999-9999
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    } else if (cleanPhone.length == 10) {
      // (99) 9999-9999
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    }

    return phone;
  }

  /// Formats maintenance summary for list display
  String formatSummary(MaintenanceEntity maintenance) {
    final parts = <String>[
      maintenance.type.displayName,
      formatCost(maintenance.cost),
    ];

    if (maintenance.hasWorkshopInfo && maintenance.workshopName != null) {
      parts.add(maintenance.workshopName!);
    }

    return parts.join(' • ');
  }

  /// Formats urgency level
  String formatUrgencyLevel(String urgency) {
    switch (urgency) {
      case 'overdue':
        return 'Vencida';
      case 'urgent':
        return 'Urgente';
      case 'soon':
        return 'Em Breve';
      case 'normal':
        return 'Normal';
      default:
        return 'N/A';
    }
  }

  /// Formats parts list
  String formatParts(Map<String, String> parts) {
    if (parts.isEmpty) return 'Nenhuma peça registrada';

    final formatted = parts.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return formatted.length > 100 ? '${formatted.substring(0, 100)}...' : formatted;
  }

  /// Formats time since service
  String formatTimeSinceService(DateTime serviceDate) {
    final now = DateTime.now();
    final difference = now.difference(serviceDate);

    if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  /// Formats maintenance progress
  String formatProgress(double progress) {
    final percentage = (progress * 100).toStringAsFixed(0);
    return '$percentage%';
  }
}
