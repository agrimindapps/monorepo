import 'package:core/core.dart' show Equatable;
import 'task.dart' as task_entity;

class TaskHistory extends Equatable {
  final String id;
  final String taskId;
  final String originalTaskTitle;
  final String plantId;
  final task_entity.TaskType taskType;
  final task_entity.TaskPriority priority;
  final DateTime originalDueDate;
  final DateTime completedAt;
  final String userId;
  final String? notes;
  final List<String> photosUrls;
  final Duration? timeSpent;
  final TaskHistoryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskHistory({
    required this.id,
    required this.taskId,
    required this.originalTaskTitle,
    required this.plantId,
    required this.taskType,
    required this.priority,
    required this.originalDueDate,
    required this.completedAt,
    required this.userId,
    this.notes,
    this.photosUrls = const [],
    this.timeSpent,
    this.status = TaskHistoryStatus.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    taskId,
    originalTaskTitle,
    plantId,
    taskType,
    priority,
    originalDueDate,
    completedAt,
    userId,
    notes,
    photosUrls,
    timeSpent,
    status,
    createdAt,
    updatedAt,
  ];

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

  Map<String, dynamic> toMap() {
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

  factory TaskHistory.fromFirebaseMap(Map<String, dynamic> map) {
    return TaskHistory(
      id: (map['id'] as String?) ?? '',
      taskId: (map['taskId'] as String?) ?? '',
      originalTaskTitle: (map['originalTaskTitle'] as String?) ?? '',
      plantId: (map['plantId'] as String?) ?? '',
      taskType: task_entity.TaskType.values.firstWhere(
        (type) => type.key == map['taskType'],
        orElse: () => task_entity.TaskType.custom,
      ),
      priority: task_entity.TaskPriority.values.firstWhere(
        (priority) => priority.key == map['priority'],
        orElse: () => task_entity.TaskPriority.medium,
      ),
      originalDueDate: DateTime.fromMillisecondsSinceEpoch(
        (map['originalDueDate'] as int?) ?? 0,
      ),
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['completedAt'] as int?) ?? 0,
      ),
      userId: (map['userId'] as String?) ?? '',
      notes: map['notes'] as String?,
      photosUrls: List<String>.from(
        (map['photosUrls'] as List<dynamic>?) ?? [],
      ),
      timeSpent: map['timeSpent'] != null
          ? Duration(minutes: (map['timeSpent'] as int))
          : null,
      status: TaskHistoryStatus.values.firstWhere(
        (status) => status.key == map['status'],
        orElse: () => TaskHistoryStatus.completed,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as int?) ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as int?) ?? 0,
      ),
    );
  }

  factory TaskHistory.fromMap(Map<String, dynamic> map) {
    return TaskHistory(
      id: (map['id'] as String?) ?? '',
      taskId: (map['taskId'] as String?) ?? '',
      originalTaskTitle: (map['originalTaskTitle'] as String?) ?? '',
      plantId: (map['plantId'] as String?) ?? '',
      taskType: task_entity.TaskType.values.firstWhere(
        (type) => type.key == map['taskType'],
        orElse: () => task_entity.TaskType.custom,
      ),
      priority: task_entity.TaskPriority.values.firstWhere(
        (priority) => priority.key == map['priority'],
        orElse: () => task_entity.TaskPriority.medium,
      ),
      originalDueDate: DateTime.fromMillisecondsSinceEpoch(
        (map['originalDueDate'] as int?) ?? 0,
      ),
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['completedAt'] as int?) ?? 0,
      ),
      userId: (map['userId'] as String?) ?? '',
      notes: map['notes'] as String?,
      photosUrls: List<String>.from(
        (map['photosUrls'] as List<dynamic>?) ?? [],
      ),
      timeSpent: map['timeSpent'] != null
          ? Duration(minutes: (map['timeSpent'] as int))
          : null,
      status: TaskHistoryStatus.values.firstWhere(
        (status) => status.key == map['status'],
        orElse: () => TaskHistoryStatus.completed,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as int?) ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as int?) ?? 0,
      ),
    );
  }
  factory TaskHistory.fromCompletedTask(
    task_entity.Task task, {
    String? notes,
    List<String> photosUrls = const [],
    Duration? timeSpent,
  }) {
    final now = DateTime.now();
    return TaskHistory(
      id: '${task.id}_history_${now.millisecondsSinceEpoch}',
      taskId: task.id,
      originalTaskTitle: task.title,
      plantId: task.plantId,
      taskType: task.type,
      priority: task.priority,
      originalDueDate: task.dueDate,
      completedAt: now,
      userId: task.userId ?? '',
      notes: notes,
      photosUrls: photosUrls,
      timeSpent: timeSpent,
      status: TaskHistoryStatus.completed,
      createdAt: now,
      updatedAt: now,
    );
  }
  bool get wasCompletedOnTime =>
      completedAt.isBefore(originalDueDate) ||
      completedAt.isAtSameMomentAs(originalDueDate);

  Duration get delayFromDueDate => completedAt.difference(originalDueDate);

  String get delayText {
    if (wasCompletedOnTime) {
      final advance = originalDueDate.difference(completedAt);
      if (advance.inDays > 0) {
        return '${advance.inDays} dia${advance.inDays > 1 ? 's' : ''} antes';
      } else if (advance.inHours > 0) {
        return '${advance.inHours} hora${advance.inHours > 1 ? 's' : ''} antes';
      } else {
        return 'No prazo';
      }
    } else {
      final delay = delayFromDueDate;
      if (delay.inDays > 0) {
        return '${delay.inDays} dia${delay.inDays > 1 ? 's' : ''} atrasado';
      } else if (delay.inHours > 0) {
        return '${delay.inHours} hora${delay.inHours > 1 ? 's' : ''} atrasado';
      } else {
        return '${delay.inMinutes} minuto${delay.inMinutes > 1 ? 's' : ''} atrasado';
      }
    }
  }

  String get timeSpentText {
    if (timeSpent == null) return 'Não informado';
    final hours = timeSpent!.inHours;
    final minutes = timeSpent!.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  TaskHistory copyWith({
    String? id,
    String? taskId,
    String? originalTaskTitle,
    String? plantId,
    task_entity.TaskType? taskType,
    task_entity.TaskPriority? priority,
    DateTime? originalDueDate,
    DateTime? completedAt,
    String? userId,
    String? notes,
    List<String>? photosUrls,
    Duration? timeSpent,
    TaskHistoryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskHistory(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      originalTaskTitle: originalTaskTitle ?? this.originalTaskTitle,
      plantId: plantId ?? this.plantId,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      originalDueDate: originalDueDate ?? this.originalDueDate,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      photosUrls: photosUrls ?? this.photosUrls,
      timeSpent: timeSpent ?? this.timeSpent,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TaskHistoryStatus {
  completed('concluida', 'Concluída'),
  cancelled('cancelada', 'Cancelada'),
  skipped('pulada', 'Pulada');

  const TaskHistoryStatus(this.key, this.displayName);
  final String key;
  final String displayName;
}
