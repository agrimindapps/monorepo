import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required int super.id,
    required int? super.animalId,
    required super.userId,
    required super.title,
    required super.description,
    required super.scheduledDate,
    required super.type,
    super.priority,
    super.status,
    super.isRecurring,
    super.recurringDays,
    super.completedAt,
    super.snoozeUntil,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: (map['id'] as int?) ?? 0,
      animalId: map['animalId'] as int?,
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      scheduledDate: DateTime.fromMillisecondsSinceEpoch((map['scheduledDate'] as int?) ?? 0),
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == 'ReminderType.${map['type']}',
        orElse: () => ReminderType.general,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.toString() == 'ReminderPriority.${map['priority']}',
        orElse: () => ReminderPriority.medium,
      ),
      status: ReminderStatus.values.firstWhere(
        (e) => e.toString() == 'ReminderStatus.${map['status']}',
        orElse: () => ReminderStatus.active,
      ),
      isRecurring: (map['isRecurring'] as bool?) ?? false,
      recurringDays: (map['recurringDays'] as int?),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['completedAt'] as int))
          : null,
      snoozeUntil: map['snoozeUntil'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['snoozeUntil'] as int))
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'userId': userId,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'snoozeUntil': snoozeUntil?.millisecondsSinceEpoch,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: int.tryParse(reminder.id) ?? 0,
      animalId: int.tryParse(reminder.animalId) ?? 0,
      userId: reminder.userId,
      title: reminder.title,
      description: reminder.description,
      scheduledDate: reminder.scheduledDate,
      type: reminder.type,
      priority: reminder.priority,
      status: reminder.status,
      isRecurring: reminder.isRecurring,
      recurringDays: reminder.recurringDays,
      completedAt: reminder.completedAt,
      snoozeUntil: reminder.snoozeUntil,
      metadata: reminder.metadata,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }

  @override
  ReminderModel copyWith({
    int? id,
    int? animalId,
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
    return ReminderModel(
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
}
