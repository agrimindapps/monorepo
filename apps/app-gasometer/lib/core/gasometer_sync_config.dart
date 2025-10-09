import 'package:core/core.dart';

import '../features/expenses/domain/entities/expense_entity.dart';
import '../features/fuel/domain/entities/fuel_record_entity.dart';
import '../features/maintenance/domain/entities/maintenance_entity.dart';
import '../features/vehicles/domain/entities/vehicle_entity.dart';
import 'extensions/user_entity_gasometer_extension.dart';
VehicleEntity _vehicleFromFirebaseMap(Map<String, dynamic> map) {
  return VehicleEntity.fromFirebaseMap(map);
}

MaintenanceEntity _maintenanceFromFirebaseMap(Map<String, dynamic> map) {
  return MaintenanceEntity.fromFirebaseMap(map);
}

FuelRecordEntity _fuelRecordFromFirebaseMap(Map<String, dynamic> map) {
  return FuelRecordEntity.fromFirebaseMap(map);
}

ExpenseEntity _expenseFromFirebaseMap(Map<String, dynamic> map) {
  return ExpenseEntity.fromFirebaseMap(map);
}

UserEntity _userEntityFromFirebaseMap(Map<String, dynamic> map) {
  return UserEntityGasometerExtension.fromGasometerJson(map);
}

/// Configuração de sincronização específica do Gasometer
/// Controle veicular com veículos e manutenções
abstract final class GasometerSyncConfig {
  const GasometerSyncConfig._();

  /// Configura o sistema de sincronização para o Gasometer
  /// Configuração específica para dados financeiros com sync mais frequente
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.simple(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 5), // Sync frequente para dados financeiros
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      entities: [
        EntitySyncRegistration<VehicleEntity>.simple(
          entityType: VehicleEntity,
          collectionName: 'vehicles',
          fromMap: _vehicleFromFirebaseMap,
          toMap: (vehicle) => vehicle.toFirebaseMap(),
        ),
        EntitySyncRegistration<FuelRecordEntity>.simple(
          entityType: FuelRecordEntity,
          collectionName: 'fuel',
          fromMap: _fuelRecordFromFirebaseMap,
          toMap: (fuelRecord) => fuelRecord.toFirebaseMap(),
        ),
        EntitySyncRegistration<ExpenseEntity>.simple(
          entityType: ExpenseEntity,
          collectionName: 'expenses',
          fromMap: _expenseFromFirebaseMap,
          toMap: (expense) => expense.toFirebaseMap(),
        ),
        EntitySyncRegistration<MaintenanceEntity>.simple(
          entityType: MaintenanceEntity,
          collectionName: 'maintenance',
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (maintenance) => maintenance.toFirebaseMap(),
        ),
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: _userEntityFromFirebaseMap,
          toMap: (user) => user.toFirebaseMap(),
        ),
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração para desenvolvimento com sync em tempo real
  static Future<void> configureDevelopment() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.development(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 2), // Sync mais frequente para desenvolvimento
      ),
      entities: [
        EntitySyncRegistration<VehicleEntity>.simple(
          entityType: VehicleEntity,
          collectionName: 'dev_vehicles',
          fromMap: _vehicleFromFirebaseMap,
          toMap: (vehicle) => vehicle.toFirebaseMap(),
        ),

        EntitySyncRegistration<FuelRecordEntity>.simple(
          entityType: FuelRecordEntity,
          collectionName: 'dev_fuel',
          fromMap: _fuelRecordFromFirebaseMap,
          toMap: (fuelRecord) => fuelRecord.toFirebaseMap(),
        ),

        EntitySyncRegistration<ExpenseEntity>.simple(
          entityType: ExpenseEntity,
          collectionName: 'dev_expenses',
          fromMap: _expenseFromFirebaseMap,
          toMap: (expense) => expense.toFirebaseMap(),
        ),

        EntitySyncRegistration<MaintenanceEntity>.simple(
          entityType: MaintenanceEntity,
          collectionName: 'dev_maintenance',
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
  /// Otimizada para dados financeiros com batch sizes menores
  static Future<void> configureOfflineFirst() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.offlineFirst(
        appName: 'gasometer',
        syncInterval: const Duration(hours: 4), // Sync esporádico para economizar bateria
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
          batchSize: 30, // Menor batch para dados críticos
        ),
        EntitySyncRegistration<FuelRecordEntity>(
          entityType: FuelRecordEntity,
          collectionName: 'fuel',
          fromMap: _fuelRecordFromFirebaseMap,
          toMap: (FuelRecordEntity fuelRecord) => fuelRecord.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.manual, // Resolução manual para dados financeiros
          enableRealtime: false,
          syncInterval: const Duration(hours: 6), // Sync mais frequente para dados financeiros
          batchSize: 15, // Batch pequeno para dados financeiros críticos
        ),
        EntitySyncRegistration<ExpenseEntity>(
          entityType: ExpenseEntity,
          collectionName: 'expenses',
          fromMap: _expenseFromFirebaseMap,
          toMap: (ExpenseEntity expense) => expense.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.manual, // Resolução manual para dados monetários
          enableRealtime: false,
          syncInterval: const Duration(hours: 6), // Sync mais frequente para dados financeiros
          batchSize: 15, // Batch pequeno para garantir precisão
        ),

        EntitySyncRegistration<MaintenanceEntity>(
          entityType: MaintenanceEntity,
          collectionName: 'maintenance',
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (MaintenanceEntity maintenance) => maintenance.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 8),
          batchSize: 25, // Batch médio para manutenções
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
