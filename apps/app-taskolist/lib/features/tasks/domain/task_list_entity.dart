import 'package:core/core.dart';

class TaskListEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String color;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final bool isArchived;
  final int position;
  final String? backgroundImage;
  final String? groupId; // Grupo ao qual a lista pertence

  const TaskListEntity({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    required this.ownerId,
    this.memberIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.isArchived = false,
    this.position = 0,
    this.backgroundImage,
    this.groupId,
  });

  bool get isOwner => ownerId.isNotEmpty;
  
  bool isMember(String userId) => memberIds.contains(userId);
  
  bool get isGrouped => groupId != null && groupId!.isNotEmpty;

  TaskListEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? color,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    bool? isArchived,
    int? position,
    String? backgroundImage,
    String? groupId,
  }) {
    return TaskListEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      isArchived: isArchived ?? this.isArchived,
      position: position ?? this.position,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        color,
        ownerId,
        memberIds,
        createdAt,
        updatedAt,
        isShared,
        isArchived,
        position,
        backgroundImage,
        groupId,
      ];
}
