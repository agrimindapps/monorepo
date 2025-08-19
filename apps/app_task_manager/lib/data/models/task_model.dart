import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.listId,
    required super.createdById,
    super.assignedToId,
    required super.createdAt,
    required super.updatedAt,
    super.dueDate,
    super.reminderDate,
    super.status,
    super.priority,
    super.isStarred,
    super.position,
    super.tags,
    super.parentTaskId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      listId: entity.listId,
      createdById: entity.createdById,
      assignedToId: entity.assignedToId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      dueDate: entity.dueDate,
      reminderDate: entity.reminderDate,
      status: entity.status,
      priority: entity.priority,
      isStarred: entity.isStarred,
      position: entity.position,
      tags: entity.tags,
      parentTaskId: entity.parentTaskId,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? listId,
    String? createdById,
    String? assignedToId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? reminderDate,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
    int? position,
    List<String>? tags,
    String? parentTaskId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      listId: listId ?? this.listId,
      createdById: createdById ?? this.createdById,
      assignedToId: assignedToId ?? this.assignedToId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      isStarred: isStarred ?? this.isStarred,
      position: position ?? this.position,
      tags: tags ?? this.tags,
      parentTaskId: parentTaskId ?? this.parentTaskId,
    );
  }
}