

import '../domain/entities/export_request.dart';

/// Service specialized in calculating and managing export progress
/// Principle: Single Responsibility - Only handles progress calculations

class ExportProgressService {
  /// Calculates progress percentage based on current step
  double calculateProgressPercentage(int currentStep, int totalSteps) {
    if (totalSteps == 0) return 0.0;
    return ((currentStep + 1) / totalSteps) * 100;
  }

  /// Estimates remaining time based on average step duration
  String? estimateRemainingTime(
    int currentStep,
    int totalSteps,
    int averageStepDurationSeconds,
  ) {
    if (currentStep >= totalSteps - 1) return null;

    final remainingSteps = totalSteps - currentStep - 1;
    final totalSeconds = remainingSteps * averageStepDurationSeconds;

    if (totalSeconds < 60) {
      return '$totalSeconds segundos restantes';
    } else {
      final minutes = totalSeconds ~/ 60;
      return '$minutes ${minutes == 1 ? 'minuto' : 'minutos'} restantes';
    }
  }

  /// Gets progress messages for each export step
  List<String> getProgressSteps(ExportFormat format) {
    return [
      'Coletando dados do perfil...',
      'Processando favoritos...',
      'Compilando comentários...',
      'Gerando arquivo ${format.displayName}...',
      'Finalizando exportação...',
    ];
  }

  /// Creates initial progress state
  ExportProgress createInitialProgress() {
    return const ExportProgress.initial();
  }

  /// Creates completed progress state
  ExportProgress createCompletedProgress() {
    return const ExportProgress.completed();
  }

  /// Creates error progress state
  ExportProgress createErrorProgress(String errorMessage) {
    return ExportProgress.error(errorMessage);
  }

  /// Updates progress for a specific step
  ExportProgress updateProgress({
    required int currentStep,
    required int totalSteps,
    required ExportFormat format,
    required int averageStepDurationSeconds,
  }) {
    final steps = getProgressSteps(format);
    final percentage = calculateProgressPercentage(currentStep, totalSteps);
    final estimatedTime = estimateRemainingTime(
      currentStep,
      totalSteps,
      averageStepDurationSeconds,
    );

    return ExportProgress(
      percentage: percentage,
      currentTask: steps[currentStep],
      estimatedTimeRemaining: estimatedTime,
    );
  }
}
