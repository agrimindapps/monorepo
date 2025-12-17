import 'package:equatable/equatable.dart';

/// Representa uma tarefa adicionada ao "Meu Dia"
/// 
/// Esta entity mapeia a relação muitos-para-muitos entre Tasks e dias.
/// Permite histórico: ver quais tarefas foram adicionadas em cada dia.
class MyDayTaskEntity extends Equatable {
  /// ID único do registro
  final String id;
  
  /// ID da tarefa associada
  final String taskId;
  
  /// Data do dia (sem hora) ao qual a tarefa foi adicionada
  /// Exemplo: 2025-12-17 00:00:00
  final DateTime dayDate;
  
  /// Quando a tarefa foi adicionada ao dia
  final DateTime addedAt;
  
  /// Se a tarefa foi completada enquanto estava no "Meu Dia"
  final bool wasCompleted;
  
  /// Quando foi completada (null se não foi)
  final DateTime? completedAt;
  
  /// Se foi removida do Meu Dia manualmente (swipe, etc)
  final bool wasRemoved;
  
  /// Quando foi removida (null se não foi)
  final DateTime? removedAt;
  
  /// Se este registro está arquivado (dias passados)
  final bool isArchived;

  const MyDayTaskEntity({
    required this.id,
    required this.taskId,
    required this.dayDate,
    required this.addedAt,
    this.wasCompleted = false,
    this.completedAt,
    this.wasRemoved = false,
    this.removedAt,
    this.isArchived = false,
  });

  /// Verifica se a tarefa está ativa no Meu Dia (não completada e não removida)
  bool get isActive => !wasCompleted && !wasRemoved;
  
  /// Verifica se é do dia de hoje
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dayDate.isAtSameMomentAs(today);
  }

  MyDayTaskEntity copyWith({
    String? id,
    String? taskId,
    DateTime? dayDate,
    DateTime? addedAt,
    bool? wasCompleted,
    DateTime? completedAt,
    bool? wasRemoved,
    DateTime? removedAt,
    bool? isArchived,
  }) {
    return MyDayTaskEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      dayDate: dayDate ?? this.dayDate,
      addedAt: addedAt ?? this.addedAt,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      completedAt: completedAt ?? this.completedAt,
      wasRemoved: wasRemoved ?? this.wasRemoved,
      removedAt: removedAt ?? this.removedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
  
  /// Marca como completada
  MyDayTaskEntity markAsCompleted() {
    return copyWith(
      wasCompleted: true,
      completedAt: DateTime.now(),
    );
  }
  
  /// Marca como removida
  MyDayTaskEntity markAsRemoved() {
    return copyWith(
      wasRemoved: true,
      removedAt: DateTime.now(),
    );
  }
  
  /// Arquiva (para dias passados)
  MyDayTaskEntity archive() {
    return copyWith(isArchived: true);
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        dayDate,
        addedAt,
        wasCompleted,
        completedAt,
        wasRemoved,
        removedAt,
        isArchived,
      ];
}
