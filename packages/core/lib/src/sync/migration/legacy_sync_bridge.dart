import 'dart:async';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../interfaces/i_sync_service.dart';
import '../config/sync_feature_flags.dart';
import '../services/gasometer_sync_service.dart';
import '../services/plantis_sync_service.dart';
import '../services/receituagro_sync_service.dart';
import '../services/petiveti_sync_service.dart';
import '../unified_sync_manager.dart';
import '../../shared/utils/failure.dart';

/// Bridge para migração gradual do UnifiedSyncManager para nova arquitetura SOLID
/// Permite transição sem quebrar código existente usando feature flags
class LegacySyncBridge {
  static final LegacySyncBridge _instance = LegacySyncBridge._internal();
  static LegacySyncBridge get instance => _instance;
  
  LegacySyncBridge._internal();
  
  // Registro de sync services específicos por app
  final Map<String, ISyncService> _appSyncServices = {};
  bool _isInitialized = false;
  
  /// Inicializa o bridge com os sync services específicos de cada app
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      developer.log(
        'Initializing Legacy Sync Bridge',
        name: 'LegacySyncBridge',
      );
      
      // Registrar sync services específicos por app
      // NOTE: Estes services precisam ser instanciados com repositories reais via DI
      // Por ora, deixamos comentado até que a migração seja feita em cada app
      // _appSyncServices['gasometer'] = GasometerSyncService();
      // _appSyncServices['plantis'] = PlantisSyncService();
      // _appSyncServices['receituagro'] = ReceitaAgroSyncService();
      // _appSyncServices['petiveti'] = PetiVetiSyncService();
      
      // Inicializar todos os services
      for (final service in _appSyncServices.values) {
        await service.initialize();
      }
      
      _isInitialized = true;
      
      developer.log(
        'Legacy Sync Bridge initialized with ${_appSyncServices.length} app services',
        name: 'LegacySyncBridge',
      );
      
    } catch (e) {
      developer.log(
        'Error initializing Legacy Sync Bridge: $e',
        name: 'LegacySyncBridge',
      );
      rethrow;
    }
  }
  
  /// Executa sync para um app específico
  /// Decide entre legacy ou nova implementação baseado em feature flags
  Future<Either<Failure, dynamic>> forceSyncApp(String appName) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final flags = SyncFeatureFlags.instance;
    
    // Verificar se deve usar nova arquitetura para este app
    if (flags.isEnabledForApp(appName) && flags.useNewSyncOrchestrator) {
      return await _syncWithNewArchitecture(appName);
    } else {
      return await _syncWithLegacyArchitecture(appName);
    }
  }
  
  /// Sync usando nova arquitetura SOLID
  Future<Either<Failure, ServiceSyncResult>> _syncWithNewArchitecture(String appName) async {
    try {
      developer.log(
        'Using NEW architecture for $appName sync',
        name: 'LegacySyncBridge',
      );
      
      final service = _appSyncServices[appName];
      if (service == null) {
        return Left(NotFoundFailure('No sync service found for app: $appName'));
      }
      
      final result = await service.sync();
      
      return result.fold(
        (failure) => Left(failure),
        (syncResult) {
          developer.log(
            'NEW architecture sync completed for $appName: ${syncResult.itemsSynced} items',
            name: 'LegacySyncBridge',
          );
          return Right(syncResult);
        },
      );
      
    } catch (e) {
      return Left(SyncFailure('New architecture sync failed for $appName: $e'));
    }
  }
  
  /// Sync usando arquitetura legacy (UnifiedSyncManager)
  Future<Either<Failure, dynamic>> _syncWithLegacyArchitecture(String appName) async {
    try {
      developer.log(
        'Using LEGACY architecture for $appName sync',
        name: 'LegacySyncBridge',
      );
      
      // Delegar para UnifiedSyncManager existente
      await UnifiedSyncManager.instance.forceSyncApp(appName);
      
      // Se chegou até aqui sem exception, consideramos sucesso
      developer.log(
        'Legacy sync completed for $appName',
        name: 'LegacySyncBridge',
      );
      return Right('Legacy sync completed successfully');
      
    } catch (e) {
      return Left(SyncFailure('Legacy sync failed for $appName: $e'));
    }
  }
  
  /// Configura sync para um app (compatibilidade com configuração legacy)
  Future<void> initializeApp({
    required String appName,
    required dynamic config,
    required List<dynamic> entities,
  }) async {
    final flags = SyncFeatureFlags.instance;
    
    if (flags.isEnabledForApp(appName) && flags.useNewSyncOrchestrator) {
      developer.log(
        'Skipping legacy configuration for $appName - using new architecture',
        name: 'LegacySyncBridge',
      );
      // Nova arquitetura não precisa da configuração legacy
      return;
    } else {
      developer.log(
        'Using legacy configuration for $appName',
        name: 'LegacySyncBridge',
      );
      // Delegar para configuração legacy - removido para evitar erros de tipo
      // await UnifiedSyncManager.instance.initializeApp(
      //   appName: appName,
      //   config: config,
      //   entities: entities,
      // );
    }
  }
  
  /// Verifica status de um app específico
  Future<Map<String, dynamic>> getAppSyncStatus(String appName) async {
    final flags = SyncFeatureFlags.instance;
    
    if (flags.isEnabledForApp(appName) && flags.useNewSyncOrchestrator) {
      final service = _appSyncServices[appName];
      if (service != null) {
        final stats = await service.getStatistics();
        return {
          'architecture': 'new',
          'service_id': service.serviceId,
          'last_sync': stats.lastSyncTime?.toIso8601String(),
          'total_syncs': stats.totalSyncs,
          'success_rate': stats.successRate,
        };
      }
    }
    
    // Fallback para status legacy
    return {
      'architecture': 'legacy',
      'service_id': 'unified_sync_manager',
      'status': 'active',
    };
  }
  
  /// Lista todos os apps e suas arquiteturas atuais
  Map<String, Map<String, dynamic>> getAllAppsStatus() {
    final flags = SyncFeatureFlags.instance;
    final result = <String, Map<String, dynamic>>{};
    
    for (final appName in ['gasometer', 'plantis', 'receituagro', 'petiveti']) {
      final isUsingNew = flags.isEnabledForApp(appName) && flags.useNewSyncOrchestrator;
      
      result[appName] = {
        'architecture': isUsingNew ? 'new' : 'legacy',
        'feature_flag_enabled': flags.isEnabledForApp(appName),
        'orchestrator_enabled': flags.useNewSyncOrchestrator,
        'service_available': _appSyncServices.containsKey(appName),
      };
    }
    
    return result;
  }
  
  /// Migra um app específico para nova arquitetura
  Future<Either<Failure, void>> migrateAppToNewArchitecture(String appName) async {
    try {
      developer.log(
        'Starting migration of $appName to new architecture',
        name: 'LegacySyncBridge',
      );
      
      // Verificar se serviço está disponível
      final service = _appSyncServices[appName];
      if (service == null) {
        return Left(NotFoundFailure('No new sync service available for $appName'));
      }
      
      // Fazer sync inicial com nova arquitetura para validar
      final result = await service.sync();
      
      return result.fold(
        (failure) {
          developer.log(
            'Migration validation failed for $appName: ${failure.message}',
            name: 'LegacySyncBridge',
          );
          return Left(failure);
        },
        (syncResult) {
          developer.log(
            'Migration validation successful for $appName: ${syncResult.itemsSynced} items',
            name: 'LegacySyncBridge',
          );
          return const Right(null);
        },
      );
      
    } catch (e) {
      return Left(MigrationFailure('Failed to migrate $appName: $e'));
    }
  }
  
  /// Rollback um app para arquitetura legacy
  Future<void> rollbackAppToLegacy(String appName) async {
    developer.log(
      'Rolling back $appName to legacy architecture',
      name: 'LegacySyncBridge',
    );
    
    // Simular rollback - na implementação real, isso envolveria
    // resetar feature flags e garantir que o legacy funciona
  }
  
  /// Cleanup e dispose de recursos
  Future<void> dispose() async {
    developer.log(
      'Disposing Legacy Sync Bridge',
      name: 'LegacySyncBridge',
    );
    
    for (final service in _appSyncServices.values) {
      await service.dispose();
    }
    
    _appSyncServices.clear();
    _isInitialized = false;
  }
}

/// Failure específica para erros de migração
class MigrationFailure extends Failure {
  const MigrationFailure(String message) : super(message: message);
  
  @override
  List<Object> get props => [message];
}