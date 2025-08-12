// models/task_list.dart

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';

part '72_task_list.g.dart';

@HiveType(typeId: 72)
class TaskList extends BaseModel {
  @HiveField(10)
  final String title;

  @HiveField(11)
  final String? description;

  @HiveField(12)
  final String color; // Hex color for personalization

  @HiveField(13)
  final String ownerId;

  @HiveField(14)
  final List<String> memberIds;

  @HiveField(15)
  final bool isShared;

  @HiveField(16)
  final bool isArchived;

  @HiveField(17)
  final int position; // For ordering lists

  TaskList({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.title,
    this.description,
    required this.color,
    required this.ownerId,
    this.memberIds = const [],
    this.isShared = false,
    this.isArchived = false,
    this.position = 0,
  });

  factory TaskList.fromMap(Map<String, dynamic> map) {
    return TaskList(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      title: map['title'],
      description: map['description'],
      color: map['color'],
      ownerId: map['ownerId'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      isShared: map['isShared'] ?? false,
      isArchived: map['isArchived'] ?? false,
      position: map['position'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'title': title,
      'description': description,
      'color': color,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'isShared': isShared,
      'isArchived': isArchived,
      'position': position,
    });
    return map;
  }

  @override
  TaskList copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? title,
    String? description,
    String? color,
    String? ownerId,
    List<String>? memberIds,
    bool? isShared,
    bool? isArchived,
    int? position,
  }) {
    return TaskList(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      isShared: isShared ?? this.isShared,
      isArchived: isArchived ?? this.isArchived,
      position: position ?? this.position,
    );
  }

  // Factory methods para compatibilidade
  factory TaskList.fromJson(Map<String, dynamic> json) =>
      TaskList.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
