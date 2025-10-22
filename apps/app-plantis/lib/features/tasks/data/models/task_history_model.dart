import '../../domain/entities/task.dart' as task_entity;
import '../../domain/entities/task_history.dart';

class TaskHistoryModel extends TaskHistory {
  const TaskHistoryModel({
    required super.id,
    required super.taskId,
    required super.originalTaskTitle,
    required super.plantId,
    required super.taskType,
    required super.priority,
    required super.originalDueDate,
    required super.completedAt,
    required super.userId,
    super.notes,
    super.photosUrls = const [],
    super.timeSpent,
    super.status = TaskHistoryStatus.completed,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskHistoryModel.fromEntity(TaskHistory history) {
    return TaskHistoryModel(
      id: history.id,
      taskId: history.taskId,
      originalTaskTitle: history.originalTaskTitle,
      plantId: history.plantId,
      taskType: history.taskType,
      priority: history.priority,
      originalDueDate: history.originalDueDate,
      completedAt: history.completedAt,
      userId: history.userId,
      notes: history.notes,
      photosUrls: history.photosUrls,
      timeSpent: history.timeSpent,
      status: history.status,
      createdAt: history.createdAt,
      updatedAt: history.updatedAt,
    );
  }

  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    return TaskHistoryModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      originalTaskTitle: json['originalTaskTitle'] as String,
      plantId: json['plantId'] as String,
      taskType: task_entity.TaskType.values.firstWhere(
        (e) => e.key == json['taskType'],
        orElse: () => task_entity.TaskType.custom,
      ),
      priority: task_entity.TaskPriority.values.firstWhere(
        (e) => e.key == json['priority'],
        orElse: () => task_entity.TaskPriority.medium,
      ),
      originalDueDate: DateTime.parse(json['originalDueDate'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      userId: json['userId'] as String,
      notes: json['notes'] as String?,
      photosUrls: List<String>.from(json['photosUrls'] as List? ?? []),
      timeSpent:
          json['timeSpent'] != null
              ? Duration(minutes: json['timeSpent'] as int)
              : null,
      status: TaskHistoryStatus.values.firstWhere(
        (e) => e.key == json['status'],
        orElse: () => TaskHistoryStatus.completed,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory TaskHistoryModel.fromFirebaseMap(Map<String, dynamic> map) {
    return TaskHistoryModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      originalTaskTitle: map['originalTaskTitle'] as String,
      plantId: map['plantId'] as String,
      taskType: task_entity.TaskType.values.firstWhere(
        (e) => e.key == map['taskType'],
        orElse: () => task_entity.TaskType.custom,
      ),
      priority: task_entity.TaskPriority.values.firstWhere(
        (e) => e.key == map['priority'],
        orElse: () => task_entity.TaskPriority.medium,
      ),
      originalDueDate: DateTime.fromMillisecondsSinceEpoch(
        map['originalDueDate'] as int,
      ),
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        map['completedAt'] as int,
      ),
      userId: map['userId'] as String,
      notes: map['notes'] as String?,
      photosUrls: List<String>.from(map['photosUrls'] as List? ?? []),
      timeSpent:
          map['timeSpent'] != null
              ? Duration(minutes: map['timeSpent'] as int)
              : null,
      status: TaskHistoryStatus.values.firstWhere(
        (e) => e.key == map['status'],
        orElse: () => TaskHistoryStatus.completed,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  factory TaskHistoryModel.fromHiveMap(Map<String, dynamic> map) {
    return TaskHistoryModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      originalTaskTitle: map['originalTaskTitle'] as String,
      plantId: map['plantId'] as String,
      taskType: task_entity.TaskType.values.firstWhere(
        (e) => e.key == map['taskType'],
        orElse: () => task_entity.TaskType.custom,
      ),
      priority: task_entity.TaskPriority.values.firstWhere(
        (e) => e.key == map['priority'],
        orElse: () => task_entity.TaskPriority.medium,
      ),
      originalDueDate: DateTime.fromMillisecondsSinceEpoch(
        map['originalDueDate'] as int,
      ),
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        map['completedAt'] as int,
      ),
      userId: map['userId'] as String,
      notes: map['notes'] as String?,
      photosUrls: List<String>.from(map['photosUrls'] as List? ?? []),
      timeSpent:
          map['timeSpent'] != null
              ? Duration(minutes: map['timeSpent'] as int)
              : null,
      status: TaskHistoryStatus.values.firstWhere(
        (e) => e.key == map['status'],
        orElse: () => TaskHistoryStatus.completed,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'originalTaskTitle': originalTaskTitle,
      'plantId': plantId,
      'taskType': taskType.key,
      'priority': priority.key,
      'originalDueDate': originalDueDate.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'userId': userId,
      'notes': notes,
      'photosUrls': photosUrls,
      'timeSpent': timeSpent?.inMinutes,
      'status': status.key,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'taskId': taskId,
      'originalTaskTitle': originalTaskTitle,
      'plantId': plantId,
      'taskType': taskType.key,
      'priority': priority.key,
      'originalDueDate': originalDueDate.millisecondsSinceEpoch,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'userId': userId,
      'notes': notes,
      'photosUrls': photosUrls,
      'timeSpent': timeSpent?.inMinutes,
      'status': status.key,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'taskId': taskId,
      'originalTaskTitle': originalTaskTitle,
      'plantId': plantId,
      'taskType': taskType.key,
      'priority': priority.key,
      'originalDueDate': originalDueDate.millisecondsSinceEpoch,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'userId': userId,
      'notes': notes,
      'photosUrls': photosUrls,
      'timeSpent': timeSpent?.inMinutes,
      'status': status.key,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
