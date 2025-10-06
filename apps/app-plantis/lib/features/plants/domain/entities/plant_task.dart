import 'package:core/core.dart' show Equatable;

/// PlantTask-specific enums
///
/// NOTE: Similar enums exist in features/tasks/domain/entities/task.dart
/// These are simplified versions for the PlantTask context
/// TODO: Consider unification with main Task enums in future refactor
enum TaskType {
  watering,
  fertilizing,
  pruning,
  sunlightCheck,
  pestInspection,
  replanting,
}

enum TaskStatus { pending, completed, overdue }

class PlantTask extends Equatable {
  final String id;
  final String plantId;
  final TaskType type;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final TaskStatus status;
  final int intervalDays;
  final DateTime createdAt;
  final DateTime? nextScheduledDate;

  const PlantTask({
    required this.id,
    required this.plantId,
    required this.type,
    required this.title,
    this.description,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    required this.intervalDays,
    required this.createdAt,
    this.nextScheduledDate,
  });

  bool get isCompleted => status == TaskStatus.completed;

  DateTime get dueDate => scheduledDate;

  bool get isOverdue {
    if (status == TaskStatus.completed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    return taskDate.isBefore(today); // Atrasada se a data é anterior a hoje
  }

  bool get isDueToday {
    if (status == TaskStatus.completed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return taskDate == today;
  }

  bool get isDueSoon {
    if (status == TaskStatus.completed) return false;
    final now = DateTime.now();
    final difference = scheduledDate.difference(now).inDays;
    return difference >= 0 && difference <= 2;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    return scheduledDate.difference(now).inDays;
  }

  String get statusText {
    if (status == TaskStatus.completed) return 'Concluída';
    if (isOverdue) return '${-daysUntilDue} dias atrás';
    if (isDueToday) return 'Hoje';
    if (isDueSoon) return 'Em $daysUntilDue dias';
    return 'Em $daysUntilDue dias';
  }

  PlantTask copyWith({
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
  }) {
    return PlantTask(
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
    );
  }

  PlantTask markAsCompleted() {
    final now = DateTime.now();
    return copyWith(
      status: TaskStatus.completed,
      completedDate: now,
      nextScheduledDate: now.add(Duration(days: intervalDays)),
    );
  }

  PlantTask updateStatus() {
    if (status == TaskStatus.completed) return this;

    final newStatus = isOverdue ? TaskStatus.overdue : TaskStatus.pending;
    return copyWith(status: newStatus);
  }

  @override
  List<Object?> get props => [
    id,
    plantId,
    type,
    title,
    description,
    scheduledDate,
    completedDate,
    status,
    intervalDays,
    createdAt,
    nextScheduledDate,
  ];
}

extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.watering:
        return 'Rega';
      case TaskType.fertilizing:
        return 'Fertilização';
      case TaskType.pruning:
        return 'Poda';
      case TaskType.sunlightCheck:
        return 'Verificação de luz solar';
      case TaskType.pestInspection:
        return 'Verificação de pragas';
      case TaskType.replanting:
        return 'Replantio';
    }
  }

  String get description {
    switch (this) {
      case TaskType.watering:
        return 'Regar a planta conforme necessário';
      case TaskType.fertilizing:
        return 'Aplicar fertilizante na planta';
      case TaskType.pruning:
        return 'Podar galhos e folhas secas';
      case TaskType.sunlightCheck:
        return 'Verificar se a planta está recebendo luz adequada';
      case TaskType.pestInspection:
        return 'Inspecionar a planta em busca de pragas ou doenças';
      case TaskType.replanting:
        return 'Replantar em vaso maior ou novo substrato';
    }
  }
}
