import 'package:core/core.dart';

import '../features/expenses/domain/entities/expense_entity.dart';
import '../features/fuel/domain/entities/fuel_record_entity.dart';
import '../features/maintenance/domain/entities/maintenance_entity.dart';
import '../features/vehicles/domain/entities/vehicle_entity.dart';
// import 'extensions/user_entity_gasometer_extension.dart'; // Não usado mais

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

// UserEntity não é mais sincronizado via UnifiedSync
// Os dados ficam no documento users/{userId}, não em subcollection
// UserEntity _userEntityFromFirebaseMap(Map<String, dynamic> map) {
//   return UserEntityGasometerExtension.fromGasometerJson(map);
// }

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
    // FORCE RECOMPILE - version 1.0.1
    print(
      '🚀 [GasometerSync] ========== INÍCIO DA INICIALIZAÇÃO v1.0.1 ==========',
    );

    // Registrar boxes no BoxRegistry primeiro
    // IMPORTANTE: As boxes precisam estar registradas ANTES do UnifiedSyncManager
    print('🔧 [GasometerSync] Obtendo BoxRegistryService...');

    try {
      final boxRegistry = getIt<IBoxRegistryService>();
      print('✅ [GasometerSync] BoxRegistryService obtido com sucesso');

      // Registrar boxes para cada entidade
      // NOTA: Nomes das boxes locais podem ser diferentes dos nomes das collections Firebase
      final boxesToRegister = [
        'vehicles', // Hive box (Firebase: vehicles)
        'fuel', // Hive box (Firebase: fuel) - usado pelo UnifiedSync
        'fuel_supplies', // Hive box (legacy) - mantido para compatibilidade com HiveService
        'expenses', // Hive box (Firebase: expenses)
        'maintenance', // Hive box (Firebase: maintenance)
        'settings', // Hive box (não sincroniza com Firebase)
        'cache', // Hive box (Firebase: subscriptions)
      ];

      print(
        '🔧 [GasometerSync] Iniciando registro de ${boxesToRegister.length} boxes...',
      );

      // Registrar cada box sequencialmente e aguardar confirmação
      for (final boxName in boxesToRegister) {
        print('🔧 [GasometerSync] Registrando box: $boxName...');
        // ✅ IMPORTANTE: persistent: false porque as boxes JÁ foram abertas pelo HiveService
        // Isso evita erro de "tipo incompatível" (Box<VehicleModel> vs Box<dynamic>)
        final config = BoxConfiguration(
          name: boxName,
          appId: 'gasometer',
          persistent: false, // NÃO tentar abrir - já está aberta
        );
        final result = await boxRegistry.registerBox(config);

        await result.fold(
          (failure) async {
            print(
              '❌ [GasometerSync] ERRO ao registrar box "$boxName": ${failure.message}',
            );
            // Não lançar exceção, apenas logar
          },
          (_) async {
            print('✅ [GasometerSync] Box "$boxName" registrada com sucesso');
          },
        );
      }

      print(
        '✅ [GasometerSync] Registro de boxes concluído. Iniciando UnifiedSyncManager...',
      );
    } catch (e, stackTrace) {
      print('❌ [GasometerSync] ERRO FATAL ao registrar boxes: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }

    print('🔧 [GasometerSync] Iniciando UnifiedSyncManager...');
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.simple(
        appName: 'gasometer',
        syncInterval: const Duration(
          minutes: 5,
        ), // Sync frequente para dados financeiros
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
        // IMPORTANTE: Firebase collection é 'fuel', mas a box local é 'fuel_supplies'
        // O SyncFirebaseService usa collectionName para AMBOS (Firebase E Hive)
        // Solução: Usar 'fuel' para acessar o Firebase corretamente
        EntitySyncRegistration<FuelRecordEntity>.simple(
          entityType: FuelRecordEntity,
          collectionName:
              'fuel', // Firebase: fuel (SyncFirebaseService usará isso para Hive também)
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
        // NOTA: UserEntity não é sincronizado como collection separada
        // Os dados do usuário ficam no documento users/{userId} (não em subcollection)
        // Removido para evitar erro de permissão

        // Assinatura: dados de billing
        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions', // Firebase collection
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );

    print('✅ [GasometerSync] ========== INICIALIZAÇÃO COMPLETA ==========');
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
