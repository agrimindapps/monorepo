import 'package:core/core.dart';

import '../features/maintenance/domain/entities/maintenance_entity.dart';
import '../features/vehicles/domain/entities/vehicle_entity.dart';
import 'extensions/user_entity_gasometer_extension.dart';

// Funções auxiliares para contornar problema do analyzer
VehicleEntity _vehicleFromFirebaseMap(Map<String, dynamic> map) {
  return VehicleEntity.fromFirebaseMap(map);
}

MaintenanceEntity _maintenanceFromFirebaseMap(Map<String, dynamic> map) {
  return MaintenanceEntity.fromFirebaseMap(map);
}

UserEntity _userEntityFromFirebaseMap(Map<String, dynamic> map) {
  return UserEntityGasometerExtension.fromGasometerJson(map);
}

/// Configuração de sincronização específica do Gasometer
/// Controle veicular com veículos e manutenções
abstract final class GasometerSyncConfig {
  const GasometerSyncConfig._();

  /// Configura o sistema de sincronização para o Gasometer
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.simple(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 5), // Sync regular
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      entities: [
        // Veículos - Entidade principal do app
        EntitySyncRegistration<VehicleEntity>.simple(
          entityType: VehicleEntity,
          collectionName: 'vehicles',
          fromMap: _vehicleFromFirebaseMap,
          toMap: (vehicle) => vehicle.toFirebaseMap(),
        ),
        
        // Manutenções - Registros de manutenção dos veículos
        EntitySyncRegistration<MaintenanceEntity>.simple(
          entityType: MaintenanceEntity,
          collectionName: 'maintenance_records',
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (maintenance) => maintenance.toFirebaseMap(),
        ),

        // Usuários (profile compartilhado entre apps)
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: _userEntityFromFirebaseMap,
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
      appName: 'gasometer',
      config: AppSyncConfig.development(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 2),
      ),
      entities: [
        EntitySyncRegistration<VehicleEntity>.simple(
          entityType: VehicleEntity,
          collectionName: 'dev_vehicles',
          fromMap: _vehicleFromFirebaseMap,
          toMap: (vehicle) => vehicle.toFirebaseMap(),
        ),

        EntitySyncRegistration<MaintenanceEntity>.simple(
          entityType: MaintenanceEntity,
          collectionName: 'dev_maintenance_records',
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (maintenance) => maintenance.toFirebaseMap(),
        ),

        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'dev_users',
          fromMap: _userEntityFromFirebaseMap,
          toMap: (user) => user.toFirebaseMap(),
        ),

        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'dev_subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração offline-first para áreas com internet limitada
  static Future<void> configureOfflineFirst() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.offlineFirst(
        appName: 'gasometer',
        syncInterval: const Duration(hours: 4), // Sync esporádico
      ),
      entities: [
        EntitySyncRegistration<VehicleEntity>(
          entityType: VehicleEntity,
          collectionName: 'vehicles',
          fromMap: _vehicleFromFirebaseMap,
          toMap: (VehicleEntity vehicle) => vehicle.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 8),
          batchSize: 50,
        ),

        EntitySyncRegistration<MaintenanceEntity>(
          entityType: MaintenanceEntity,
          collectionName: 'maintenance_records',
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (MaintenanceEntity maintenance) => maintenance.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 8),
          batchSize: 50,
        ),

        EntitySyncRegistration<UserEntity>(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: _userEntityFromFirebaseMap,
          toMap: (UserEntity user) => user.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.remoteWins, // Remote vence para usuários
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 24),
          batchSize: 10,
        ),

        EntitySyncRegistration<SubscriptionEntity>(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (SubscriptionEntity subscription) => subscription.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.remoteWins, // Remote sempre vence para assinaturas
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 24),
          batchSize: 5,
        ),
      ],
    );
  }
}