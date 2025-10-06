import 'package:core/core.dart' show Equatable;

enum ReminderType { vaccine, medication, appointment, weight, general }

enum ReminderPriority { low, medium, high, urgent }

enum ReminderStatus { active, completed, cancelled, snoozed }

class Reminder extends Equatable {
  final String id;
  final String animalId;
  final String userId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final ReminderType type;
  final ReminderPriority priority;
  final ReminderStatus status;
  final bool isRecurring;
  final int? recurringDays;
  final DateTime? completedAt;
  final DateTime? snoozeUntil;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.animalId,
    required this.userId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.type,
    this.priority = ReminderPriority.medium,
    this.status = ReminderStatus.active,
    this.isRecurring = false,
    this.recurringDays,
    this.completedAt,
    this.snoozeUntil,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Reminder copyWith({
    String? id,
    String? animalId,
    String? userId,
    String? title,
    String? description,
    DateTime? scheduledDate,
    ReminderType? type,
    ReminderPriority? priority,
    ReminderStatus? status,
    bool? isRecurring,
    int? recurringDays,
    DateTime? completedAt,
    DateTime? snoozeUntil,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      completedAt: completedAt ?? this.completedAt,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue =>
      status == ReminderStatus.active && DateTime.now().isAfter(scheduledDate);

  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return today.isAtSameMomentAs(scheduled);
  }

  bool get isDueSoon {
    final now = DateTime.now();
    final difference = scheduledDate.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  @override
  List<Object?> get props => [
    id,
    animalId,
    userId,
    title,
    description,
    scheduledDate,
    type,
    priority,
    status,
    isRecurring,
    recurringDays,
    completedAt,
    snoozeUntil,
    metadata,
    createdAt,
    updatedAt,
  ];
}
