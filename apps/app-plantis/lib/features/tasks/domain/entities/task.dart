import 'package:core/core.dart';

enum TaskType {
  watering('regar', 'Regar'),
  fertilizing('adubar', 'Adubar'),
  pruning('podar', 'Podar'),
  repotting('replantar', 'Replantar'),
  cleaning('limpar', 'Limpar'),
  spraying('pulverizar', 'Pulverizar'),
  sunlight('sol', 'Colocar no Sol'),
  shade('sombra', 'Colocar na Sombra'),
  pestInspection('inspecao_pragas', 'Inspeção de Pragas'),
  custom('custom', 'Personalizada');

  const TaskType(this.key, this.displayName);
  final String key;
  final String displayName;
}

enum TaskStatus {
  pending('pendente', 'Pendente'),
  completed('concluida', 'Concluída'),
  overdue('atrasada', 'Atrasada'),
  cancelled('cancelada', 'Cancelada');

  const TaskStatus(this.key, this.displayName);
  final String key;
  final String displayName;
}

enum TaskPriority {
  low('baixa', 'Baixa'),
  medium('media', 'Média'),
  high('alta', 'Alta'),
  urgent('urgente', 'Urgente');

  const TaskPriority(this.key, this.displayName);
  final String key;
  final String displayName;
}

class Task extends BaseSyncEntity {
  final String title;
  final String? description;
  final String plantId;
  final String plantName;
  final TaskType type;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final DateTime? completedAt;
  final String? completionNotes;
  final bool isRecurring;
  final int? recurringIntervalDays;
  final DateTime? nextDueDate;

  const Task({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    this.description,
    required this.plantId,
    required this.plantName,
    required this.type,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.dueDate,
    this.completedAt,
    this.completionNotes,
    this.isRecurring = false,
    this.recurringIntervalDays,
    this.nextDueDate,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
  });

  @override
  Task copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return Task(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      title: title,
      description: description,
      plantId: plantId,
      plantName: plantName,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
      completedAt: completedAt,
      completionNotes: completionNotes,
      isRecurring: isRecurring,
      recurringIntervalDays: recurringIntervalDays,
      nextDueDate: nextDueDate,
    );
  }

  Task copyWithTaskData({
    String? title,
    String? description,
    String? plantId,
    String? plantName,
    TaskType? type,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    String? completionNotes,
    bool? isRecurring,
    int? recurringIntervalDays,
    DateTime? nextDueDate,
  }) {
    return Task(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastSyncAt: lastSyncAt,
      isDirty: true,
      isDeleted: isDeleted,
      version: version,
      userId: userId,
      moduleName: moduleName,
      title: title ?? this.title,
      description: description ?? this.description,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalDays:
          recurringIntervalDays ?? this.recurringIntervalDays,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    title,
    description,
    plantId,
    plantName,
    type,
    status,
    priority,
    dueDate,
    completedAt,
    completionNotes,
    isRecurring,
    recurringIntervalDays,
    nextDueDate,
    isDeleted,
    needsSync,
  ];

  bool get isOverdue =>
      status == TaskStatus.pending && DateTime.now().isAfter(dueDate);

  bool get isDueToday {
    final today = DateTime.now();
    final due = dueDate;
    return today.year == due.year &&
        today.month == due.month &&
        today.day == due.day;
  }

  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final due = dueDate;
    return tomorrow.year == due.year &&
        tomorrow.month == due.month &&
        tomorrow.day == due.day;
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, plantName: $plantName, type: ${type.displayName}, status: ${status.displayName}, dueDate: $dueDate}';
  }

  // Implementação dos métodos abstratos do BaseSyncEntity
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'title': title,
      'description': description,
      'plant_id': plantId,
      'plant_name': plantName,
      'type': type.key,
      'status': status.key,
      'priority': priority.key,
      'due_date': dueDate.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'completion_notes': completionNotes,
      'is_recurring': isRecurring,
      'recurring_interval_days': recurringIntervalDays,
      'next_due_date': nextDueDate?.toIso8601String(),
    };
  }

  @override
  Task markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  Task markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  Task markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  Task incrementVersion() {
    return copyWith(
      version: version + 1,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Task withUserId(String userId) {
    return copyWith(userId: userId, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  Task withModule(String moduleName) {
    return copyWith(
      moduleName: moduleName,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria uma Task entity a partir de um TarefaModel
  static Task fromModel(dynamic tarefaModel, {String? plantName}) {
    // Mapeia tipos de cuidado para TaskType
    TaskType mapCareType(String tipoCuidado) {
      switch (tipoCuidado) {
        case 'agua':
          return TaskType.watering;
        case 'adubo':
          return TaskType.fertilizing;
        case 'poda':
          return TaskType.pruning;
        case 'replantar':
          return TaskType.repotting;
        case 'inspecao_pragas':
          return TaskType.pestInspection;
        case 'banho_sol':
          return TaskType.sunlight;
        default:
          return TaskType.custom;
      }
    }

    // Mapeia prioridade baseado no tipo de cuidado
    TaskPriority mapPriority(String tipoCuidado) {
      switch (tipoCuidado) {
        case 'agua':
          return TaskPriority.high;
        case 'adubo':
          return TaskPriority.medium;
        case 'poda':
          return TaskPriority.medium;
        case 'replantar':
          return TaskPriority.high;
        case 'inspecao_pragas':
          return TaskPriority.high;
        case 'banho_sol':
          return TaskPriority.low;
        default:
          return TaskPriority.medium;
      }
    }

    final taskType = mapCareType(tarefaModel.tipoCuidado);

    return Task(
      id: tarefaModel.id,
      createdAt: tarefaModel.createdAt ?? DateTime.now(),
      updatedAt: tarefaModel.updatedAt ?? DateTime.now(),
      lastSyncAt: tarefaModel.lastSyncAt,
      isDirty: tarefaModel.isDirty,
      isDeleted: tarefaModel.isDeleted,
      version: tarefaModel.version,
      userId: tarefaModel.userId,
      moduleName: tarefaModel.moduleName,
      title: taskType.displayName,
      description: _getTaskDescription(tarefaModel.tipoCuidado),
      plantId: tarefaModel.plantaId,
      plantName: plantName ?? 'Planta',
      type: taskType,
      status: tarefaModel.concluida ? TaskStatus.completed : TaskStatus.pending,
      priority: mapPriority(tarefaModel.tipoCuidado),
      dueDate: tarefaModel.dataExecucao,
      completedAt: tarefaModel.dataConclusao,
      completionNotes: tarefaModel.observacoes,
    );
  }

  static String _getTaskDescription(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return 'Verificar e regar conforme necessário';
      case 'adubo':
        return 'Aplicar fertilizante ou adubo';
      case 'banho_sol':
        return 'Expor a planta ao sol adequado';
      case 'inspecao_pragas':
        return 'Verificar folhas e caule em busca de pragas';
      case 'poda':
        return 'Remover folhas secas e fazer poda necessária';
      case 'replantar':
        return 'Trocar vaso ou substrato';
      default:
        return 'Executar cuidado personalizado';
    }
  }
}
