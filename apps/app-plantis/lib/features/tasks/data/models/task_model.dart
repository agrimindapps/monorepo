import 'package:core/core.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.title,
    super.description,
    required super.plantId,
    required super.plantName,
    required super.type,
    super.status = TaskStatus.pending,
    super.priority = TaskPriority.medium,
    required super.dueDate,
    super.completedAt,
    super.completionNotes,
    super.isRecurring = false,
    super.recurringIntervalDays,
    super.nextDueDate,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      title: task.title,
      description: task.description,
      plantId: task.plantId,
      plantName: task.plantName,
      type: task.type,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      completionNotes: task.completionNotes,
      isRecurring: task.isRecurring,
      recurringIntervalDays: task.recurringIntervalDays,
      nextDueDate: task.nextDueDate,
      lastSyncAt: task.lastSyncAt,
      isDirty: task.isDirty,
      isDeleted: task.isDeleted,
      version: task.version,
      userId: task.userId,
      moduleName: task.moduleName,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      title: json['title'] as String,
      description: json['description'] as String?,
      plantId: json['plant_id'] as String,
      plantName: json['plant_name'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.key == json['type'],
        orElse: () => TaskType.custom,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.key == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.key == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.parse(json['due_date'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completionNotes: json['completion_notes'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringIntervalDays: json['recurring_interval_days'] as int?,
      nextDueDate: json['next_due_date'] != null
          ? DateTime.parse(json['next_due_date'] as String)
          : null,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      isDirty: json['is_dirty'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      userId: json['user_id'] as String?,
      moduleName: json['module_name'] as String?,
    );
  }

  factory TaskModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    
    return TaskModel(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      plantId: map['plant_id'] as String,
      plantName: map['plant_name'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.key == map['type'],
        orElse: () => TaskType.custom,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.key == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.key == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.parse(map['due_date'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      completionNotes: map['completion_notes'] as String?,
      isRecurring: map['is_recurring'] as bool? ?? false,
      recurringIntervalDays: map['recurring_interval_days'] as int?,
      nextDueDate: map['next_due_date'] != null
          ? DateTime.parse(map['next_due_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'title': title,
      'description': description,
      'plant_id': plantId,
      'plant_name': plantName,
      'type': type.key,
      'status': status.key,
      'priority': priority.key,
      'due_date': dueDate.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'completion_notes': completionNotes,
      'is_recurring': isRecurring,
      'recurring_interval_days': recurringIntervalDays,
      'next_due_date': nextDueDate?.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'is_dirty': isDirty,
      'is_deleted': isDeleted,
      'version': version,
      'user_id': userId,
      'module_name': moduleName,
    };
  }

  @override
  TaskModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return TaskModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      title: title,
      description: description,
      plantId: plantId,
      plantName: plantName,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
      completedAt: completedAt,
      completionNotes: completionNotes,
      isRecurring: isRecurring,
      recurringIntervalDays: recurringIntervalDays,
      nextDueDate: nextDueDate,
    );
  }

  @override
  TaskModel copyWithTaskData({
    String? title,
    String? description,
    String? plantId,
    String? plantName,
    TaskType? type,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    String? completionNotes,
    bool? isRecurring,
    int? recurringIntervalDays,
    DateTime? nextDueDate,
  }) {
    return TaskModel(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastSyncAt: lastSyncAt,
      isDirty: true,
      isDeleted: isDeleted,
      version: version,
      userId: userId,
      moduleName: moduleName,
      title: title ?? this.title,
      description: description ?? this.description,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalDays: recurringIntervalDays ?? this.recurringIntervalDays,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  @override
  TaskModel markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  TaskModel markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  TaskModel markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  TaskModel incrementVersion() {
    return copyWith(
      version: version + 1,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  TaskModel withUserId(String userId) {
    return copyWith(
      userId: userId,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  TaskModel withModule(String moduleName) {
    return copyWith(
      moduleName: moduleName,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }
}