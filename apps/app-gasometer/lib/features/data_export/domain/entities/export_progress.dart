/// Classe para representar progresso da exportação de dados LGPD
class ExportProgress {

  const ExportProgress({
    required this.phase,
    required this.percentage,
    required this.currentTask,
    this.processedCounts = const {},
  });

  factory ExportProgress.initial() => const ExportProgress(
    phase: 'initializing',
    percentage: 0.0,
    currentTask: 'Iniciando exportação...',
  );

  factory ExportProgress.collecting(String category, int processed, int total) => ExportProgress(
    phase: 'collecting',
    percentage: (processed / total * 50).clamp(0.0, 50.0),
    currentTask: 'Coletando dados: $category ($processed/$total)',
    processedCounts: {'processed': processed, 'total': total},
  );

  factory ExportProgress.processing(String task, double progress) => ExportProgress(
    phase: 'processing',
    percentage: 50.0 + (progress * 40).clamp(0.0, 40.0),
    currentTask: task,
  );

  factory ExportProgress.finalizing() => const ExportProgress(
    phase: 'finalizing',
    percentage: 95.0,
    currentTask: 'Finalizando arquivo...',
  );

  factory ExportProgress.completed() => const ExportProgress(
    phase: 'completed',
    percentage: 100.0,
    currentTask: 'Exportação concluída!',
  );

  factory ExportProgress.fromJson(Map<String, dynamic> json) => ExportProgress(
    phase: json['phase'] as String,
    percentage: (json['percentage'] as num).toDouble(),
    currentTask: json['current_task'] as String,
    processedCounts: Map<String, int>.from(json['processed_counts'] as Map? ?? {}),
  );
  final String phase;
  final double percentage;
  final String currentTask;
  final Map<String, int> processedCounts;

  Map<String, dynamic> toJson() => {
    'phase': phase,
    'percentage': percentage,
    'current_task': currentTask,
    'processed_counts': processedCounts,
  };

  ExportProgress copyWith({
    String? phase,
    double? percentage,
    String? currentTask,
    Map<String, int>? processedCounts,
  }) => ExportProgress(
    phase: phase ?? this.phase,
    percentage: percentage ?? this.percentage,
    currentTask: currentTask ?? this.currentTask,
    processedCounts: processedCounts ?? this.processedCounts,
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ExportProgress && 
    phase == other.phase &&
    percentage == other.percentage &&
    currentTask == other.currentTask;

  @override
  int get hashCode => Object.hash(phase, percentage, currentTask);

  @override
  String toString() => 'ExportProgress(phase: $phase, percentage: $percentage%, currentTask: $currentTask)';
}
