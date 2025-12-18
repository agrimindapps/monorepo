import 'package:core/core.dart';

import '../domain/recurrence_entity.dart';
import '../domain/task_entity.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
    required super.title,
    super.description,
    required super.listId,
    required super.createdById,
    super.assignedToId,
    super.dueDate,
    super.reminderDate,
    super.status,
    super.priority,
    super.isStarred,
    super.position,
    super.tags,
    super.parentTaskId,
    super.notes,
    super.recurrence = const RecurrencePattern(),
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastSyncAt: entity.lastSyncAt,
      isDirty: entity.isDirty,
      isDeleted: entity.isDeleted,
      version: entity.version,
      userId: entity.userId,
      moduleName: entity.moduleName,
      title: entity.title,
      description: entity.description,
      listId: entity.listId,
      createdById: entity.createdById,
      assignedToId: entity.assignedToId,
      dueDate: entity.dueDate,
      reminderDate: entity.reminderDate,
      status: entity.status,
      priority: entity.priority,
      isStarred: entity.isStarred,
      position: entity.position,
      tags: entity.tags,
      parentTaskId: entity.parentTaskId,
      notes: entity.notes,
      recurrence: entity.recurrence,
    );
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
    RecurrencePattern? recurrence,
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
      recurrence: recurrence ?? this.recurrence,
    );
  }
}
