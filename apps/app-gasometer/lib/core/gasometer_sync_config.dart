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
/// UNIFIED ENVIRONMENT: Uma única configuração para dev e prod
abstract final class GasometerSyncConfig {
  const GasometerSyncConfig._();

  /// Configura o sistema de sincronização para o Gasometer
  /// Configuração unificada com sync frequente para dados financeiros críticos
  /// Firebase Firestore collections: vehicles, fuel, expenses, maintenance, users, subscriptions
  /// Hive boxes: vehicles, fuel_supplies, expenses, maintenance (sem prefixos)
  static Future<void> initialize() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.simple(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 5), // Sync frequente para dados financeiros
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      entities: [
        // Veículos: dados críticos, sync frequente
        EntitySyncRegistration<VehicleEntity>.simple(
          entityType: VehicleEntity,
          collectionName: 'vehicles', // Firebase collection
          fromMap: _vehicleFromFirebaseMap,
          toMap: (vehicle) => vehicle.toFirebaseMap(),
        ),
        // Combustível: dados financeiros, resolução manual para precisão
        EntitySyncRegistration<FuelRecordEntity>.simple(
          entityType: FuelRecordEntity,
          collectionName: 'fuel', // Firebase collection
          fromMap: _fuelRecordFromFirebaseMap,
          toMap: (fuelRecord) => fuelRecord.toFirebaseMap(),
        ),
        // Despesas: dados monetários, resolução manual
        EntitySyncRegistration<ExpenseEntity>.simple(
          entityType: ExpenseEntity,
          collectionName: 'expenses', // Firebase collection
          fromMap: _expenseFromFirebaseMap,
          toMap: (expense) => expense.toFirebaseMap(),
        ),
        // Manutenção: dados críticos do veículo
        EntitySyncRegistration<MaintenanceEntity>.simple(
          entityType: MaintenanceEntity,
          collectionName: 'maintenance', // Firebase collection
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (maintenance) => maintenance.toFirebaseMap(),
        ),
        // Usuário: sincronização por login
        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'users', // Firebase collection
          fromMap: _userEntityFromFirebaseMap,
          toMap: (user) => user.toFirebaseMap(),
        ),
        // Assinatura: dados de billing
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions', // Firebase collection
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Deprecated: Use initialize() instead
  /// Kept for backward compatibility during transition
  @Deprecated('Use GasometerSyncConfig.initialize() instead')
  static Future<void> configure() async {
    await initialize();
  }

  /// Deprecated: Use initialize() instead
  /// Single environment - development mode is no longer separated
  @Deprecated('Use GasometerSyncConfig.initialize() instead')
  static Future<void> configureDevelopment() async {
    await initialize();
  }

  /// Deprecated: Use initialize() instead
  /// All sync strategies are now unified in single initialize() method
  @Deprecated('Use GasometerSyncConfig.initialize() instead')
  static Future<void> configureOfflineFirst() async {
    await initialize();
  }
}
