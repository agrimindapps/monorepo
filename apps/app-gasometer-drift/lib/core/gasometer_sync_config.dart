import 'package:core/core.dart';

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

    try {
      final boxRegistry = getIt<IBoxRegistryService>();
      print('✅ [GasometerSync] BoxRegistryService obtido com sucesso');

      // Registrar boxes para cada entidade
      // NOTA: Nomes das boxes locais podem ser diferentes dos nomes das collections Firebase
      final boxesToRegister = [
        // Removido: vehicles - migrado para Drift
        // Removido: fuel - migrado para Drift
        // Removido: fuel_supplies - não usado
        // Removido: expenses - migrado para Drift
        // Removido: maintenance - migrado para Drift
        // Removido: odometer - migrado para Drift
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
        // NOTA: Veículos, combustível, despesas, manutenção e odômetro foram migrados para Drift
        // Apenas subscriptions permanece usando Hive para cache

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
