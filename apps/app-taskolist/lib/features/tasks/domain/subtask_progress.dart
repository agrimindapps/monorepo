import 'package:equatable/equatable.dart';

/// Modelo representando o progresso de subtarefas de uma task
class SubtaskProgress extends Equatable {
  final int total;
  final int completed;

  const SubtaskProgress({
    required this.total,
    required this.completed,
  });

  /// Progresso de 0.0 a 1.0
  double get progress {
    if (total == 0) return 0.0;
    return completed / total;
  }

  /// Progresso em porcentagem (0-100)
  int get progressPercent => (progress * 100).round();

  /// Se todas as subtarefas foram completadas
  bool get isFullyCompleted => total > 0 && completed == total;

  /// Se tem alguma subtarefa completada
  bool get hasProgress => completed > 0;

  /// Se tem subtarefas
  bool get hasSubtasks => total > 0;

  /// Texto formatado "3/5"
  String get formattedCount => '$completed/$total';

  /// Texto formatado com label "3 de 5 concluídas"
  String get formattedLabel => '$completed de $total concluída${total != 1 ? 's' : ''}';

  const SubtaskProgress.empty()
      : total = 0,
        completed = 0;

  @override
  List<Object?> get props => [total, completed];

  @override
  String toString() => 'SubtaskProgress($formattedCount, $progressPercent%)';
}
