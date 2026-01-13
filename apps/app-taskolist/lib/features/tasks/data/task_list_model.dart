import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_list_entity.dart';

class TaskListModel extends TaskListEntity {
  const TaskListModel({
    required super.id,
    required super.title,
    super.description,
    required super.color,
    required super.ownerId,
    super.memberIds,
    required super.createdAt,
    required super.updatedAt,
    super.isShared,
    super.isArchived,
    super.position,
    super.backgroundImage,
  });

  /// Converte de Firestore Document para Model
  factory TaskListModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskListModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      color: data['color'] as String? ?? '#2196F3', // Default blue
      ownerId: data['ownerId'] as String,
      memberIds: (data['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isShared: data['isShared'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
      position: data['position'] as int? ?? 0,
      backgroundImage: data['backgroundImage'] as String?,
    );
  }

  /// Converte de Map para Model
  factory TaskListModel.fromMap(Map<String, dynamic> map) {
    return TaskListModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      color: map['color'] as String? ?? '#2196F3',
      ownerId: map['ownerId'] as String,
      memberIds:
          (map['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
      isShared: map['isShared'] as bool? ?? false,
      isArchived: map['isArchived'] as bool? ?? false,
      position: map['position'] as int? ?? 0,
      backgroundImage: map['backgroundImage'] as String?,
    );
  }

  /// Converte de Entity para Model
  factory TaskListModel.fromEntity(TaskListEntity entity) {
    return TaskListModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      color: entity.color,
      ownerId: entity.ownerId,
      memberIds: entity.memberIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isShared: entity.isShared,
      isArchived: entity.isArchived,
      position: entity.position,
      backgroundImage: entity.backgroundImage,
    );
  }

  /// Converte para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'color': color,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isShared': isShared,
      'isArchived': isArchived,
      'position': position,
      'backgroundImage': backgroundImage,
    };
  }

  /// Copia com novos valores
  @override
  TaskListModel copyWith({
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
  }) {
    return TaskListModel(
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
    );
  }
}
