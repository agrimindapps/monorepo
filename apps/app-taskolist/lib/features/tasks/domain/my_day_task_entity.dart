import 'package:equatable/equatable.dart';

/// Representa uma tarefa adicionada ao "Meu Dia"
class MyDayTaskEntity extends Equatable {
  /// ID único do registro
  final String id;
  
  /// ID da tarefa associada
  final String taskId;
  
  /// ID do usuário
  final String userId;
  
  /// Quando a tarefa foi adicionada ao dia
  final DateTime addedAt;

  const MyDayTaskEntity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.addedAt,
  });

  MyDayTaskEntity copyWith({
    String? id,
    String? taskId,
    String? userId,
    DateTime? addedAt,
  }) {
    return MyDayTaskEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, userId, addedAt];
}
