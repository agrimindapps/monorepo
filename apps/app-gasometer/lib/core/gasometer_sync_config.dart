import 'package:core/core.dart';

import 'services/gasometer_sync_service.dart';

// import 'extensions/user_entity_gasometer_extension.dart'; // Não usado mais

// REMOVIDO: Funções de conversão migradas para Drift
// VehicleEntity _vehicleFromFirebaseMap(Map<String, dynamic> map) {
//   return VehicleEntity.fromFirebaseMap(map);
// }

// MaintenanceEntity _maintenanceFromFirebaseMap(Map<String, dynamic> map) {
//   return MaintenanceEntity.fromFirebaseMap(map);
// }

// FuelRecordEntity _fuelRecordFromFirebaseMap(Map<String, dynamic> map) {
//   return FuelRecordEntity.fromFirebaseMap(map);
// }

// ExpenseEntity _expenseFromFirebaseMap(Map<String, dynamic> map) {
//   return ExpenseEntity.fromFirebaseMap(map);
// }

// OdometerEntity _odometerFromFirebaseMap(Map<String, dynamic> map) {
//   return OdometerEntity.fromFirebaseMap(map);
// }

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

    // Hive boxes removed - all data now in Drift
    // BoxRegistry no longer needed for gasometer
    print('🔧 [GasometerSync] Drift database handles all local storage');

    print('🔧 [GasometerSync] Iniciando UnifiedSyncManager...');

    // 🔥 CRITICAL: Inicializar BackgroundSyncManager PRIMEIRO
    print('🔧 [GasometerSync] Inicializando BackgroundSyncManager...');
    final bgSyncInitResult = await BackgroundSyncManager.instance.initialize(
      minSyncInterval: const Duration(minutes: 3),
      maxQueueSize: 50,
    );

    bgSyncInitResult.fold(
      (failure) {
        print('❌ [GasometerSync] Erro ao inicializar BackgroundSyncManager: ${failure.message}');
        throw Exception('Failed to initialize BackgroundSyncManager: ${failure.message}');
      },
      (_) {
        print('✅ [GasometerSync] BackgroundSyncManager inicializado com sucesso');
      },
    );

    // Obter GasometerSyncService do DI
    print('🔧 [GasometerSync] Obtendo GasometerSyncService do DI...');
    final gasometerSyncService = GetIt.I<GasometerSyncService>();

    // Inicializar o GasometerSyncService
    print('🔧 [GasometerSync] Inicializando GasometerSyncService...');
    await gasometerSyncService.initialize();

    // Inicializar UnifiedSyncManager para registrar o app
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.simple(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 5),
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      entities: [
        // NOTA: Drift entities são gerenciadas pelo GasometerSyncService
        // Não precisamos registrar entidades individuais aqui
      ],
    );

    // 🔥 IMPORTANTE: Registrar o GasometerSyncService no BackgroundSyncManager
    // Isso permite que AutoSyncService → UnifiedSyncManager → BackgroundSync → GasometerSyncService
    print(
      '🔧 [GasometerSync] Registrando GasometerSyncService no BackgroundSyncManager...',
    );
    BackgroundSyncManager.instance.registerService(
      gasometerSyncService,
      config: const BackgroundSyncConfig(
        syncInterval: Duration(minutes: 3),
        enabled: true,
      ),
    );
    print('✅ [GasometerSync] GasometerSyncService registrado com sucesso');

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
