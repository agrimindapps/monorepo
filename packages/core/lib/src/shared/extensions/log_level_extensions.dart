import 'package:flutter/material.dart';
import '../enums/log_level.dart';

/// Extensões para o enum LogLevel
extension LogLevelExtensions on LogLevel {
  /// Cor associada ao nível do log
  Color get color {
    switch (this) {
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.debug:
        return Colors.grey;
    }
  }

  /// Ícone associado ao nível do log
  IconData get icon {
    switch (this) {
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.debug:
        return Icons.bug_report;
    }
  }

  /// Prioridade do log (maior número = maior prioridade)
  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
    }
  }

  /// Nome formatado do nível
  String get displayName {
    switch (this) {
      case LogLevel.info:
        return 'Info';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
      case LogLevel.debug:
        return 'Debug';
    }
  }

  /// Nome em maiúsculo para logs
  String get logName => name.toUpperCase();

  /// Verifica se é um nível crítico
  bool get isCritical => this == LogLevel.error;

  /// Verifica se é um nível de produção
  bool get isProductionLevel {
    switch (this) {
      case LogLevel.error:
      case LogLevel.warning:
      case LogLevel.info:
        return true;
      case LogLevel.debug:
        return false;
    }
  }

  /// Verifica se é um nível de desenvolvimento
  bool get isDevelopmentLevel => this == LogLevel.debug;

  /// Obtém a cor do texto baseada no fundo
  Color get textColor {
    switch (this) {
      case LogLevel.error:
        return Colors.white;
      case LogLevel.warning:
        return Colors.black;
      case LogLevel.info:
        return Colors.white;
      case LogLevel.debug:
        return Colors.white;
    }
  }

  /// Obtém cor de fundo mais suave para cards
  Color get lightBackgroundColor {
    switch (this) {
      case LogLevel.info:
        return Colors.blue.withValues(alpha: 0.1);
      case LogLevel.warning:
        return Colors.orange.withValues(alpha: 0.1);
      case LogLevel.error:
        return Colors.red.withValues(alpha: 0.1);
      case LogLevel.debug:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  /// Método helper para comparar níveis
  bool isHigherPriorityThan(LogLevel other) {
    return priority > other.priority;
  }

  /// Método helper para comparar níveis
  bool isLowerPriorityThan(LogLevel other) {
    return priority < other.priority;
  }

  /// Converte string para LogLevel (case insensitive)
  static LogLevel? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final normalized = value.toLowerCase().trim();
    
    switch (normalized) {
      case 'info':
      case 'information':
        return LogLevel.info;
      case 'warning':
      case 'warn':
        return LogLevel.warning;
      case 'error':
      case 'err':
        return LogLevel.error;
      case 'debug':
      case 'dbg':
        return LogLevel.debug;
      default:
        return null;
    }
  }
}

/// Classe helper para trabalhar com múltiplos LogLevels
class LogLevelUtils {
  /// Obtém todos os níveis ordenados por prioridade (menor para maior)
  static List<LogLevel> get allLevelsByPriority {
    final levels = LogLevel.values.toList();
    levels.sort((a, b) => a.priority.compareTo(b.priority));
    return levels;
  }

  /// Obtém todos os níveis ordenados por prioridade (maior para menor)
  static List<LogLevel> get allLevelsByPriorityDesc {
    final levels = LogLevel.values.toList();
    levels.sort((a, b) => b.priority.compareTo(a.priority));
    return levels;
  }

  /// Obtém apenas níveis de produção
  static List<LogLevel> get productionLevels {
    return LogLevel.values.where((level) => level.isProductionLevel).toList();
  }

  /// Obtém apenas níveis de desenvolvimento
  static List<LogLevel> get developmentLevels {
    return LogLevel.values.where((level) => level.isDevelopmentLevel).toList();
  }

  /// Obtém níveis acima de uma determinada prioridade
  static List<LogLevel> getLevelsAbove(LogLevel level) {
    return LogLevel.values
        .where((l) => l.isHigherPriorityThan(level))
        .toList();
  }

  /// Obtém níveis abaixo de uma determinada prioridade
  static List<LogLevel> getLevelsBelow(LogLevel level) {
    return LogLevel.values
        .where((l) => l.isLowerPriorityThan(level))
        .toList();
  }

  /// Obtém níveis incluindo e acima de uma determinada prioridade
  static List<LogLevel> getLevelsIncludingAndAbove(LogLevel level) {
    return LogLevel.values
        .where((l) => l.priority >= level.priority)
        .toList();
  }

  /// Obtém níveis incluindo e abaixo de uma determinada prioridade
  static List<LogLevel> getLevelsIncludingAndBelow(LogLevel level) {
    return LogLevel.values
        .where((l) => l.priority <= level.priority)
        .toList();
  }

  /// Filtra uma lista de LogLevel baseado em critérios
  static List<LogLevel> filterLevels({
    bool? productionOnly,
    bool? developmentOnly,
    int? minPriority,
    int? maxPriority,
  }) {
    Iterable<LogLevel> levels = LogLevel.values;

    if (productionOnly == true) {
      levels = levels.where((level) => level.isProductionLevel);
    } else if (developmentOnly == true) {
      levels = levels.where((level) => level.isDevelopmentLevel);
    }

    if (minPriority != null) {
      levels = levels.where((level) => level.priority >= minPriority);
    }

    if (maxPriority != null) {
      levels = levels.where((level) => level.priority <= maxPriority);
    }

    return levels.toList();
  }

  /// Obtém estatísticas de níveis de log
  static Map<String, dynamic> getStats(List<LogLevel> levels) {
    final stats = <String, dynamic>{
      'total': levels.length,
      'distribution': <String, int>{},
      'criticalCount': 0,
      'productionCount': 0,
      'developmentCount': 0,
    };

    for (final level in levels) {
      final levelName = level.name;
      stats['distribution'][levelName] = 
          (stats['distribution'][levelName] as int? ?? 0) + 1;

      if (level.isCritical) {
        stats['criticalCount'] = (stats['criticalCount'] as int) + 1;
      }

      if (level.isProductionLevel) {
        stats['productionCount'] = (stats['productionCount'] as int) + 1;
      }

      if (level.isDevelopmentLevel) {
        stats['developmentCount'] = (stats['developmentCount'] as int) + 1;
      }
    }

    return stats;
  }
}