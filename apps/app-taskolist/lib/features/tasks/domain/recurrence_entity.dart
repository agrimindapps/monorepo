/// Recurrence configuration for tasks
enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'Sem recorrência';
      case RecurrenceType.daily:
        return 'Diariamente';
      case RecurrenceType.weekly:
        return 'Semanalmente';
      case RecurrenceType.monthly:
        return 'Mensalmente';
      case RecurrenceType.yearly:
        return 'Anualmente';
      case RecurrenceType.custom:
        return 'Personalizado';
    }
  }
}

/// Recurrence pattern for tasks
class RecurrencePattern {
  final RecurrenceType type;
  final int interval; // Every X days/weeks/months/years
  final List<int>? daysOfWeek; // For weekly: [1,2,3] = Mon,Tue,Wed (1=Monday, 7=Sunday)
  final int? dayOfMonth; // For monthly: day of month (1-31)
  final DateTime? endDate; // Null = infinite

  const RecurrencePattern({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
  });

  bool get isRecurring => type != RecurrenceType.none;

  /// Check if recurrence is still active
  bool get isActive {
    if (!isRecurring) return false;
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate!);
  }

  /// Get next occurrence date from a given date
  DateTime? getNextOccurrence(DateTime from) {
    if (!isActive) return null;

    switch (type) {
      case RecurrenceType.none:
        return null;

      case RecurrenceType.daily:
        return from.add(Duration(days: interval));

      case RecurrenceType.weekly:
        // If daysOfWeek is specified, find next matching day
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          DateTime next = from.add(const Duration(days: 1));
          while (!daysOfWeek!.contains(next.weekday)) {
            next = next.add(const Duration(days: 1));
            // Prevent infinite loop
            if (next.difference(from).inDays > 7) break;
          }
          return next;
        }
        return from.add(Duration(days: 7 * interval));

      case RecurrenceType.monthly:
        if (dayOfMonth != null) {
          int month = from.month + interval;
          int year = from.year;
          while (month > 12) {
            month -= 12;
            year++;
          }
          // Handle invalid dates (e.g., Feb 30)
          int day = dayOfMonth!;
          while (day > _daysInMonth(year, month)) {
            day--;
          }
          return DateTime(year, month, day, from.hour, from.minute);
        }
        return DateTime(
          from.year,
          from.month + interval,
          from.day,
          from.hour,
          from.minute,
        );

      case RecurrenceType.yearly:
        return DateTime(
          from.year + interval,
          from.month,
          from.day,
          from.hour,
          from.minute,
        );

      case RecurrenceType.custom:
        // For custom patterns, implement based on business rules
        return null;
    }
  }

  /// Helper to get days in month
  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  RecurrencePattern copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
  }) {
    return RecurrencePattern(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'endDate': endDate?.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecurrenceType.none,
      ),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.cast<int>(),
      dayOfMonth: json['dayOfMonth'] as int?,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  @override
  String toString() {
    if (!isRecurring) return 'Sem recorrência';

    String result = '';
    if (interval > 1) {
      result = 'A cada $interval ';
    }

    result += type.label.toLowerCase();

    if (type == RecurrenceType.weekly && daysOfWeek != null) {
      final dayNames = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final days = daysOfWeek!.map((d) => dayNames[d]).join(', ');
      result += ' ($days)';
    }

    if (type == RecurrenceType.monthly && dayOfMonth != null) {
      result += ' (dia $dayOfMonth)';
    }

    if (endDate != null) {
      result += ' até ${endDate!.day}/${endDate!.month}/${endDate!.year}';
    }

    return result;
  }
}
