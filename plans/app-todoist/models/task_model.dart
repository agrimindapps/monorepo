// models/task.dart

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';
import '74_75_task_attachment.dart';
import '76_task_comment.dart';

part 'task_model.g.dart';

@HiveType(typeId: 70)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent
}

@HiveType(typeId: 71)
class Task extends BaseModel {
  @HiveField(10)
  final String title;

  @HiveField(11)
  final String? description;

  @HiveField(12)
  final String listId;

  @HiveField(13)
  final String createdById;

  @HiveField(14)
  final String? assignedToId;

  @HiveField(15)
  final DateTime? dueDate;

  @HiveField(16)
  final DateTime? reminderDate;

  @HiveField(17)
  final bool isCompleted;

  @HiveField(18)
  final bool isStarred;

  @HiveField(19)
  final TaskPriority priority;

  @HiveField(20)
  final int position; // For ordering within list

  @HiveField(21)
  final List<String> tags;

  @HiveField(22)
  final List<TaskAttachment> attachments;

  @HiveField(23)
  final List<TaskComment> comments;

  @HiveField(24)
  final String? parentTaskId; // For subtasks

  Task({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.title,
    this.description,
    required this.listId,
    required this.createdById,
    this.assignedToId,
    this.dueDate,
    this.reminderDate,
    this.isCompleted = false,
    this.isStarred = false,
    this.priority = TaskPriority.medium,
    this.position = 0,
    this.tags = const [],
    this.attachments = const [],
    this.comments = const [],
    this.parentTaskId,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      title: map['title'],
      description: map['description'],
      listId: map['listId'],
      createdById: map['createdById'],
      assignedToId: map['assignedToId'],
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      reminderDate: map['reminderDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderDate'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      isStarred: map['isStarred'] ?? false,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      position: map['position'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      attachments: (map['attachments'] as List<dynamic>?)
              ?.map((a) => TaskAttachment.fromJson(a))
              .toList() ??
          [],
      comments: (map['comments'] as List<dynamic>?)
              ?.map((c) => TaskComment.fromJson(c))
              .toList() ??
          [],
      parentTaskId: map['parentTaskId'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'title': title,
      'description': description,
      'listId': listId,
      'createdById': createdById,
      'assignedToId': assignedToId,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'reminderDate': reminderDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'isStarred': isStarred,
      'priority': priority.name,
      'position': position,
      'tags': tags,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'parentTaskId': parentTaskId,
    });
    return map;
  }

  @override
  Task copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? title,
    String? description,
    String? listId,
    String? createdById,
    String? assignedToId,
    DateTime? dueDate,
    DateTime? reminderDate,
    bool? isCompleted,
    bool? isStarred,
    TaskPriority? priority,
    int? position,
    List<String>? tags,
    List<TaskAttachment>? attachments,
    List<TaskComment>? comments,
    String? parentTaskId,
  }) {
    return Task(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      title: title ?? this.title,
      description: description ?? this.description,
      listId: listId ?? this.listId,
      createdById: createdById ?? this.createdById,
      assignedToId: assignedToId ?? this.assignedToId,
      dueDate: dueDate ?? this.dueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarred: isStarred ?? this.isStarred,
      priority: priority ?? this.priority,
      position: position ?? this.position,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      parentTaskId: parentTaskId ?? this.parentTaskId,
    );
  }

  // Getter para verificar se é uma subtask
  bool get isSubtask => parentTaskId != null;

  // Getter para verificar se está atrasada
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;

  // Factory methods para compatibilidade
  factory Task.fromJson(Map<String, dynamic> json) => Task.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
