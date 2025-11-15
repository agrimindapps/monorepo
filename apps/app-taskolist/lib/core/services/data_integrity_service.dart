import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/tasks/data/task_local_datasource.dart';
import '../../features/tasks/data/task_model.dart';
import '../errors/failures.dart';

/// Serviço de integridade de dados para app-taskolist
///
/// Responsabilidades:
/// 1. **ID Reconciliation**: Mapear IDs locais temporários → IDs remotos do Firebase
/// 2. **Orphan Detection**: Detectar tasks sem TaskList válido ou subtasks sem parent
/// 3. **Duplicate Detection**: Identificar e remover duplicatas
///
/// **Quando usar:**
/// - Após sync manual (forceSyncApp)
/// - Periodicamente em background (timer)
/// - Antes de operações críticas (compartilhamento, exportação)
///
/// **Exemplo:**
/// ```dart
/// final service = getIt<DataIntegrityService>();
///
/// // Reconciliar ID após sync
/// await service.reconcileTaskId('local_abc123', 'firebase_xyz789');
///
/// // Verificação completa
/// final result = await service.verifyTaskIntegrity();
/// result.fold(
///   (failure) => print('Erro: ${failure.message}'),
///   (report) => print('Tasks verificadas: ${report.totalTasks}'),
/// );
/// ```
@injectable
class DataIntegrityService {
  const DataIntegrityService(this._taskLocalDataSource);

  final TaskLocalDataSource _taskLocalDataSource;

  // ========================================================================
  // ID RECONCILIATION
  // ========================================================================

  /// Reconcilia ID de uma task: remove versão local e mantém apenas versão remota
  ///
  /// **Fluxo:**
  /// 1. Usuário cria task offline → ID local (ex: 'local_abc123')
  /// 2. Sync envia ao Firebase → Firebase retorna ID remoto (ex: 'firebase_xyz789')
  /// 3. Este método:
  ///    - Remove entrada com ID local do storage local
  ///    - Mantém apenas entrada com ID remoto
  ///    - Atualiza referências em subtasks (parentTaskId)
  ///
  /// **Exemplo:**
  /// ```dart
  /// // Após sync bem-sucedido
  /// await reconcileTaskId('local_abc123', 'firebase_xyz789');
  /// // Storage agora contém apenas 'firebase_xyz789'
  /// ```
  Future<Either<Failure, void>> reconcileTaskId(String localId, String remoteId) async {
    try {
      if (localId == remoteId) {
        // Mesmo ID - não há o que reconciliar
        return Right<Failure, void>(null);
      }

      if (kDebugMode) {
        debugPrint('[DataIntegrity] Reconciling task ID: $localId → $remoteId');
      }

      // 1. Buscar task local
      final localTask = await _taskLocalDataSource.getTask(localId);
      if (localTask == null) {
        // Task local já foi removida ou nunca existiu
        if (kDebugMode) {
          debugPrint('[DataIntegrity] Local task $localId not found - already reconciled?');
        }
        return Right<Failure, void>(null);
      }

      // 2. Verificar se task remota já existe
      final remoteTask = await _taskLocalDataSource.getTask(remoteId);
      if (remoteTask != null) {
        // Task remota já existe - apenas remover duplicata local
        await _taskLocalDataSource.deleteTask(localId);

        if (kDebugMode) {
          debugPrint('[DataIntegrity] ✅ Removed duplicate local task $localId');
        }
      } else {
        // Task remota não existe - atualizar ID da task local
        final updatedTask = localTask.copyWith(id: remoteId);
        await _taskLocalDataSource.cacheTask(updatedTask);
        await _taskLocalDataSource.deleteTask(localId);

        if (kDebugMode) {
          debugPrint('[DataIntegrity] ✅ Updated task ID: $localId → $remoteId');
        }
      }

      // 3. Atualizar referências em subtasks (parentTaskId)
      await _updateSubtaskReferences(localId, remoteId);

      return Right<Failure, void>(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[DataIntegrity] ❌ Error reconciling task ID: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left<Failure, void>(ServerFailure('Failed to reconcile task ID: $e'));
    }
  }

  /// Atualiza referências de parentTaskId em subtasks
  Future<void> _updateSubtaskReferences(String oldParentId, String newParentId) async {
    try {
      // Buscar todas as subtasks que referenciam o ID antigo
      final allTasks = await _taskLocalDataSource.getTasks();
      final subtasksToUpdate = allTasks.where(
        (task) => task.parentTaskId == oldParentId,
      ).toList();

      if (subtasksToUpdate.isEmpty) {
        return; // Nenhuma subtask referencia este parent
      }

      if (kDebugMode) {
        debugPrint('[DataIntegrity] Updating ${subtasksToUpdate.length} subtask references: $oldParentId → $newParentId');
      }

      // Atualizar cada subtask
      for (final subtask in subtasksToUpdate) {
        final updatedSubtask = subtask.copyWith(parentTaskId: newParentId);
        await _taskLocalDataSource.updateTask(updatedSubtask);
      }

      if (kDebugMode) {
        debugPrint('[DataIntegrity] ✅ Updated ${subtasksToUpdate.length} subtask references');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DataIntegrity] ⚠️ Error updating subtask references: $e');
      }
      // Não propagar erro - continuar verificação
    }
  }

  // ========================================================================
  // INTEGRITY VERIFICATION
  // ========================================================================

  /// Verifica integridade completa de todas as tasks no storage local
  ///
  /// **Verificações:**
  /// 1. **Orphaned Subtasks**: Subtasks cujo parentTaskId não existe
  /// 2. **Duplicate IDs**: Tasks com IDs duplicados (improvável mas possível)
  /// 3. **Invalid References**: Tasks com listId inválido (se TaskList não existir)
  ///
  /// **Retorna:** IntegrityReport com estatísticas e problemas encontrados
  Future<Either<Failure, IntegrityReport>> verifyTaskIntegrity() async {
    try {
      if (kDebugMode) {
        debugPrint('[DataIntegrity] 🔍 Starting task integrity verification...');
      }

      final startTime = DateTime.now();
      final report = IntegrityReport();

      // Buscar todas as tasks
      final allTasks = await _taskLocalDataSource.getTasks();
      report.totalTasks = allTasks.length;

      if (kDebugMode) {
        debugPrint('[DataIntegrity] Verifying ${allTasks.length} tasks...');
      }

      // 1. Verificar duplicatas de ID
      await _checkDuplicateIds(allTasks, report);

      // 2. Verificar orphaned subtasks
      await _checkOrphanedSubtasks(allTasks, report);

      // 3. Verificar tasks órfãs (sem TaskList válido) - será implementado quando TaskList estiver sincronizado
      // await _checkOrphanedTasks(allTasks, report);

      final duration = DateTime.now().difference(startTime);
      report.verificationDuration = duration;

      if (kDebugMode) {
        debugPrint('[DataIntegrity] ✅ Verification complete in ${duration.inMilliseconds}ms');
        debugPrint('[DataIntegrity] Report: ${report.summary}');
      }

      return Right(report);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[DataIntegrity] ❌ Error verifying task integrity: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(ServerFailure('Failed to verify task integrity: $e'));
    }
  }

  /// Verifica duplicatas de ID (improvável mas possível em cenários de erro)
  Future<void> _checkDuplicateIds(List<TaskModel> tasks, IntegrityReport report) async {
    final idCounts = <String, int>{};

    for (final task in tasks) {
      idCounts[task.id] = (idCounts[task.id] ?? 0) + 1;
    }

    final duplicates = idCounts.entries.where((entry) => entry.value > 1);

    if (duplicates.isNotEmpty) {
      report.duplicateIds.addAll(duplicates.map((e) => e.key));

      if (kDebugMode) {
        debugPrint('[DataIntegrity] ⚠️ Found ${duplicates.length} duplicate IDs');
      }

      // Auto-fix: Remover duplicatas (manter apenas primeira ocorrência)
      for (final duplicateId in report.duplicateIds) {
        final duplicateTasks = tasks.where((t) => t.id == duplicateId).toList();
        // Remover todas exceto a primeira
        for (var i = 1; i < duplicateTasks.length; i++) {
          await _taskLocalDataSource.deleteTask(duplicateId);
          report.issuesFixed++;
        }
      }
    }
  }

  /// Verifica subtasks órfãs (parentTaskId aponta para task inexistente)
  Future<void> _checkOrphanedSubtasks(List<TaskModel> tasks, IntegrityReport report) async {
    final taskIds = tasks.map((t) => t.id).toSet();
    final subtasks = tasks.where((t) => t.parentTaskId != null);

    for (final subtask in subtasks) {
      if (!taskIds.contains(subtask.parentTaskId)) {
        report.orphanedSubtasks.add(subtask.id);

        if (kDebugMode) {
          debugPrint('[DataIntegrity] ⚠️ Orphaned subtask: ${subtask.id} (parent: ${subtask.parentTaskId} not found)');
        }

        // Auto-fix: Converter subtask órfã em task principal (remover parentTaskId)
        final fixedTask = subtask.copyWith(parentTaskId: null);
        await _taskLocalDataSource.updateTask(fixedTask);
        report.issuesFixed++;
      }
    }
  }

  // ========================================================================
  // BATCH OPERATIONS
  // ========================================================================

  /// Reconcilia múltiplos IDs em batch (otimizado para performance)
  ///
  /// **Exemplo:**
  /// ```dart
  /// await reconcileBatch([
  ///   ('local_1', 'firebase_1'),
  ///   ('local_2', 'firebase_2'),
  ///   ('local_3', 'firebase_3'),
  /// ]);
  /// ```
  Future<Either<Failure, void>> reconcileBatch(List<(String, String)> idPairs) async {
    try {
      if (kDebugMode) {
        debugPrint('[DataIntegrity] Starting batch reconciliation of ${idPairs.length} tasks...');
      }

      for (final (localId, remoteId) in idPairs) {
        (await reconcileTaskId(localId, remoteId)).fold(
          (failure) {
            // Log erro mas continua com próxima task
            if (kDebugMode) {
              debugPrint('[DataIntegrity] ⚠️ Failed to reconcile $localId → $remoteId: ${failure.message}');
            }
          },
          (_) {
            // Sucesso - continuar
          },
        );
      }

      if (kDebugMode) {
        debugPrint('[DataIntegrity] ✅ Batch reconciliation complete');
      }

      return Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(ServerFailure('Batch reconciliation failed: $e'));
    }
  }
}

// ============================================================================
// INTEGRITY REPORT
// ============================================================================

/// Relatório de verificação de integridade
class IntegrityReport {
  int totalTasks = 0;
  List<String> duplicateIds = [];
  List<String> orphanedSubtasks = [];
  List<String> orphanedTasks = []; // Tasks sem TaskList válido (futuro)
  int issuesFixed = 0;
  Duration verificationDuration = Duration.zero;

  bool get hasIssues => duplicateIds.isNotEmpty ||
                        orphanedSubtasks.isNotEmpty ||
                        orphanedTasks.isNotEmpty;

  int get totalIssues => duplicateIds.length +
                         orphanedSubtasks.length +
                         orphanedTasks.length;

  String get summary {
    return '''
IntegrityReport {
  Total tasks: $totalTasks
  Duplicate IDs: ${duplicateIds.length}
  Orphaned subtasks: ${orphanedSubtasks.length}
  Orphaned tasks: ${orphanedTasks.length}
  Issues fixed: $issuesFixed
  Duration: ${verificationDuration.inMilliseconds}ms
}''';
  }
}
