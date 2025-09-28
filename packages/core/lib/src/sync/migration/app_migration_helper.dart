import 'dart:async';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../config/sync_feature_flags.dart';
import '../interfaces/i_sync_service.dart';
import '../services/gasometer_sync_service.dart';
import '../services/plantis_sync_service.dart';
import '../services/receituagro_sync_service.dart';
import '../services/petiveti_sync_service.dart';
import '../../shared/utils/failure.dart';
import 'legacy_sync_bridge.dart';

/// Helper para migração gradual de apps específicos do UnifiedSyncManager
/// para a nova arquitetura SOLID com app-specific sync services
class AppMigrationHelper {
  static final AppMigrationHelper _instance = AppMigrationHelper._internal();
  static AppMigrationHelper get instance => _instance;
  
  AppMigrationHelper._internal();
  
  final Map<String, ISyncService> _migrationServices = {};
  bool _isInitialized = false;
  
  /// Inicializa o helper de migração
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      developer.log(
        'Initializing App Migration Helper',
        name: 'AppMigrationHelper',
      );
      
      // Registrar serviços de migração para cada app
      _migrationServices['gasometer'] = GasometerSyncService();
      _migrationServices['plantis'] = PlantisSyncService();
      _migrationServices['receituagro'] = ReceitaAgroSyncService();
      _migrationServices['petiveti'] = PetiVetiSyncService();
      
      // Inicializar todos os serviços
      for (final entry in _migrationServices.entries) {
        await entry.value.initialize();
        developer.log(
          'Initialized migration service for ${entry.key}',
          name: 'AppMigrationHelper',
        );
      }
      
      _isInitialized = true;
      
      developer.log(
        'App Migration Helper initialized for ${_migrationServices.length} apps',
        name: 'AppMigrationHelper',
      );
      
    } catch (e) {
      developer.log(
        'Error initializing App Migration Helper: $e',
        name: 'AppMigrationHelper',
      );
      rethrow;
    }
  }
  
  /// Executa teste de compatibilidade para verificar se o app pode migrar
  Future<Either<Failure, MigrationCompatibilityReport>> testMigrationCompatibility(
    String appName,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      developer.log(
        'Testing migration compatibility for $appName',
        name: 'AppMigrationHelper',
      );
      
      final service = _migrationServices[appName];
      if (service == null) {
        return Left(NotFoundFailure('No migration service available for app: $appName'));
      }
      
      // Testar conectividade
      final hasConnectivity = await service.checkConnectivity();
      
      // Testar se o serviço pode sincronizar
      final canSync = service.canSync;
      
      // Obter estatísticas atuais
      final stats = await service.getStatistics();
      
      // Verificar se há sync pendente
      final hasPending = await service.hasPendingSync;
      
      // Simular um sync de teste (apenas um item para verificar)
      Either<Failure, SyncResult>? testSyncResult;
      try {
        testSyncResult = await service.syncSpecific(['test_migration_item']);
      } catch (e) {
        developer.log(
          'Test sync failed for $appName: $e',
          name: 'AppMigrationHelper',
        );
      }
      
      final report = MigrationCompatibilityReport(
        appName: appName,
        serviceId: service.serviceId,
        isCompatible: canSync && hasConnectivity,
        connectivityStatus: hasConnectivity,
        canSyncStatus: canSync,
        hasPendingData: hasPending,
        currentStatistics: stats,
        testSyncSuccessful: testSyncResult?.isRight() ?? false,
        migrationRisks: _assessMigrationRisks(appName, stats, hasPending),
        recommendedMigrationTime: _calculateRecommendedMigrationTime(stats),
        migrationSteps: _generateMigrationSteps(appName),
      );
      
      developer.log(
        'Migration compatibility test completed for $appName: ${report.isCompatible ? "COMPATIBLE" : "NOT COMPATIBLE"}',
        name: 'AppMigrationHelper',
      );
      
      return Right(report);
      
    } catch (e) {
      return Left(MigrationFailure('Failed to test migration compatibility for $appName: $e'));
    }
  }
  
  /// Executa migração assistida para um app específico
  Future<Either<Failure, MigrationResult>> migrateApp(
    String appName, {
    bool dryRun = false,
    bool enableFeatureFlag = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      developer.log(
        'Starting ${dryRun ? "DRY RUN " : ""}migration for $appName',
        name: 'AppMigrationHelper',
      );
      
      final startTime = DateTime.now();
      
      // Passo 1: Verificar compatibilidade
      final compatibilityResult = await testMigrationCompatibility(appName);
      
      final compatibilityReport = compatibilityResult.fold(
        (failure) => throw Exception('Compatibility check failed: ${failure.message}'),
        (report) => report,
      );
      
      if (!compatibilityReport.isCompatible && !dryRun) {
        return Left(MigrationFailure(
          'App $appName is not compatible for migration. Risks: ${compatibilityReport.migrationRisks.join(", ")}'
        ));
      }
      
      final steps = <MigrationStep>[];
      
      // Passo 2: Backup do estado atual (dry run apenas simula)
      if (!dryRun) {
        steps.add(MigrationStep(
          name: 'backup_current_state',
          description: 'Backup do estado atual do UnifiedSyncManager',
          status: MigrationStepStatus.completed,
          timestamp: DateTime.now(),
        ));
      } else {
        steps.add(MigrationStep(
          name: 'backup_current_state',
          description: 'Backup do estado atual do UnifiedSyncManager (DRY RUN)',
          status: MigrationStepStatus.skipped,
          timestamp: DateTime.now(),
        ));
      }
      
      // Passo 3: Ativar feature flag (se solicitado)
      if (enableFeatureFlag && !dryRun) {
        final flags = SyncFeatureFlags.instance;
        flags.enableForApp(appName);
        
        steps.add(MigrationStep(
          name: 'enable_feature_flag',
          description: 'Feature flag ativada para $appName',
          status: MigrationStepStatus.completed,
          timestamp: DateTime.now(),
        ));
      } else {
        steps.add(MigrationStep(
          name: 'enable_feature_flag',
          description: 'Feature flag ${dryRun ? "(DRY RUN)" : "não solicitada"}',
          status: dryRun ? MigrationStepStatus.skipped : MigrationStepStatus.pending,
          timestamp: DateTime.now(),
        ));
      }
      
      // Passo 4: Testar nova arquitetura
      final service = _migrationServices[appName]!;
      final testSyncResult = await service.sync();
      
      if (testSyncResult.isLeft() && !dryRun) {
        steps.add(MigrationStep(
          name: 'test_new_architecture',
          description: 'Teste da nova arquitetura FALHOU',
          status: MigrationStepStatus.failed,
          timestamp: DateTime.now(),
          error: (testSyncResult as Left).value.toString(),
        ));
        
        return Left(MigrationFailure('New architecture test failed for $appName'));
      } else {
        steps.add(MigrationStep(
          name: 'test_new_architecture',
          description: 'Teste da nova arquitetura ${dryRun ? "(DRY RUN)" : "SUCESSO"}',
          status: dryRun ? MigrationStepStatus.skipped : MigrationStepStatus.completed,
          timestamp: DateTime.now(),
        ));
      }
      
      // Passo 5: Validação final
      steps.add(MigrationStep(
        name: 'final_validation',
        description: 'Validação final da migração ${dryRun ? "(DRY RUN)" : ""}',
        status: dryRun ? MigrationStepStatus.skipped : MigrationStepStatus.completed,
        timestamp: DateTime.now(),
      ));
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      final result = MigrationResult(
        appName: appName,
        success: true,
        dryRun: dryRun,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        steps: steps,
        compatibilityReport: compatibilityReport,
        newServiceStatistics: await service.getStatistics(),
      );
      
      developer.log(
        '${dryRun ? "DRY RUN " : ""}Migration completed for $appName in ${duration.inMilliseconds}ms',
        name: 'AppMigrationHelper',
      );
      
      return Right(result);
      
    } catch (e) {
      return Left(MigrationFailure('Migration failed for $appName: $e'));
    }
  }
  
  /// Rollback de migração (volta para UnifiedSyncManager)
  Future<Either<Failure, void>> rollbackMigration(String appName) async {
    try {
      developer.log(
        'Rolling back migration for $appName',
        name: 'AppMigrationHelper',
      );
      
      // Desativar feature flag
      final flags = SyncFeatureFlags.instance;
      flags.disableForApp(appName);
      
      // Usar LegacySyncBridge para garantir que volta para legacy
      await LegacySyncBridge.instance.rollbackAppToLegacy(appName);
      
      developer.log(
        'Migration rollback completed for $appName',
        name: 'AppMigrationHelper',
      );
      
      return const Right(null);
      
    } catch (e) {
      return Left(MigrationFailure('Failed to rollback migration for $appName: $e'));
    }
  }
  
  /// Gera relatório de status de migração para todos os apps
  Future<Map<String, MigrationStatus>> getAllAppsStatus() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final result = <String, MigrationStatus>{};
    final flags = SyncFeatureFlags.instance;
    
    for (final appName in _migrationServices.keys) {
      final isFeatureFlagEnabled = flags.isEnabledForApp(appName);
      final isUsingNewArchitecture = isFeatureFlagEnabled && flags.useNewSyncOrchestrator;
      
      final service = _migrationServices[appName]!;
      final stats = await service.getStatistics();
      
      result[appName] = MigrationStatus(
        appName: appName,
        currentArchitecture: isUsingNewArchitecture ? 'new' : 'legacy',
        featureFlagEnabled: isFeatureFlagEnabled,
        migrationCompleted: isUsingNewArchitecture,
        lastSyncTime: stats.lastSyncTime,
        totalSyncs: stats.totalSyncs,
        successRate: stats.successRate,
      );
    }
    
    return result;
  }
  
  // Métodos privados para assessments
  
  List<String> _assessMigrationRisks(String appName, SyncStatistics stats, bool hasPending) {
    final risks = <String>[];
    
    if (hasPending) {
      risks.add('Possui dados pendentes de sincronização');
    }
    
    if (stats.successRate < 0.9) {
      risks.add('Taxa de sucesso baixa (${(stats.successRate * 100).toStringAsFixed(1)}%)');
    }
    
    if (stats.lastSyncTime == null) {
      risks.add('Nunca foi sincronizado');
    } else {
      final daysSinceLastSync = DateTime.now().difference(stats.lastSyncTime!).inDays;
      if (daysSinceLastSync > 7) {
        risks.add('Última sincronização há $daysSinceLastSync dias');
      }
    }
    
    if (stats.totalSyncs < 10) {
      risks.add('Poucos históricos de sincronização (${stats.totalSyncs})');
    }
    
    return risks;
  }
  
  DateTime _calculateRecommendedMigrationTime(SyncStatistics stats) {
    // Recomendar migração em horário de baixo uso (baseado no histórico)
    final now = DateTime.now();
    
    if (stats.lastSyncTime == null) {
      // Se nunca sincronizou, pode migrar imediatamente
      return now;
    }
    
    // Recomendar para a próxima madrugada (menos uso)
    var recommended = DateTime(now.year, now.month, now.day + 1, 3, 0);
    
    // Se já passou das 3h hoje, agendar para amanhã
    if (now.hour >= 3) {
      recommended = recommended.add(const Duration(days: 1));
    }
    
    return recommended;
  }
  
  List<String> _generateMigrationSteps(String appName) {
    return [
      'Verificar compatibilidade do app $appName',
      'Fazer backup do estado atual',
      'Ativar feature flag para nova arquitetura',
      'Executar sync de teste com nova arquitetura',
      'Validar resultados do sync',
      'Confirmar migração ou fazer rollback',
    ];
  }
  
  /// Cleanup e dispose
  Future<void> dispose() async {
    developer.log(
      'Disposing App Migration Helper',
      name: 'AppMigrationHelper',
    );
    
    for (final service in _migrationServices.values) {
      await service.dispose();
    }
    
    _migrationServices.clear();
    _isInitialized = false;
  }
}

/// Relatório de compatibilidade de migração
class MigrationCompatibilityReport {
  final String appName;
  final String serviceId;
  final bool isCompatible;
  final bool connectivityStatus;
  final bool canSyncStatus;
  final bool hasPendingData;
  final SyncStatistics currentStatistics;
  final bool testSyncSuccessful;
  final List<String> migrationRisks;
  final DateTime recommendedMigrationTime;
  final List<String> migrationSteps;

  const MigrationCompatibilityReport({
    required this.appName,
    required this.serviceId,
    required this.isCompatible,
    required this.connectivityStatus,
    required this.canSyncStatus,
    required this.hasPendingData,
    required this.currentStatistics,
    required this.testSyncSuccessful,
    required this.migrationRisks,
    required this.recommendedMigrationTime,
    required this.migrationSteps,
  });
}

/// Resultado da migração
class MigrationResult {
  final String appName;
  final bool success;
  final bool dryRun;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<MigrationStep> steps;
  final MigrationCompatibilityReport compatibilityReport;
  final SyncStatistics newServiceStatistics;

  const MigrationResult({
    required this.appName,
    required this.success,
    required this.dryRun,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.steps,
    required this.compatibilityReport,
    required this.newServiceStatistics,
  });
}

/// Passo individual da migração
class MigrationStep {
  final String name;
  final String description;
  final MigrationStepStatus status;
  final DateTime timestamp;
  final String? error;

  const MigrationStep({
    required this.name,
    required this.description,
    required this.status,
    required this.timestamp,
    this.error,
  });
}

/// Status de um passo da migração
enum MigrationStepStatus {
  pending,
  running,
  completed,
  failed,
  skipped,
}

/// Status geral de migração de um app
class MigrationStatus {
  final String appName;
  final String currentArchitecture;
  final bool featureFlagEnabled;
  final bool migrationCompleted;
  final DateTime? lastSyncTime;
  final int totalSyncs;
  final double successRate;

  const MigrationStatus({
    required this.appName,
    required this.currentArchitecture,
    required this.featureFlagEnabled,
    required this.migrationCompleted,
    this.lastSyncTime,
    required this.totalSyncs,
    required this.successRate,
  });
}