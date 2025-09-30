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
  final String plantId; // Apenas o ID da planta - relação com Plant
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

  bool get isOverdue {
    if (status != TaskStatus.pending) return false;

    // Comparar apenas a data (sem hora) para evitar falsos positivos
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return taskDate.isBefore(today); // Atrasada se a data é anterior a hoje
  }

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
    return 'Task{id: $id, title: $title, plantId: $plantId, type: ${type.displayName}, status: ${status.displayName}, dueDate: $dueDate}';
  }

  // Implementação dos métodos abstratos do BaseSyncEntity
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'title': title,
      'description': description,
      'plant_id': plantId,
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
  static Task fromModel(dynamic tarefaModel) {
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

    final taskType = mapCareType(tarefaModel.tipoCuidado as String);

    return Task(
      id: tarefaModel.id as String,
      createdAt: (tarefaModel.createdAt as DateTime?) ?? DateTime.now(),
      updatedAt: (tarefaModel.updatedAt as DateTime?) ?? DateTime.now(),
      lastSyncAt: tarefaModel.lastSyncAt as DateTime?,
      isDirty: (tarefaModel.isDirty as bool?) ?? false,
      isDeleted: (tarefaModel.isDeleted as bool?) ?? false,
      version: (tarefaModel.version as int?) ?? 1,
      userId: tarefaModel.userId as String?,
      moduleName: tarefaModel.moduleName as String?,
      title: taskType.displayName,
      description: _getTaskDescription(tarefaModel.tipoCuidado as String),
      plantId: tarefaModel.plantaId as String,
      type: taskType,
      status:
          ((tarefaModel.concluida as bool?) ?? false)
              ? TaskStatus.completed
              : TaskStatus.pending,
      priority: mapPriority(tarefaModel.tipoCuidado as String),
      dueDate: tarefaModel.dataExecucao as DateTime,
      completedAt: tarefaModel.dataConclusao as DateTime?,
      completionNotes: tarefaModel.observacoes as String?,
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

  /// Convert Task entity directly to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'plantId': plantId,
      'type': type.key,
      'status': status.key,
      'priority': priority.key,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'completionNotes': completionNotes,
      'isRecurring': isRecurring,
      'recurringIntervalDays': recurringIntervalDays,
      'nextDueDate': nextDueDate?.millisecondsSinceEpoch,
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
    };
  }

  /// Create Task entity directly from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
      title: json['title'] as String,
      description: json['description'] as String?,
      plantId: json['plantId'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.key == json['type'],
        orElse: () => TaskType.custom,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.key == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.key == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int),
      completedAt:
          json['completedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
              : null,
      completionNotes: json['completionNotes'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringIntervalDays: json['recurringIntervalDays'] as int?,
      nextDueDate:
          json['nextDueDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['nextDueDate'] as int)
              : null,
      isDirty: json['isDirty'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      userId: json['userId'] as String?,
      moduleName: json['moduleName'] as String?,
      lastSyncAt:
          json['lastSyncAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['lastSyncAt'] as int)
              : null,
    );
  }

  /// Create Task entity from Firebase map
  static Task fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return Task(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      plantId: map['plant_id'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.key == map['type'],
        orElse: () => TaskType.custom,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.key == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.key == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.parse(map['due_date'] as String),
      completedAt:
          map['completed_at'] != null
              ? DateTime.parse(map['completed_at'] as String)
              : null,
      completionNotes: map['completion_notes'] as String?,
      isRecurring: map['is_recurring'] as bool? ?? false,
      recurringIntervalDays: map['recurring_interval_days'] as int?,
      nextDueDate:
          map['next_due_date'] != null
              ? DateTime.parse(map['next_due_date'] as String)
              : null,
    );
  }
}
