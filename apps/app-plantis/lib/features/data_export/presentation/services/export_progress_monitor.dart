import '../../domain/entities/export_request.dart';

/// Monitors export progress and updates state
/// Extracted from notifier for better separation of concerns
class ExportProgressMonitor {
  /// Gets progress steps for an export
  List<(double, String)> getProgressSteps(ExportRequest request) {
    return [
      (0.1, 'Coletando dados das plantas...'),
      (0.25, 'Processando tarefas e lembretes...'),
      (0.4, 'Compilando fotos das plantas...'),
      (0.55, 'Coletando comentários das plantas...'),
      (0.7, 'Organizando configurações...'),
      (0.85, 'Gerando arquivo ${request.format.displayName}...'),
      (1.0, 'Finalizando exportação...'),
    ];
  }

  /// Calculates time remaining based on progress
  String calculateTimeRemaining(int currentStep, int totalSteps) {
    const secondsPerStep = 3;
    final stepsRemaining = totalSteps - currentStep - 1;
    final secondsRemaining = stepsRemaining * secondsPerStep;
    return '$secondsRemaining segundos restantes';
  }

  /// Formats progress step message
  String formatProgressMessage(
    double percentage,
    String currentTask,
    String? timeRemaining,
  ) {
    return '$currentTask ${percentage.toStringAsFixed(0)}%'
        '${timeRemaining != null ? ' - $timeRemaining' : ''}';
  }
}
