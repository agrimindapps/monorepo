import 'package:flutter/material.dart';
import '../enums/log_level.dart';

/// An extension on the [LogLevel] enum to provide utility methods and properties.
extension LogLevelExtensions on LogLevel {
  /// A color associated with the log level for UI representation.
  Color get color {
    switch (this) {
      case LogLevel.trace:
        return Colors.purple;
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red.shade900;
    }
  }

  /// An icon associated with the log level for UI representation.
  IconData get icon {
    switch (this) {
      case LogLevel.trace:
        return Icons.search;
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.critical:
        return Icons.error_outline;
    }
  }

  /// A numeric priority for the log level (higher value means higher priority).
  int get priority => index;

  /// A user-friendly, capitalized name for the log level (e.g., "Debug").
  String get displayName => name[0].toUpperCase() + name.substring(1);

  /// The uppercase name of the log level for use in log messages.
  String get logName => name.toUpperCase();

  /// Returns `true` if the level is [LogLevel.error] or [LogLevel.critical].
  bool get isCritical => priority >= LogLevel.error.priority;

  /// Returns `true` if the log level is suitable for production environments.
  bool get isProductionLevel => priority >= LogLevel.info.priority;

  /// Returns `true` if the log level is typically used for development.
  bool get isDevelopmentLevel => priority < LogLevel.info.priority;

  /// A suitable text color to be used on a background of this level's [color].
  Color get textColor {
    switch (this) {
      case LogLevel.warning:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  /// A lighter version of the log level's color, suitable for backgrounds.
  Color get lightBackgroundColor {
    switch (this) {
      case LogLevel.trace:
        return Colors.purple.withOpacity(0.1);
      case LogLevel.debug:
        return Colors.grey.withOpacity(0.1);
      case LogLevel.info:
        return Colors.blue.withOpacity(0.1);
      case LogLevel.warning:
        return Colors.orange.withOpacity(0.1);
      case LogLevel.error:
        return Colors.red.withOpacity(0.1);
      case LogLevel.critical:
        return Colors.red.shade900.withOpacity(0.1);
    }
  }

  /// Returns `true` if this log level has a higher priority than [other].
  bool isHigherPriorityThan(LogLevel other) => priority > other.priority;

  /// Returns `true` if this log level has a lower priority than [other].
  bool isLowerPriorityThan(LogLevel other) => priority < other.priority;

  /// Creates a [LogLevel] from a string, ignoring case.
  ///
  /// Supports full names (e.g., "debug") and common abbreviations (e.g., "dbg").
  static LogLevel? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    final normalized = value.toLowerCase().trim();
    for (final level in LogLevel.values) {
      if (level.name == normalized) return level;
    }

    // Check for common abbreviations
    switch (normalized) {
      case 'trc':
        return LogLevel.trace;
      case 'dbg':
        return LogLevel.debug;
      case 'information':
        return LogLevel.info;
      case 'warn':
        return LogLevel.warning;
      case 'err':
        return LogLevel.error;
      case 'crit':
        return LogLevel.critical;
      default:
        return null;
    }
  }
}

/// A utility class for performing operations related to [LogLevel].
class LogLevelUtils {
  LogLevelUtils._();

  /// A list of all log levels, sorted from lowest to highest priority.
  static final List<LogLevel> allLevelsByPriority = List.unmodifiable(
    LogLevel.values..sort((a, b) => a.priority.compareTo(b.priority)),
  );

  /// A list of all log levels, sorted from highest to lowest priority.
  static final List<LogLevel> allLevelsByPriorityDesc = List.unmodifiable(
    LogLevel.values..sort((a, b) => b.priority.compareTo(a.priority)),
  );

  /// A list of log levels suitable for production environments.
  static final List<LogLevel> productionLevels = List.unmodifiable(
    LogLevel.values.where((level) => level.isProductionLevel),
  );

  /// A list of log levels typically used during development.
  static final List<LogLevel> developmentLevels = List.unmodifiable(
    LogLevel.values.where((level) => level.isDevelopmentLevel),
  );

  /// Returns a list of log levels with a higher priority than the given [level].
  static List<LogLevel> getLevelsAbove(LogLevel level) {
    return allLevelsByPriority.where((l) => l.isHigherPriorityThan(level)).toList();
  }

  /// Returns a list of log levels with a lower priority than the given [level].
  static List<LogLevel> getLevelsBelow(LogLevel level) {
    return allLevelsByPriority.where((l) => l.isLowerPriorityThan(level)).toList();
  }

  /// Returns a list of log levels with a priority greater than or equal to the given [level].
  static List<LogLevel> getLevelsIncludingAndAbove(LogLevel level) {
    return allLevelsByPriority.where((l) => l.priority >= level.priority).toList();
  }

  /// Returns a list of log levels with a priority less than or equal to the given [level].
  static List<LogLevel> getLevelsIncludingAndBelow(LogLevel level) {
    return allLevelsByPriority.where((l) => l.priority <= level.priority).toList();
  }

  /// Filters a list of [LogLevel]s based on the provided criteria.
  static List<LogLevel> filterLevels({
    bool? productionOnly,
    bool? developmentOnly,
    int? minPriority,
    int? maxPriority,
  }) {
    return allLevelsByPriority.where((level) {
      if (productionOnly == true && !level.isProductionLevel) return false;
      if (developmentOnly == true && !level.isDevelopmentLevel) return false;
      if (minPriority != null && level.priority < minPriority) return false;
      if (maxPriority != null && level.priority > maxPriority) return false;
      return true;
    }).toList();
  }

  /// Generates statistics for a given list of [LogLevel]s.
  static Map<String, dynamic> getStats(List<LogLevel> levels) {
    final distribution = <LogLevel, int>{
      for (final level in LogLevel.values) level: 0
    };
    int criticalCount = 0;
    int productionCount = 0;
    int developmentCount = 0;

    for (final level in levels) {
      distribution[level] = (distribution[level] ?? 0) + 1;
      if (level.isCritical) criticalCount++;
      if (level.isProductionLevel) productionCount++;
      if (level.isDevelopmentLevel) developmentCount++;
    }

    return {
      'total': levels.length,
      'distribution': distribution.map((key, value) => MapEntry(key.name, value)),
      'criticalCount': criticalCount,
      'productionCount': productionCount,
      'developmentCount': developmentCount,
    };
  }
}