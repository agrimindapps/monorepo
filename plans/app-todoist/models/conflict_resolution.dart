/// Sistema de resolução de conflitos para operações concorrentes
library;

// Project imports:
import 'task_model.dart';

/// Este arquivo define as estratégias e estruturas para lidar com conflitos
/// quando múltiplos usuários editam a mesma tarefa simultaneamente.

/// Tipos de conflito que podem ocorrer
enum ConflictType {
  /// Conflito de versão - duas versões diferentes da mesma task
  versionConflict,

  /// Conflito de timestamp - modificações simultâneas
  timestampConflict,

  /// Conflito de dados - campos específicos foram alterados
  dataConflict,

  /// Conflito de posição - task foi movida por usuários diferentes
  positionConflict,
}

/// Estratégias disponíveis para resolução de conflitos
enum ConflictResolutionStrategy {
  /// O último que escreve ganha (padrão para a maioria dos casos)
  lastWriteWins,

  /// O primeiro que escreve ganha (para operações críticas)
  firstWriteWins,

  /// Merge automático dos campos (quando possível)
  autoMerge,

  /// Solicitar resolução manual do usuário
  manualResolution,

  /// Rejeitar a operação e manter o estado atual
  rejectOperation,
}

/// Resultado de uma tentativa de resolução de conflito
enum ConflictResolutionResult {
  /// Conflito resolvido automaticamente
  resolved,

  /// Conflito precisa de resolução manual
  needsManualResolution,

  /// Operação foi rejeitada devido ao conflito
  rejected,

  /// Nenhum conflito detectado
  noConflict,
}

/// Representa um conflito detectado entre duas versões de uma task
class TaskConflict {
  /// ID da task em conflito
  final String taskId;

  /// Tipo do conflito
  final ConflictType type;

  /// Versão local (atual no dispositivo)
  final Task localVersion;

  /// Versão remota (no servidor)
  final Task remoteVersion;

  /// Timestamp quando o conflito foi detectado
  final DateTime detectedAt;

  /// Estratégia recomendada para resolução
  final ConflictResolutionStrategy recommendedStrategy;

  /// Campos específicos que estão em conflito
  final List<String> conflictingFields;

  TaskConflict({
    required this.taskId,
    required this.type,
    required this.localVersion,
    required this.remoteVersion,
    required this.detectedAt,
    required this.recommendedStrategy,
    required this.conflictingFields,
  });

  /// Verifica se o conflito pode ser resolvido automaticamente
  bool get canAutoResolve {
    return recommendedStrategy == ConflictResolutionStrategy.lastWriteWins ||
        recommendedStrategy == ConflictResolutionStrategy.firstWriteWins ||
        recommendedStrategy == ConflictResolutionStrategy.autoMerge;
  }

  /// Retorna uma descrição legível do conflito
  String get description {
    switch (type) {
      case ConflictType.versionConflict:
        return 'Task "${localVersion.title}" foi modificada por outro usuário. '
            'Versão local: ${localVersion.version}, Versão remota: ${remoteVersion.version}';
      case ConflictType.timestampConflict:
        return 'Task "${localVersion.title}" foi editada simultaneamente por múltiplos usuários.';
      case ConflictType.dataConflict:
        return 'Campos conflitantes em "${localVersion.title}": ${conflictingFields.join(", ")}';
      case ConflictType.positionConflict:
        return 'Task "${localVersion.title}" foi movida para posições diferentes.';
    }
  }

  @override
  String toString() {
    return 'TaskConflict(taskId: $taskId, type: $type, strategy: $recommendedStrategy)';
  }
}

/// Resultado de uma operação de resolução de conflito
class ConflictResolutionOutcome {
  /// Resultado da resolução
  final ConflictResolutionResult result;

  /// Task resultante após a resolução (null se rejeitada)
  final Task? resolvedTask;

  /// Estratégia que foi aplicada
  final ConflictResolutionStrategy appliedStrategy;

  /// Mensagem explicativa sobre o resultado
  final String message;

  /// Se true, a operação original deve ser repetida
  final bool shouldRetry;

  ConflictResolutionOutcome({
    required this.result,
    this.resolvedTask,
    required this.appliedStrategy,
    required this.message,
    this.shouldRetry = false,
  });

  /// Indica se a resolução foi bem-sucedida
  bool get isSuccess => result == ConflictResolutionResult.resolved;

  /// Indica se precisa de intervenção manual
  bool get needsManualIntervention =>
      result == ConflictResolutionResult.needsManualResolution;

  @override
  String toString() {
    return 'ConflictResolutionOutcome(result: $result, strategy: $appliedStrategy, message: $message)';
  }
}

/// Configuração para detecção e resolução de conflitos
class ConflictDetectionConfig {
  /// Estratégia padrão para resolução automática
  final ConflictResolutionStrategy defaultStrategy;

  /// Tempo limite em segundos para considerar operações simultâneas
  final int simultaneousOperationThreshold;

  /// Se true, sempre tenta merge automático antes de outras estratégias
  final bool attemptAutoMerge;

  /// Campos que nunca devem ser mesclados automaticamente
  final Set<String> nonMergeableFields;

  /// Se true, permite resolução manual via UI
  final bool allowManualResolution;

  const ConflictDetectionConfig({
    this.defaultStrategy = ConflictResolutionStrategy.lastWriteWins,
    this.simultaneousOperationThreshold = 5, // 5 segundos
    this.attemptAutoMerge = true,
    this.nonMergeableFields = const {'id', 'createdAt', 'createdById'},
    this.allowManualResolution = true,
  });
}

/// Resultado de uma operação batch com verificação de conflitos
class BatchOperationResult {
  /// Número total de tasks processadas
  final int totalTasks;

  /// Tasks que foram atualizadas com sucesso
  final List<Task> succeededTasks;

  /// Tasks que falharam na atualização
  final List<Task> failedTasks;

  /// Resultados detalhados de cada operação por ID da task
  final Map<String, ConflictResolutionOutcome> results;

  BatchOperationResult({
    required this.totalTasks,
    required this.succeededTasks,
    required this.failedTasks,
    required this.results,
  });

  /// Número de tasks que foram processadas com sucesso
  int get successCount => succeededTasks.length;

  /// Número de tasks que falharam
  int get failureCount => failedTasks.length;

  /// Taxa de sucesso da operação batch
  double get successRate => totalTasks > 0 ? successCount / totalTasks : 0.0;

  /// Se true, todas as tasks foram processadas com sucesso
  bool get isCompleteSuccess => failureCount == 0;

  /// Se true, todas as tasks falharam
  bool get isCompleteFailure => successCount == 0;

  /// Resumo das operações realizadas
  String get summary {
    if (isCompleteSuccess) {
      return 'Todas as $totalTasks tasks foram atualizadas com sucesso';
    } else if (isCompleteFailure) {
      return 'Todas as $totalTasks tasks falharam na atualização';
    } else {
      return '$successCount de $totalTasks tasks atualizadas com sucesso';
    }
  }

  @override
  String toString() {
    return 'BatchOperationResult(total: $totalTasks, success: $successCount, failed: $failureCount)';
  }
}
