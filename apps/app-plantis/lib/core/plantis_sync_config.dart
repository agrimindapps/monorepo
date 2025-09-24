import 'package:core/core.dart';

import '../features/plants/domain/entities/plant.dart';
import '../features/plants/domain/entities/space.dart';
import '../features/tasks/domain/entities/task.dart';
import 'data/models/comentario_model.dart';

// Funções auxiliares para contornar problemas de tipo do sistema de sync
Plant _plantFromFirebaseMap(Map<String, dynamic> map) {
  final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

  return Plant(
    id: baseFields['id'] as String,
    createdAt: baseFields['createdAt'] as DateTime?,
    updatedAt: baseFields['updatedAt'] as DateTime?,
    lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
    isDirty: baseFields['isDirty'] as bool,
    isDeleted: baseFields['isDeleted'] as bool,
    version: baseFields['version'] as int,
    userId: baseFields['userId'] as String?,
    moduleName: baseFields['moduleName'] as String?,
    name: map['name'] as String,
    species: map['species'] as String?,
    spaceId: map['space_id'] as String?,
    imageBase64: map['image_base64'] as String?,
    imageUrls:
        map['image_urls'] != null
            ? List<String>.from(map['image_urls'] as List)
            : const [],
    plantingDate:
        map['planting_date'] != null
            ? DateTime.parse(map['planting_date'] as String)
            : null,
    notes: map['notes'] as String?,
    isFavorited: map['is_favorited'] as bool? ?? false,
    config:
        null, // PlantConfig seria complexo de mapear aqui, então deixamos null
  );
}

Space _spaceFromFirebaseMap(Map<String, dynamic> map) {
  final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

  return Space(
    id: baseFields['id'] as String,
    createdAt: baseFields['createdAt'] as DateTime?,
    updatedAt: baseFields['updatedAt'] as DateTime?,
    lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
    isDirty: baseFields['isDirty'] as bool,
    isDeleted: baseFields['isDeleted'] as bool,
    version: baseFields['version'] as int,
    userId: baseFields['userId'] as String?,
    moduleName: baseFields['moduleName'] as String?,
    name: map['name'] as String,
    description: map['description'] as String?,
    lightCondition: map['light_condition'] as String?,
    humidity: (map['humidity'] as num?)?.toDouble(),
    averageTemperature: (map['average_temperature'] as num?)?.toDouble(),
  );
}

/// Configuração de sincronização específica do Plantis
/// Apps simples com poucas entidades e sync básico
abstract final class PlantisSyncConfig {
  /// Configura o sistema de sincronização para o Plantis
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.simple(
        appName: 'plantis',
        syncInterval: const Duration(minutes: 10), // Sync menos frequente
        conflictStrategy: ConflictStrategy.timestamp, // Simples timestamp
      ),
      entities: [
        // Entidade principal - Plantas (usando a entidade real do app)
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: _plantFromFirebaseMap,
          toMap: (plant) => plant.toFirebaseMap(),
        ),

        // Espaços das plantas
        EntitySyncRegistration<Space>.simple(
          entityType: Space,
          collectionName: 'spaces',
          fromMap: _spaceFromFirebaseMap,
          toMap: (space) => space.toFirebaseMap(),
        ),

        // Tasks relacionadas às plantas (usando a entidade real do app)
        EntitySyncRegistration<Task>.simple(
          entityType: Task,
          collectionName: 'tasks',
          fromMap: Task.fromFirebaseMap,
          toMap: (task) => task.toFirebaseMap(),
        ),

        // Comentários das plantas
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (comentario) => comentario.toFirebaseMap(),
        ),

        // Usuários (profile compartilhado entre apps)
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: UserEntity.fromFirebaseMap,
          toMap: (user) => user.toFirebaseMap(),
        ),

        // Assinaturas (subscription compartilhada entre apps)
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração para desenvolvimento
  static Future<void> configureDevelopment() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.development(
        appName: 'plantis',
        syncInterval: const Duration(minutes: 2),
      ),
      entities: [
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'dev_plants',
          fromMap: _plantFromFirebaseMap,
          toMap: (plant) => plant.toFirebaseMap(),
        ),

        // Espaços das plantas (desenvolvimento)
        EntitySyncRegistration<Space>.simple(
          entityType: Space,
          collectionName: 'dev_spaces',
          fromMap: _spaceFromFirebaseMap,
          toMap: (space) => space.toFirebaseMap(),
        ),

        // Tasks relacionadas às plantas (desenvolvimento)
        EntitySyncRegistration<Task>.simple(
          entityType: Task,
          collectionName: 'dev_tasks',
          fromMap: Task.fromFirebaseMap,
          toMap: (task) => task.toFirebaseMap(),
        ),

        // Comentários das plantas (desenvolvimento)
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'dev_comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (comentario) => comentario.toFirebaseMap(),
        ),

        // Usuários (desenvolvimento)
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'dev_users',
          fromMap: UserEntity.fromFirebaseMap,
          toMap: (user) => user.toFirebaseMap(),
        ),

        // Assinaturas (desenvolvimento)
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'dev_subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração offline-first para áreas rurais com internet limitada
  static Future<void> configureOfflineFirst() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.offlineFirst(
        appName: 'plantis',
        syncInterval: const Duration(hours: 6), // Sync muito esporádico
      ),
      entities: [
        EntitySyncRegistration<Plant>(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: _plantFromFirebaseMap,
          toMap: (Plant plant) => plant.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 100, // Lotes maiores quando sync
        ),

        // Espaços das plantas (offline-first)
        EntitySyncRegistration<Space>(
          entityType: Space,
          collectionName: 'spaces',
          fromMap: _spaceFromFirebaseMap,
          toMap: (Space space) => space.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 50, // Lotes medianos para espaços
        ),

        // Tasks relacionadas às plantas (offline-first)
        EntitySyncRegistration<Task>(
          entityType: Task,
          collectionName: 'tasks',
          fromMap: Task.fromFirebaseMap,
          toMap: (Task task) => task.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 50, // Lotes menores para tasks
        ),

        // Comentários das plantas (offline-first)
        EntitySyncRegistration<ComentarioModel>(
          entityType: ComentarioModel,
          collectionName: 'comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (ComentarioModel comentario) => comentario.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 50, // Lotes menores para comentários
        ),

        // Usuários (offline-first)
        EntitySyncRegistration<UserEntity>(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: UserEntity.fromFirebaseMap,
          toMap: (UserEntity user) => user.toFirebaseMap(),
          conflictStrategy:
              ConflictStrategy.remoteWins, // Remote vence para usuários
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(
            hours: 24,
          ), // Sync mais esporádico para usuários
          batchSize: 10, // Lotes pequenos para usuários
        ),

        // Assinaturas (offline-first)
        EntitySyncRegistration<SubscriptionEntity>(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap:
              (SubscriptionEntity subscription) => subscription.toFirebaseMap(),
          conflictStrategy:
              ConflictStrategy
                  .remoteWins, // Remote sempre vence para assinaturas
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(
            hours: 24,
          ), // Sync mais esporádico para assinaturas
          batchSize: 5, // Lotes muito pequenos para assinaturas
        ),
      ],
    );
  }
}
