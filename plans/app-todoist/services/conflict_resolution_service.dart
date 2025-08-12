/// Serviço para detecção e resolução de conflitos em operações concorrentes
library;

import '../models/conflict_resolution.dart';
// Project imports:
import '../models/task_model.dart';

/// Serviço principal para gerenciar conflitos de sincronização
class ConflictResolutionService {
  /// Configuração atual para detecção de conflitos
  final ConflictDetectionConfig config;

  ConflictResolutionService({
    this.config = const ConflictDetectionConfig(),
  });

  /// Detecta se há conflito entre duas versões de uma task
  TaskConflict? detectConflict(Task localTask, Task remoteTask) {
    // Se são a mesma versão, não há conflito
    if (localTask.version == remoteTask.version &&
        localTask.updatedAt == remoteTask.updatedAt) {
      return null;
    }

    // Detectar tipo de conflito
    final conflictType = _determineConflictType(localTask, remoteTask);
    final conflictingFields = _findConflictingFields(localTask, remoteTask);
    final recommendedStrategy = _determineResolutionStrategy(
      localTask,
      remoteTask,
      conflictType,
      conflictingFields,
    );

    return TaskConflict(
      taskId: localTask.id,
      type: conflictType,
      localVersion: localTask,
      remoteVersion: remoteTask,
      detectedAt: DateTime.now(),
      recommendedStrategy: recommendedStrategy,
      conflictingFields: conflictingFields,
    );
  }

  /// Resolve um conflito automaticamente usando a estratégia especificada
  ConflictResolutionOutcome resolveConflict(
    TaskConflict conflict,
    ConflictResolutionStrategy? strategy,
  ) {
    final appliedStrategy = strategy ?? conflict.recommendedStrategy;

    try {
      switch (appliedStrategy) {
        case ConflictResolutionStrategy.lastWriteWins:
          return _resolveLastWriteWins(conflict);

        case ConflictResolutionStrategy.firstWriteWins:
          return _resolveFirstWriteWins(conflict);

        case ConflictResolutionStrategy.autoMerge:
          return _resolveAutoMerge(conflict);

        case ConflictResolutionStrategy.manualResolution:
          return ConflictResolutionOutcome(
            result: ConflictResolutionResult.needsManualResolution,
            appliedStrategy: appliedStrategy,
            message:
                'Conflito requer resolução manual: ${conflict.description}',
          );

        case ConflictResolutionStrategy.rejectOperation:
          return ConflictResolutionOutcome(
            result: ConflictResolutionResult.rejected,
            appliedStrategy: appliedStrategy,
            message:
                'Operação rejeitada devido a conflito: ${conflict.description}',
          );
      }
    } catch (e) {
      return ConflictResolutionOutcome(
        result: ConflictResolutionResult.rejected,
        appliedStrategy: appliedStrategy,
        message: 'Erro ao resolver conflito: $e',
      );
    }
  }

  /// Verifica se uma operação pode causar conflito
  bool wouldCauseConflict(Task currentTask, Task proposedTask) {
    final conflict = detectConflict(currentTask, proposedTask);
    return conflict != null;
  }

  /// Determina o tipo de conflito entre duas tasks
  ConflictType _determineConflictType(Task local, Task remote) {
    // Conflito de versão
    if (local.version != remote.version) {
      return ConflictType.versionConflict;
    }

    // Conflito de timestamp (modificações muito próximas)
    final timeDiff = (local.updatedAt - remote.updatedAt).abs();
    if (timeDiff <= config.simultaneousOperationThreshold * 1000) {
      return ConflictType.timestampConflict;
    }

    // Conflito de posição
    if (local.position != remote.position) {
      return ConflictType.positionConflict;
    }

    // Conflito de dados (outros campos)
    return ConflictType.dataConflict;
  }

  /// Encontra campos específicos que estão em conflito
  List<String> _findConflictingFields(Task local, Task remote) {
    final conflicting = <String>[];

    if (local.title != remote.title) conflicting.add('title');
    if (local.description != remote.description) conflicting.add('description');
    if (local.isCompleted != remote.isCompleted) conflicting.add('isCompleted');
    if (local.isStarred != remote.isStarred) conflicting.add('isStarred');
    if (local.priority != remote.priority) conflicting.add('priority');
    if (local.position != remote.position) conflicting.add('position');
    if (local.dueDate != remote.dueDate) conflicting.add('dueDate');
    if (local.reminderDate != remote.reminderDate) {
      conflicting.add('reminderDate');
    }
    if (local.assignedToId != remote.assignedToId) {
      conflicting.add('assignedToId');
    }
    if (local.listId != remote.listId) conflicting.add('listId');
    if (local.parentTaskId != remote.parentTaskId) {
      conflicting.add('parentTaskId');
    }

    // Comparar tags
    if (!_listsEqual(local.tags, remote.tags)) conflicting.add('tags');

    return conflicting;
  }

  /// Determina a melhor estratégia de resolução para um conflito
  ConflictResolutionStrategy _determineResolutionStrategy(
    Task local,
    Task remote,
    ConflictType type,
    List<String> conflictingFields,
  ) {
    // Para conflitos simples de timestamp, usar lastWriteWins
    if (type == ConflictType.timestampConflict &&
        conflictingFields.length <= 1) {
      return ConflictResolutionStrategy.lastWriteWins;
    }

    // Para conflitos de posição, usar merge automático
    if (type == ConflictType.positionConflict) {
      return ConflictResolutionStrategy.autoMerge;
    }

    // Para conflitos com campos não mesclveis, pedir resolução manual
    if (conflictingFields
        .any((field) => config.nonMergeableFields.contains(field))) {
      return config.allowManualResolution
          ? ConflictResolutionStrategy.manualResolution
          : ConflictResolutionStrategy.lastWriteWins;
    }

    // Se configurado para tentar merge automático
    if (config.attemptAutoMerge && conflictingFields.length <= 3) {
      return ConflictResolutionStrategy.autoMerge;
    }

    // Usar estratégia padrão
    return config.defaultStrategy;
  }

  /// Resolve conflito usando estratégia "último que escreve ganha"
  ConflictResolutionOutcome _resolveLastWriteWins(TaskConflict conflict) {
    final winner = conflict.localVersion.isNewerThan(conflict.remoteVersion)
        ? conflict.localVersion
        : conflict.remoteVersion;

    return ConflictResolutionOutcome(
      result: ConflictResolutionResult.resolved,
      resolvedTask: winner,
      appliedStrategy: ConflictResolutionStrategy.lastWriteWins,
      message: 'Conflito resolvido: versão mais recente mantida',
    );
  }

  /// Resolve conflito usando estratégia "primeiro que escreve ganha"
  ConflictResolutionOutcome _resolveFirstWriteWins(TaskConflict conflict) {
    final winner = conflict.localVersion.isNewerThan(conflict.remoteVersion)
        ? conflict.remoteVersion
        : conflict.localVersion;

    return ConflictResolutionOutcome(
      result: ConflictResolutionResult.resolved,
      resolvedTask: winner,
      appliedStrategy: ConflictResolutionStrategy.firstWriteWins,
      message: 'Conflito resolvido: primeira versão mantida',
    );
  }

  /// Resolve conflito tentando fazer merge automático dos campos
  ConflictResolutionOutcome _resolveAutoMerge(TaskConflict conflict) {
    try {
      final merged =
          _mergeTaskVersions(conflict.localVersion, conflict.remoteVersion);

      return ConflictResolutionOutcome(
        result: ConflictResolutionResult.resolved,
        resolvedTask: merged,
        appliedStrategy: ConflictResolutionStrategy.autoMerge,
        message: 'Conflito resolvido: versões mescladas automaticamente',
      );
    } catch (e) {
      // Se não conseguir fazer merge, usar lastWriteWins como fallback
      return _resolveLastWriteWins(conflict);
    }
  }

  /// Mescla duas versões de uma task automaticamente
  Task _mergeTaskVersions(Task local, Task remote) {
    // Usar a versão mais recente como base
    final base = local.isNewerThan(remote) ? local : remote;
    final other = local.isNewerThan(remote) ? remote : local;

    // Mesclar campos que podem ser combinados
    final mergedTags = <String>{...base.tags, ...other.tags}.toList();

    // Para campos conflitantes, priorizar a versão mais recente
    return base.copyWith(
      tags: mergedTags,
      // Se um tem data de vencimento e outro não, manter a que tem
      dueDate: base.dueDate ?? other.dueDate,
      reminderDate: base.reminderDate ?? other.reminderDate,
      // Incrementar versão para indicar merge
      version:
          (base.version > other.version ? base.version : other.version) + 1,
    );
  }

  /// Compara duas listas para verificar se são iguais
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
