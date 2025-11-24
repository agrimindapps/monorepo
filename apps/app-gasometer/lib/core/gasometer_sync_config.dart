import 'package:core/core.dart' hide OfflineData;
import 'package:core/src/domain/repositories/i_local_storage_repository.dart' show OfflineData;

import '../features/sync/domain/services/gasometer_sync_service.dart';

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
///
/// ## 🔥 Firestore Indices Required
///
/// This app uses Firestore composite indices for pull-based synchronization.
/// The sync system fetches remote changes using timestamp-based queries:
///
/// ```dart
/// // Query pattern used by DriftSyncAdapterBase.pullRemoteChanges()
/// query.where('updatedAt', isGreaterThan: lastSyncTime).limit(500)
/// ```
///
/// **Required Indices:**
/// - vehicles: updatedAt ASC
/// - fuel_supplies: updatedAt ASC
/// - maintenances: updatedAt ASC
/// - expenses: updatedAt ASC
/// - odometer_readings: updatedAt ASC
///
/// **Deployment:**
/// 1. CLI: `./deploy-firestore-indexes.sh my-project-id`
/// 2. Manual: See FIRESTORE_INDICES.md
/// 3. Console: https://console.firebase.google.com/project/{PROJECT}/firestore/indexes
///
/// **Without these indices:**
/// ❌ Firestore will reject pull queries with: "The query requires an index"
/// ❌ Sync will fail and app will crash on pull operations
/// ❌ Users cannot sync offline changes
///
/// **Status:** CRITICAL for production. Must be deployed before app launch.
///
/// See: `FIRESTORE_INDICES.md` for complete documentation
abstract final class GasometerSyncConfig {
  const GasometerSyncConfig._();

  /// Configura o sistema de sincronização para o Gasometer
  /// Configuração unificada com sync frequente para dados financeiros críticos
  /// Firebase Firestore collections: vehicles, fuel, expenses, maintenance, users, subscriptions
  static Future<void> initialize(GasometerSyncService gasometerSyncService) async {
    // FORCE RECOMPILE - version 1.0.1
    print(
      '🚀 [GasometerSync] ========== INÍCIO DA INICIALIZAÇÃO v1.0.1 ==========',
    );

    // Registrar boxes no BoxRegistry primeiro
    // IMPORTANTE: As boxes precisam estar registradas ANTES do UnifiedSyncManager
    print('🔧 [GasometerSync] Obtendo BoxRegistryService...');

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
      localStorage: _NoOpLocalStorageRepository(),
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
}

class _NoOpLocalStorageRepository implements ILocalStorageRepository {
  @override
  Future<Either<Failure, void>> addToList<T>({required String key, required T item, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> clear({String? box}) async => const Right(null);

  @override
  Future<Either<Failure, bool>> contains({required String key, String? box}) async => const Right(false);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async => const Right({});

  @override
  Future<Either<Failure, T?>> get<T>({required String key, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async => const Right([]);

  @override
  Future<Either<Failure, List<T>>> getList<T>({required String key, String? box}) async => const Right([]);

  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({required String key}) async => const Right(null);

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async => const Right([]);

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({required String key, T? defaultValue}) async => Right(defaultValue);

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async => const Right([]);

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({required String key, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> initialize() async => const Right(null);

  @override
  Future<Either<Failure, int>> length({String? box}) async => const Right(0);

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async => const Right(null);

  @override
  Future<Either<Failure, void>> remove({required String key, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFromList<T>({required String key, required T item, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> save<T>({required String key, required T data, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveList<T>({required String key, required List<T> data, String? box}) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({required String key, required T data, DateTime? lastSync}) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveUserSetting({required String key, required dynamic value}) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({required String key, required T data, required Duration ttl, String? box}) async => const Right(null);
}
