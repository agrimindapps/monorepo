// models/task_comment.dart

// Package imports:
import 'package:hive/hive.dart';

part '76_task_comment.g.dart';

@HiveType(typeId: 76)
class TaskComment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  @HiveField(6)
  bool isSynced; // Para controlar sincronização

  @HiveField(7)
  DateTime lastModified; // Para conflict resolution

  TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = true,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'],
      taskId: json['taskId'],
      userId: json['userId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
