import 'package:core/core.dart';

import '../domain/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
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

  // Sync fields - New fields for BaseSyncEntity support
  @HiveField(17)
  @override
  DateTime? get lastSyncAt => super.lastSyncAt;

  @HiveField(18)
  @override
  bool get isDirty => super.isDirty;

  @HiveField(19)
  @override
  bool get isDeleted => super.isDeleted;

  @HiveField(20)
  @override
  int get version => super.version;

  @HiveField(21)
  @override
  String? get userId => super.userId;

  @HiveField(22)
  @override
  String? get moduleName => super.moduleName;

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
    );
  }
}
