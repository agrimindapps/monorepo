import 'package:intl/intl.dart';
import '../entities/maintenance_entity.dart';

/// Serviço especializado para formatação de dados de manutenção
class MaintenanceFormatterService {
  factory MaintenanceFormatterService() => _instance;
  MaintenanceFormatterService._internal();
  static final MaintenanceFormatterService _instance =
      MaintenanceFormatterService._internal();
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final NumberFormat _odometerFormatter = NumberFormat('#,##0.0', 'pt_BR');
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');
  final DateFormat _timeFormatter = DateFormat('HH:mm', 'pt_BR');
  final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  final Map<String, String> _formatCache = {};
  static const int maxCacheSize = 100;

  /// Formata valores monetários
  String formatAmount(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, 2, 'amount', () {
      return _currencyFormatter.format(value);
    });
  }

  /// Formata odômetro com uma casa decimal
  String formatOdometer(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, 1, 'odometer', () {
      return _odometerFormatter.format(value);
    });
  }

  /// Formata data no padrão brasileiro
  String formatDate(DateTime date) {
    return _formatWithCache(date.millisecondsSinceEpoch, 0, 'date', () {
      return _dateFormatter.format(date);
    });
  }

  /// Formata hora no padrão brasileiro
  String formatTime(DateTime time) {
    return _formatWithCache(time.millisecondsSinceEpoch, 0, 'time', () {
      return _timeFormatter.format(time);
    });
  }

  /// Formata data e hora
  String formatDateTime(DateTime dateTime) {
    return _formatWithCache(dateTime.millisecondsSinceEpoch, 0, 'datetime', () {
      return _dateTimeFormatter.format(dateTime);
    });
  }

  /// Formatar com cache para otimização
  String _formatWithCache(
    num value,
    int decimals,
    String type,
    String Function() formatter,
  ) {
    final key = '${type}_${value}_$decimals';

    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    final formatted = formatter();
    if (_formatCache.length >= maxCacheSize) {
      _formatCache.clear();
    }

    _formatCache[key] = formatted;
    return formatted;
  }

  /// Parse de valores formatados para double
  double parseFormattedAmount(String value) {
    if (value.isEmpty) return 0.0;
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll('.', '') // Remove separador de milhares
        .replaceAll(',', '.') // Converte decimal
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Parse de odômetro formatado para double
  double parseFormattedOdometer(String value) {
    if (value.isEmpty) return 0.0;
    final cleaned = value
        .replaceAll('km', '')
        .replaceAll('.', '') // Remove separador de milhares
        .replaceAll(',', '.') // Converte decimal
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Sanitiza entrada de texto
  String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formata telefone brasileiro
  String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    }

    return phone; // Retorna original se não conseguir formatar
  }

  /// Formata tipo de manutenção com ícone
  String formatTypeWithIcon(MaintenanceType type) {
    return '${_getTypeIcon(type)} ${type.displayName}';
  }

  /// Formata status com ícone
  String formatStatusWithIcon(MaintenanceStatus status) {
    return '${_getStatusIcon(status)} ${status.displayName}';
  }

  String _getTypeIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return '🔧';
      case MaintenanceType.corrective:
        return '⚠️';
      case MaintenanceType.inspection:
        return '🔍';
      case MaintenanceType.emergency:
        return '🚨';
    }
  }

  String _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return '⏳';
      case MaintenanceStatus.inProgress:
        return '⚙️';
      case MaintenanceStatus.completed:
        return '✅';
      case MaintenanceStatus.cancelled:
        return '❌';
    }
  }

  /// Formatar período entre manutenções
  String formatServiceInterval(DateTime from, DateTime to) {
    final difference = to.difference(from);

    if (difference.inDays < 1) {
      return 'Mesmo dia';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round();
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).round();
      final remainingMonths = ((difference.inDays % 365) / 30).round();

      String result = '$years ${years == 1 ? 'ano' : 'anos'}';
      if (remainingMonths > 0) {
        result +=
            ' e $remainingMonths ${remainingMonths == 1 ? 'mês' : 'meses'}';
      }
      return result;
    }
  }

  /// Formatar quilometragem entre manutenções
  String formatOdometerInterval(double from, double to) {
    final difference = to - from;

    if (difference < 1000) {
      return '${difference.toStringAsFixed(0)} km';
    } else {
      final thousands = (difference / 1000).toStringAsFixed(1);
      return '${thousands.replaceAll('.', ',')} mil km';
    }
  }

  /// Formatar resumo de manutenção
  String formatMaintenanceSummary(MaintenanceEntity maintenance) {
    final parts = <String>[
      maintenance.type.displayName,
      formatAmount(maintenance.cost),
      formatDate(maintenance.serviceDate),
    ];

    if (maintenance.hasWorkshopInfo) {
      parts.add(maintenance.workshopName!);
    }

    return parts.join(' • ');
  }

  /// Formatar lista de peças
  String formatPartsList(Map<String, String> parts) {
    if (parts.isEmpty) return 'Nenhuma peça registrada';

    return parts.entries
        .map((entry) {
          final partName = entry.key;
          final partInfo = entry.value;
          return partInfo.isNotEmpty ? '$partName ($partInfo)' : partName;
        })
        .join(', ');
  }

  /// Formatar próxima manutenção
  String formatNextService(
    MaintenanceEntity maintenance,
    double currentOdometer,
  ) {
    final List<String> nextService = [];

    if (maintenance.nextServiceDate != null) {
      nextService.add('Data: ${formatDate(maintenance.nextServiceDate!)}');
    }

    if (maintenance.nextServiceOdometer != null) {
      nextService.add(
        'Odômetro: ${formatOdometer(maintenance.nextServiceOdometer!)} km',
      );

      final remaining = maintenance.nextServiceOdometer! - currentOdometer;
      if (remaining > 0) {
        nextService.add('Faltam: ${formatOdometer(remaining)} km');
      } else {
        nextService.add('Atrasada em: ${formatOdometer(-remaining)} km');
      }
    }

    return nextService.isEmpty ? 'Não programada' : nextService.join(' • ');
  }

  /// Limpar cache
  void clearCache() {
    _formatCache.clear();
  }
}
