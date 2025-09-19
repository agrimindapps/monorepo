import '../../domain/entities/plant_task.dart';

class PlantTaskModel extends PlantTask {
  const PlantTaskModel({
    required super.id,
    required super.plantId,
    required super.type,
    required super.title,
    super.description,
    required super.scheduledDate,
    super.completedDate,
    required super.status,
    required super.intervalDays,
    required super.createdAt,
    super.nextScheduledDate,
    this.isDirty = false,
    this.isDeleted = false,
    this.updatedAt,
  });

  /// Flag indicating if the task needs to be synced with remote
  final bool isDirty;

  /// Flag indicating if the task has been deleted (soft delete)
  final bool isDeleted;

  /// Last updated timestamp
  final DateTime? updatedAt;

  factory PlantTaskModel.fromJson(Map<String, dynamic> json) {
    return PlantTaskModel(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.watering,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      intervalDays: json['intervalDays'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      nextScheduledDate: json['nextScheduledDate'] != null
          ? DateTime.parse(json['nextScheduledDate'] as String)
          : null,
      isDirty: json['isDirty'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'type': type.name,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status.name,
      'intervalDays': intervalDays,
      'createdAt': createdAt.toIso8601String(),
      'nextScheduledDate': nextScheduledDate?.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create PlantTaskModel from PlantTask entity
  factory PlantTaskModel.fromEntity(PlantTask task) {
    return PlantTaskModel(
      id: task.id,
      plantId: task.plantId,
      type: task.type,
      title: task.title,
      description: task.description,
      scheduledDate: task.scheduledDate,
      completedDate: task.completedDate,
      status: task.status,
      intervalDays: task.intervalDays,
      createdAt: task.createdAt,
      nextScheduledDate: task.nextScheduledDate,
      isDirty: false,
      isDeleted: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to entity
  PlantTask toEntity() {
    return PlantTask(
      id: id,
      plantId: plantId,
      type: type,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      status: status,
      intervalDays: intervalDays,
      createdAt: createdAt,
      nextScheduledDate: nextScheduledDate,
    );
  }

  /// Copy with modifications
  PlantTaskModel copyWith({
    String? id,
    String? plantId,
    TaskType? type,
    String? title,
    String? description,
    DateTime? scheduledDate,
    DateTime? completedDate,
    TaskStatus? status,
    int? intervalDays,
    DateTime? createdAt,
    DateTime? nextScheduledDate,
    bool? isDirty,
    bool? isDeleted,
    DateTime? updatedAt,
  }) {
    return PlantTaskModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      intervalDays: intervalDays ?? this.intervalDays,
      createdAt: createdAt ?? this.createdAt,
      nextScheduledDate: nextScheduledDate ?? this.nextScheduledDate,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
    );
  }

  /// Mark as dirty for sync
  PlantTaskModel markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as synced
  PlantTaskModel markAsSynced() {
    return copyWith(
      isDirty: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as deleted (soft delete)
  PlantTaskModel markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  PlantTaskModel markAsCompleted() {
    final now = DateTime.now();
    return copyWith(
      status: TaskStatus.completed,
      completedDate: now,
      nextScheduledDate: now.add(Duration(days: intervalDays)),
      isDirty: true,
      updatedAt: now,
    );
  }

  @override
  PlantTaskModel updateStatus() {
    if (status == TaskStatus.completed) return this;

    final newStatus = isOverdue ? TaskStatus.overdue : TaskStatus.pending;
    if (newStatus != status) {
      return copyWith(
        status: newStatus,
        isDirty: true,
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }
}