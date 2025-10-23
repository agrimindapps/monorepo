import 'package:core/core.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

/// Task entity with full sync capabilities
/// Extends BaseSyncEntity for robust offline-first synchronization:
/// - version: Version-based conflict resolution
/// - isDirty: Optimized dirty tracking for sync
/// - lastSyncAt: Last sync timestamp tracking
/// - isDeleted: Soft delete support
/// - userId/moduleName: Multi-tenant support
class TaskEntity extends BaseSyncEntity {
  // Business fields
  final String title;
  final String? description;
  final String listId;
  final String createdById;
  final String? assignedToId;
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final TaskStatus status;
  final TaskPriority priority;
  final bool isStarred;
  final int position;
  final List<String> tags;
  final String? parentTaskId;
  final String? notes;

  const TaskEntity({
    // BaseSyncEntity fields
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
    // Task-specific fields
    required this.title,
    this.description,
    required this.listId,
    required this.createdById,
    this.assignedToId,
    this.dueDate,
    this.reminderDate,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.isStarred = false,
    this.position = 0,
    this.tags = const [],
    this.parentTaskId,
    this.notes,
  });

  // Override to provide non-nullable types for task domain
  @override
  DateTime get createdAt => super.createdAt!;

  @override
  DateTime get updatedAt => super.updatedAt!;

  bool get isCompleted => status == TaskStatus.completed;
  
  bool get isOverdue => dueDate != null && 
      DateTime.now().isAfter(dueDate!) && 
      !isCompleted;
  
  bool get isSubtask => parentTaskId != null;
  
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today == taskDate;
  }
  
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate!.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           dueDate!.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  @override
  TaskEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? title,
    String? description,
    String? listId,
    String? createdById,
    String? assignedToId,
    DateTime? dueDate,
    DateTime? reminderDate,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
    int? position,
    List<String>? tags,
    String? parentTaskId,
    String? notes,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      title: title ?? this.title,
      description: description ?? this.description,
      listId: listId ?? this.listId,
      createdById: createdById ?? this.createdById,
      assignedToId: assignedToId ?? this.assignedToId,
      dueDate: dueDate ?? this.dueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      isStarred: isStarred ?? this.isStarred,
      position: position ?? this.position,
      tags: tags ?? this.tags,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      notes: notes ?? this.notes,
    );
  }

  // BaseSyncEntity implementations
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'title': title,
      'description': description,
      'list_id': listId,
      'created_by_id': createdById,
      'assigned_to_id': assignedToId,
      'due_date': dueDate?.toIso8601String(),
      'reminder_date': reminderDate?.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'is_starred': isStarred,
      'position': position,
      'tags': tags,
      'parent_task_id': parentTaskId,
      'notes': notes,
    };
  }

  @override
  TaskEntity markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  TaskEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  TaskEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  TaskEntity incrementVersion() {
    return copyWith(version: version + 1);
  }

  @override
  TaskEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  TaskEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Factory constructor to create TaskEntity from Firebase map
  static TaskEntity fromFirebaseMap(Map<String, dynamic> map) {
    return TaskEntity(
      // BaseSyncEntity fields
      id: map['id'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      version: map['version'] as int? ?? 1,
      isDirty: map['is_dirty'] as bool? ?? false,
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
      isDeleted: map['is_deleted'] as bool? ?? false,
      userId: map['user_id'] as String?,
      moduleName: map['module_name'] as String?,
      // Business fields
      title: map['title'] as String,
      description: map['description'] as String?,
      listId: map['list_id'] as String,
      createdById: map['created_by_id'] as String,
      assignedToId: map['assigned_to_id'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      reminderDate: map['reminder_date'] != null
          ? DateTime.parse(map['reminder_date'] as String)
          : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isStarred: map['is_starred'] as bool? ?? false,
      position: map['position'] as int? ?? 0,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      parentTaskId: map['parent_task_id'] as String?,
      notes: map['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        title,
        description,
        listId,
        createdById,
        assignedToId,
        dueDate,
        reminderDate,
        status,
        priority,
        isStarred,
        position,
        tags,
        parentTaskId,
        notes,
      ];
}
