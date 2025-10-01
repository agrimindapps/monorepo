import 'package:core/core.dart' hide Task;

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
        map['config'] != null
            ? PlantConfig(
              wateringIntervalDays:
                  map['config']['watering_interval_days'] as int?,
              fertilizingIntervalDays:
                  map['config']['fertilizing_interval_days'] as int?,
              pruningIntervalDays:
                  map['config']['pruning_interval_days'] as int?,
              sunlightCheckIntervalDays:
                  map['config']['sunlight_check_interval_days'] as int?,
              pestInspectionIntervalDays:
                  map['config']['pest_inspection_interval_days'] as int?,
              replantingIntervalDays:
                  map['config']['replanting_interval_days'] as int?,
              lightRequirement: map['config']['light_requirement'] as String?,
              waterAmount: map['config']['water_amount'] as String?,
              soilType: map['config']['soil_type'] as String?,
              idealTemperature:
                  (map['config']['ideal_temperature'] as num?)?.toDouble(),
              idealHumidity:
                  (map['config']['ideal_humidity'] as num?)?.toDouble(),
              enableWateringCare:
                  map['config']['enable_watering_care'] as bool?,
              lastWateringDate:
                  map['config']['last_watering_date'] != null
                      ? DateTime.parse(
                        map['config']['last_watering_date'] as String,
                      )
                      : null,
              enableFertilizerCare:
                  map['config']['enable_fertilizer_care'] as bool?,
              lastFertilizerDate:
                  map['config']['last_fertilizer_date'] != null
                      ? DateTime.parse(
                        map['config']['last_fertilizer_date'] as String,
                      )
                      : null,
            )
            : null,
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
        syncInterval: const Duration(minutes: 15), // OPTIMIZED: Sync otimizado (bateria)
        conflictStrategy: ConflictStrategy.timestamp, // Simples timestamp
      ),
      entities: [
        // Entidade principal - Plantas (usando a entidade real do app)
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: _plantFromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Espaços das plantas
        EntitySyncRegistration<Space>.simple(
          entityType: Space,
          collectionName: 'spaces',
          fromMap: _spaceFromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Tasks relacionadas às plantas (usando a entidade real do app)
        EntitySyncRegistration<Task>.simple(
          entityType: Task,
          collectionName: 'tasks',
          fromMap: Task.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Comentários das plantas
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Usuários (profile compartilhado entre apps)
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: UserEntity.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Assinaturas (subscription compartilhada entre apps)
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
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
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Espaços das plantas (desenvolvimento)
        EntitySyncRegistration<Space>.simple(
          entityType: Space,
          collectionName: 'dev_spaces',
          fromMap: _spaceFromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Tasks relacionadas às plantas (desenvolvimento)
        EntitySyncRegistration<Task>.simple(
          entityType: Task,
          collectionName: 'dev_tasks',
          fromMap: Task.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Comentários das plantas (desenvolvimento)
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'dev_comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Usuários (desenvolvimento)
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'dev_users',
          fromMap: UserEntity.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
        ),

        // Assinaturas (desenvolvimento)
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'dev_subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (entity) => entity.toFirebaseMap(),
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
          toMap: (entity) => (entity as Plant).toFirebaseMap(),
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
          toMap: (entity) => (entity as Space).toFirebaseMap(),
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
          toMap: (entity) => (entity as Task).toFirebaseMap(),
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
          toMap: (entity) => (entity as ComentarioModel).toFirebaseMap(),
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
          toMap: (entity) => (entity as UserEntity).toFirebaseMap(),
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
          toMap: (entity) => (entity as SubscriptionEntity).toFirebaseMap(),
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
