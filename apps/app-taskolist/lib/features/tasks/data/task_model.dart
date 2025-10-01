import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
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
    super.notes,
  });

  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get title => super.title;

  @HiveField(2)
  @override
  String? get description => super.description;

  @HiveField(3)
  @override
  String get listId => super.listId;

  @HiveField(4)
  @override
  String get createdById => super.createdById;

  @HiveField(5)
  @override
  String? get assignedToId => super.assignedToId;

  @HiveField(6)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(7)
  @override
  DateTime get updatedAt => super.updatedAt;

  @HiveField(8)
  @override
  DateTime? get dueDate => super.dueDate;

  @HiveField(9)
  @override
  DateTime? get reminderDate => super.reminderDate;

  @HiveField(10)
  @override
  TaskStatus get status => super.status;

  @HiveField(11)
  @override
  TaskPriority get priority => super.priority;

  @HiveField(12)
  @override
  bool get isStarred => super.isStarred;

  @HiveField(13)
  @override
  int get position => super.position;

  @HiveField(14)
  @override
  List<String> get tags => super.tags;

  @HiveField(15)
  @override
  String? get parentTaskId => super.parentTaskId;

  @HiveField(16)
  @override
  String? get notes => super.notes;

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
      notes: entity.notes,
    );
  }

  @override
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
    String? notes,
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
      notes: notes ?? this.notes,
    );
  }
}