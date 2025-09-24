import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/i_enhanced_notification_repository.dart';

/// Template engine for processing notification templates with data binding
class NotificationTemplateEngine {
  // Regular expression for finding template variables {{variableName}}
  static final RegExp _variableRegex = RegExp(r'\{\{(\w+)\}\}');

  /// Processes a template with provided data
  ///
  /// [template] - The template to process
  /// [data] - Data to bind to template variables
  /// Returns a NotificationRequest with processed content
  static NotificationRequest processTemplate(
    NotificationTemplate template,
    Map<String, dynamic> data,
  ) {
    final mergedData = {...template.defaultData, ...data};

    // Validate required fields
    for (final field in template.requiredFields) {
      if (!mergedData.containsKey(field)) {
        throw ArgumentError('Required template field missing: $field');
      }
    }

    // Process title and body
    final processedTitle = _processTemplateString(template.title, mergedData);
    final processedBody = _processTemplateString(template.body, mergedData);

    // Calculate scheduled date if recurrence is defined
    DateTime? scheduledDate;
    if (template.recurrence != null) {
      scheduledDate = _calculateRecurringDate(
        template.recurrence!,
        mergedData,
      );
    } else if (mergedData.containsKey('scheduledDate')) {
      final dateValue = mergedData['scheduledDate'];
      if (dateValue is DateTime) {
        scheduledDate = dateValue;
      } else if (dateValue is String) {
        scheduledDate = DateTime.tryParse(dateValue);
      }
    }

    return NotificationRequest(
      id: mergedData['id']?.toString(),
      title: processedTitle,
      body: processedBody,
      imageUrl: mergedData['imageUrl'] as String?,
      data: mergedData,
      actions: template.actions,
      priority: template.priority,
      channelId: template.channelId,
      scheduledDate: scheduledDate,
      recurrence: template.recurrence,
      templateId: template.id,
      pluginId: template.pluginId,
      metadata: {
        ...template.metadata,
        'processedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Processes a template string by replacing variables
  ///
  /// [template] - String with {{variable}} placeholders
  /// [data] - Data map with variable values
  /// Returns string with variables replaced
  static String _processTemplateString(String template, Map<String, dynamic> data) {
    return template.replaceAllMapped(_variableRegex, (match) {
      final variableName = match.group(1)!;
      final value = data[variableName];

      if (value == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Template variable not found: $variableName');
        }
        return '{{$variableName}}'; // Keep original if not found
      }

      return _formatValue(value);
    });
  }

  /// Formats a value for display in notification text
  ///
  /// [value] - The value to format
  /// Returns formatted string representation
  static String _formatValue(dynamic value) {
    if (value is DateTime) {
      return _formatDateTime(value);
    } else if (value is Duration) {
      return _formatDuration(value);
    } else if (value is double) {
      // Format doubles with appropriate precision
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    } else if (value is List) {
      return value.map((item) => _formatValue(item)).join(', ');
    } else if (value is Map) {
      return jsonEncode(value);
    } else {
      return value.toString();
    }
  }

  /// Formats DateTime for display
  ///
  /// [dateTime] - DateTime to format
  /// Returns formatted date string
  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      // Today - show time
      return 'hoje às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Tomorrow
      return 'amanhã às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == -1) {
      // Yesterday
      return 'ontem às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays.abs() < 7) {
      // This week
      final weekdays = ['domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'];
      final weekday = weekdays[dateTime.weekday % 7];
      return '$weekday às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Full date
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }

  /// Formats Duration for display
  ///
  /// [duration] - Duration to format
  /// Returns formatted duration string
  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} dia${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} segundo${duration.inSeconds > 1 ? 's' : ''}';
    }
  }

  /// Calculates the next scheduled date for recurring notifications
  ///
  /// [recurrence] - Recurrence rule
  /// [data] - Template data that may contain base date
  /// Returns calculated DateTime
  static DateTime _calculateRecurringDate(
    RecurrenceRule recurrence,
    Map<String, dynamic> data,
  ) {
    DateTime baseDate = DateTime.now();

    // Check if base date is provided in data
    if (data.containsKey('baseDate')) {
      final baseDateValue = data['baseDate'];
      if (baseDateValue is DateTime) {
        baseDate = baseDateValue;
      } else if (baseDateValue is String) {
        baseDate = DateTime.tryParse(baseDateValue) ?? DateTime.now();
      }
    }

    switch (recurrence.frequency) {
      case RecurrenceFrequency.daily:
        return baseDate.add(Duration(days: recurrence.interval));

      case RecurrenceFrequency.weekly:
        return baseDate.add(Duration(days: 7 * recurrence.interval));

      case RecurrenceFrequency.monthly:
        return DateTime(
          baseDate.year,
          baseDate.month + recurrence.interval,
          recurrence.dayOfMonth ?? baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );

      case RecurrenceFrequency.yearly:
        return DateTime(
          baseDate.year + recurrence.interval,
          baseDate.month,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );

      case RecurrenceFrequency.custom:
        // Custom recurrence would need additional logic
        // For now, default to daily
        return baseDate.add(Duration(days: recurrence.interval));
    }
  }

  /// Validates template syntax
  ///
  /// [template] - Template to validate
  /// Returns list of validation errors (empty if valid)
  static List<String> validateTemplate(NotificationTemplate template) {
    final errors = <String>[];

    // Check for basic requirements
    if (template.id.isEmpty) {
      errors.add('Template ID cannot be empty');
    }

    if (template.title.isEmpty) {
      errors.add('Template title cannot be empty');
    }

    if (template.body.isEmpty) {
      errors.add('Template body cannot be empty');
    }

    // Check for undefined variables in title
    final titleVariables = _extractVariables(template.title);
    for (final variable in titleVariables) {
      if (!template.defaultData.containsKey(variable) &&
          !template.requiredFields.contains(variable)) {
        errors.add('Undefined variable in title: $variable');
      }
    }

    // Check for undefined variables in body
    final bodyVariables = _extractVariables(template.body);
    for (final variable in bodyVariables) {
      if (!template.defaultData.containsKey(variable) &&
          !template.requiredFields.contains(variable)) {
        errors.add('Undefined variable in body: $variable');
      }
    }

    // Validate actions
    for (int i = 0; i < template.actions.length; i++) {
      final action = template.actions[i];
      if (action.id.isEmpty) {
        errors.add('Action ${i + 1} has empty ID');
      }
      if (action.title.isEmpty) {
        errors.add('Action ${i + 1} has empty title');
      }
    }

    // Validate recurrence rule
    if (template.recurrence != null) {
      final recurrence = template.recurrence!;
      if (recurrence.interval <= 0) {
        errors.add('Recurrence interval must be positive');
      }

      if (recurrence.frequency == RecurrenceFrequency.weekly &&
          recurrence.weekdays != null) {
        for (final weekday in recurrence.weekdays!) {
          if (weekday < 1 || weekday > 7) {
            errors.add('Invalid weekday in recurrence: $weekday');
          }
        }
      }

      if (recurrence.frequency == RecurrenceFrequency.monthly &&
          recurrence.dayOfMonth != null) {
        if (recurrence.dayOfMonth! < 1 || recurrence.dayOfMonth! > 31) {
          errors.add('Invalid day of month in recurrence: ${recurrence.dayOfMonth}');
        }
      }
    }

    return errors;
  }

  /// Extracts variable names from a template string
  ///
  /// [template] - Template string
  /// Returns list of variable names found
  static List<String> _extractVariables(String template) {
    final matches = _variableRegex.allMatches(template);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Previews how a template will look with given data
  ///
  /// [template] - Template to preview
  /// [data] - Data to use for preview
  /// Returns processed template preview
  static TemplatePreview previewTemplate(
    NotificationTemplate template,
    Map<String, dynamic> data,
  ) {
    final errors = validateTemplate(template);
    if (errors.isNotEmpty) {
      return TemplatePreview(
        title: template.title,
        body: template.body,
        errors: errors,
        isValid: false,
      );
    }

    final mergedData = {...template.defaultData, ...data};
    final processedTitle = _processTemplateString(template.title, mergedData);
    final processedBody = _processTemplateString(template.body, mergedData);

    return TemplatePreview(
      title: processedTitle,
      body: processedBody,
      errors: [],
      isValid: true,
      missingVariables: _findMissingVariables(template, mergedData),
    );
  }

  /// Finds missing variables in template data
  ///
  /// [template] - Template to check
  /// [data] - Available data
  /// Returns list of missing variable names
  static List<String> _findMissingVariables(
    NotificationTemplate template,
    Map<String, dynamic> data,
  ) {
    final titleVars = _extractVariables(template.title);
    final bodyVars = _extractVariables(template.body);
    final allVars = {...titleVars, ...bodyVars};

    return allVars
        .where((variable) => !data.containsKey(variable))
        .toList();
  }
}

/// Template preview result
class TemplatePreview {
  final String title;
  final String body;
  final List<String> errors;
  final bool isValid;
  final List<String> missingVariables;

  const TemplatePreview({
    required this.title,
    required this.body,
    required this.errors,
    required this.isValid,
    this.missingVariables = const [],
  });
}