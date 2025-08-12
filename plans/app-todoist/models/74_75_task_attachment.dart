// models/task_attachment.dart

// Package imports:
import 'package:hive/hive.dart';

part '74_75_task_attachment.g.dart';

@HiveType(typeId: 74)
enum AttachmentType {
  @HiveField(0)
  image,
  @HiveField(1)
  document,
  @HiveField(2)
  link,
  @HiveField(3)
  voice
}

@HiveType(typeId: 75)
class TaskAttachment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final AttachmentType type;

  @HiveField(5)
  final int size; // in bytes

  @HiveField(6)
  final String uploadedById;

  @HiveField(7)
  final DateTime uploadedAt;

  @HiveField(8)
  bool isSynced; // Para controlar sincronização

  @HiveField(9)
  DateTime lastModified; // Para conflict resolution

  TaskAttachment({
    required this.id,
    required this.taskId,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedById,
    required this.uploadedAt,
    this.isSynced = true,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'],
      taskId: json['taskId'],
      name: json['name'],
      url: json['url'],
      type: AttachmentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AttachmentType.document,
      ),
      size: json['size'],
      uploadedById: json['uploadedById'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'name': name,
      'url': url,
      'type': type.name,
      'size': size,
      'uploadedById': uploadedById,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
