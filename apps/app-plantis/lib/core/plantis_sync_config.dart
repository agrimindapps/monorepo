import 'package:core/core.dart';
import '../core/data/models/comentario_model.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/tasks/domain/entities/task.dart' as task_entity;

// Funções de conversão para Plant
Plant _plantFromFirebaseMap(Map<String, dynamic> map) {
  // Usando chamada direta ao construtor estático
  return Plant.fromFirebaseMap(map);
}

// Funções de conversão para ComentarioModel
ComentarioModel _comentarioFromFirebaseMap(Map<String, dynamic> map) {
  return ComentarioModel.fromFirebaseMap(map);
}

// Funções de conversão para Task
task_entity.Task _taskFromFirebaseMap(Map<String, dynamic> map) {
  return task_entity.Task.fromFirebaseMap(map);
}

/// Configuração de sincronização específica do Plantis
/// Controle de plantas com sync otimizado para dados agrícolas
abstract final class PlantisSyncConfig {
  const PlantisSyncConfig._();

  /// Configura o sistema de sincronização para o Plantis
  /// Configuração específica para dados de plantas com sync moderado
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.simple(
        appName: 'plantis',
        syncInterval: const Duration(
          minutes: 15,
        ), // Sync moderado para dados agrícolas
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      entities: [
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: _plantFromFirebaseMap,
          toMap: (plant) => plant.toFirebaseMap(),
        ),
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'comments',
          fromMap: _comentarioFromFirebaseMap,
          toMap: (comment) => comment.toFirebaseMap(),
        ),
        EntitySyncRegistration<task_entity.Task>.simple(
          entityType: task_entity.Task,
          collectionName: 'tasks',
          fromMap: _taskFromFirebaseMap,
          toMap: (task) => task.toFirebaseMap(),
        ),
      ],
    );
  }
}
