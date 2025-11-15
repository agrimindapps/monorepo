import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/tasks/domain/task_entity.dart';

/// Configuração de sincronização específica do app-taskolist
/// Gerencia sincronização offline-first de tarefas, listas e tags
/// com estratégias otimizadas para dados de produtividade
///
/// **ID Reconciliation:**
/// O sistema usará DataIntegrityService para prevenir duplicação quando:
/// 1. Usuário cria task offline (ID local temporário)
/// 2. Task é sincronizada com Firebase (pode receber ID remoto diferente)
/// 3. DataIntegrityService reconcilia IDs (atualiza referências de dados)
///
/// **Quando executar ID Reconciliation:**
/// - Após forceSync manual: `await dataIntegrityService.verifyTaskIntegrity()`
/// - Periodicamente em background (timer)
/// - Antes de operações críticas (exportação, compartilhamento)
///
/// **Exemplo de uso:**
/// ```dart
/// // 1. Criar task offline
/// final task = TaskEntity(id: 'local_abc123', ...);
/// await unifiedSync.create('taskolist', task);
///
/// // 2. Sincronizar
/// await unifiedSync.forceSyncApp('taskolist');
///
/// // 3. Reconciliar IDs (se necessário)
/// final dataIntegrity = getIt<DataIntegrityService>();
/// await dataIntegrity.verifyTaskIntegrity();
/// ```
abstract final class TaskolistSyncConfig {
  const TaskolistSyncConfig._();

  /// Configura o sistema de sincronização para o app-taskolist
  /// Usa configuração avançada devido à complexidade das relações (subtasks, tags, N:N)
  ///
  /// **Conflict Resolution Strategy:**
  /// - **TaskEntity**: Last Write Wins (timestamp-based) - Simples e efetivo para tasks
  ///
  /// Futuramente será expandido para:
  /// - **TaskListEntity**: Version-based (listas são entidades críticas)
  /// - **TagEntity**: Union merge (tags N:N precisam merge inteligente)
  ///
  /// Todos os conflitos serão registrados por ConflictAuditService para auditoria.
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'taskolist',
      config: AppSyncConfig.advanced(
        appName: 'taskolist',
        syncInterval: const Duration(
          minutes: 5,
        ), // Sync moderado para dados de produtividade
        conflictStrategy:
            ConflictStrategy.timestamp, // Last Write Wins como padrão
        enableOrchestration:
            true, // Entidades têm dependências (TaskList -> Task -> Subtasks)
      ),
      entities: [
        // Task é a entidade principal
        // Usa Last Write Wins (timestamp-based) para simplicidade inicial
        // ConflictStrategy.timestamp já resolve automaticamente por updatedAt
        EntitySyncRegistration<TaskEntity>.advanced(
          entityType: TaskEntity,
          collectionName: 'tasks',
          fromMap: _taskFromFirebaseMap,
          toMap: (task) => task.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.timestamp,
          // customResolver será implementado na Fase 3 se necessário
        ),

        // TODO: Adicionar TaskListEntity (Fase 1.3 ou posterior)
        // TODO: Adicionar TagEntity com merge strategy (Fase 3)
      ],
    );

    if (kDebugMode) {
      debugPrint(
          '[TaskolistSync] UnifiedSyncManager configured with TaskEntity');
    }
  }
}

// ============================================================================
// Funções de conversão Firebase Map <-> Entity
// ============================================================================

TaskEntity _taskFromFirebaseMap(Map<String, dynamic> map) {
  return TaskEntity.fromFirebaseMap(map);
}
