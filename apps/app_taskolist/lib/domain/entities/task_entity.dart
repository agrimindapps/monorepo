import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String listId;
  final String createdById;
  final String? assignedToId;
  final DateTime createdAt;
  final DateTime updatedAt;
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
    required this.id,
    required this.title,
    this.description,
    required this.listId,
    required this.createdById,
    this.assignedToId,
    required this.createdAt,
    required this.updatedAt,
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

  TaskEntity copyWith({
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
    return TaskEntity(
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

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        listId,
        createdById,
        assignedToId,
        createdAt,
        updatedAt,
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