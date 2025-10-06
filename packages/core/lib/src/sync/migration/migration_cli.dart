import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../config/sync_feature_flags.dart';
import 'app_migration_helper.dart';
import 'legacy_sync_bridge.dart';

/// CLI para migração assistida do UnifiedSyncManager para nova arquitetura
/// Fornece comandos simples para os apps gerenciarem sua migração
class MigrationCLI {
  static final MigrationCLI _instance = MigrationCLI._internal();
  static MigrationCLI get instance => _instance;

  MigrationCLI._internal();

  bool _isInitialized = false;

  /// Inicializa a CLI de migração
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      developer.log('Initializing Migration CLI', name: 'MigrationCLI');

      await AppMigrationHelper.instance.initialize();
      await LegacySyncBridge.instance.initialize();

      _isInitialized = true;

      developer.log(
        'Migration CLI initialized successfully',
        name: 'MigrationCLI',
      );
    } catch (e) {
      developer.log(
        'Error initializing Migration CLI: $e',
        name: 'MigrationCLI',
      );
      rethrow;
    }
  }

  /// Comando: status - Mostra status atual de migração de todos os apps
  Future<Map<String, dynamic>> commandStatus() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      developer.log('Executing status command', name: 'MigrationCLI');

      final appStatuses = await AppMigrationHelper.instance.getAllAppsStatus();
      final bridgeStatuses = LegacySyncBridge.instance.getAllAppsStatus();
      final flags = SyncFeatureFlags.instance;

      final result = {
        'migration_cli_version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'feature_flags': {
          'use_new_sync_orchestrator': flags.useNewSyncOrchestrator,
          'enabled_apps': flags.enabledApps,
        },
        'apps': <String, Map<String, dynamic>>{},
        'summary': {
          'total_apps': appStatuses.length,
          'migrated_apps':
              appStatuses.values.where((s) => s.migrationCompleted).length,
          'pending_migration':
              appStatuses.values.where((s) => !s.migrationCompleted).length,
        },
      };

      for (final appName in appStatuses.keys) {
        final appStatus = appStatuses[appName];
        final bridgeStatus = bridgeStatuses[appName] ?? <String, dynamic>{};

        if (appStatus != null) {
          (result['apps'] as Map<String, dynamic>)[appName] = {
            'current_architecture': appStatus.currentArchitecture,
            'migration_completed': appStatus.migrationCompleted,
            'feature_flag_enabled': appStatus.featureFlagEnabled,
            'last_sync': appStatus.lastSyncTime?.toIso8601String(),
            'total_syncs': appStatus.totalSyncs,
            'success_rate':
                '${(appStatus.successRate * 100).toStringAsFixed(1)}%',
            'bridge_status': bridgeStatus,
          };
        }
      }

      developer.log('Status command completed', name: 'MigrationCLI');

      return result;
    } catch (e) {
      developer.log('Error executing status command: $e', name: 'MigrationCLI');
      return {
        'error': 'Failed to get status: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Comando: check - Verifica compatibilidade de migração para um app
  Future<Map<String, dynamic>> commandCheck(String appName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      developer.log(
        'Executing check command for $appName',
        name: 'MigrationCLI',
      );

      final compatibilityResult = await AppMigrationHelper.instance
          .testMigrationCompatibility(appName);

      final report = compatibilityResult.fold(
        (failure) =>
            throw Exception('Compatibility check failed: ${failure.message}'),
        (report) => report,
      );

      final result = {
        'app': appName,
        'service_id': report.serviceId,
        'is_compatible': report.isCompatible,
        'connectivity_ok': report.connectivityStatus,
        'can_sync': report.canSyncStatus,
        'has_pending_data': report.hasPendingData,
        'test_sync_successful': report.testSyncSuccessful,
        'migration_risks': report.migrationRisks,
        'recommended_migration_time':
            report.recommendedMigrationTime.toIso8601String(),
        'migration_steps': report.migrationSteps,
        'current_statistics': {
          'total_syncs': report.currentStatistics.totalSyncs,
          'successful_syncs': report.currentStatistics.successfulSyncs,
          'failed_syncs': report.currentStatistics.failedSyncs,
          'success_rate':
              '${(report.currentStatistics.successRate * 100).toStringAsFixed(1)}%',
          'last_sync': report.currentStatistics.lastSyncTime?.toIso8601String(),
        },
        'recommendation': _generateMigrationRecommendation(report),
        'timestamp': DateTime.now().toIso8601String(),
      };

      developer.log(
        'Check command completed for $appName: ${report.isCompatible ? "COMPATIBLE" : "NOT COMPATIBLE"}',
        name: 'MigrationCLI',
      );

      return result;
    } catch (e) {
      developer.log(
        'Error executing check command for $appName: $e',
        name: 'MigrationCLI',
      );
      return {
        'app': appName,
        'error': 'Failed to check compatibility: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Comando: migrate - Executa migração para um app
  Future<Map<String, dynamic>> commandMigrate(
    String appName, {
    bool dryRun = false,
    bool force = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      developer.log(
        'Executing migrate command for $appName (dryRun: $dryRun, force: $force)',
        name: 'MigrationCLI',
      );
      if (!force) {
        final checkResult = await commandCheck(appName);
        final isCompatible = checkResult['is_compatible'] as bool? ?? false;
        if (checkResult['error'] != null || !isCompatible) {
          return {
            'app': appName,
            'action': 'migrate',
            'error':
                'App not compatible for migration. Use --force to override.',
            'compatibility_check': checkResult,
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
      }

      final migrationResult = await AppMigrationHelper.instance.migrateApp(
        appName,
        dryRun: dryRun,
        enableFeatureFlag: !dryRun,
      );

      final result = migrationResult.fold(
        (failure) => throw Exception('Migration failed: ${failure.message}'),
        (result) => result,
      );

      final response = {
        'app': appName,
        'action': 'migrate',
        'success': result.success,
        'dry_run': result.dryRun,
        'duration_ms': result.duration.inMilliseconds,
        'start_time': result.startTime.toIso8601String(),
        'end_time': result.endTime.toIso8601String(),
        'steps':
            result.steps
                .map(
                  (MigrationStep step) => {
                    'name': step.name,
                    'description': step.description,
                    'status': step.status.name,
                    'timestamp': step.timestamp.toIso8601String(),
                    'error': step.error,
                  },
                )
                .toList(),
        'new_service_stats': {
          'service_id': result.newServiceStatistics.serviceId,
          'total_syncs': result.newServiceStatistics.totalSyncs,
          'success_rate':
              '${(result.newServiceStatistics.successRate * 100).toStringAsFixed(1)}%',
        },
        'next_steps': _generateNextSteps(result),
        'timestamp': DateTime.now().toIso8601String(),
      };

      developer.log(
        'Migrate command completed for $appName: ${result.success ? "SUCCESS" : "FAILED"}',
        name: 'MigrationCLI',
      );

      return response;
    } catch (e) {
      developer.log(
        'Error executing migrate command for $appName: $e',
        name: 'MigrationCLI',
      );
      return {
        'app': appName,
        'action': 'migrate',
        'dry_run': dryRun,
        'error': 'Failed to migrate: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Comando: rollback - Faz rollback da migração
  Future<Map<String, dynamic>> commandRollback(String appName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      developer.log(
        'Executing rollback command for $appName',
        name: 'MigrationCLI',
      );

      final rollbackResult = await AppMigrationHelper.instance
          .rollbackMigration(appName);

      if (rollbackResult.isLeft()) {
        final failure = (rollbackResult as Left).value;
        return {
          'app': appName,
          'action': 'rollback',
          'error': failure.message,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      developer.log(
        'Rollback command completed for $appName',
        name: 'MigrationCLI',
      );

      return {
        'app': appName,
        'action': 'rollback',
        'success': true,
        'message': 'App $appName rolled back to legacy UnifiedSyncManager',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log(
        'Error executing rollback command for $appName: $e',
        name: 'MigrationCLI',
      );
      return {
        'app': appName,
        'action': 'rollback',
        'error': 'Failed to rollback: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Comando: enable-flags - Ativa feature flags globalmente
  Future<Map<String, dynamic>> commandEnableFlags() async {
    try {
      developer.log('Executing enable-flags command', name: 'MigrationCLI');

      final flags = SyncFeatureFlags.instance;
      flags.enableNewSyncOrchestrator();

      return {
        'action': 'enable-flags',
        'success': true,
        'message': 'Global feature flags enabled for new sync orchestrator',
        'enabled_flags': {
          'use_new_sync_orchestrator': flags.useNewSyncOrchestrator,
          'enabled_apps': flags.enabledApps,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'action': 'enable-flags',
        'error': 'Failed to enable flags: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Comando: disable-flags - Desativa feature flags globalmente
  Future<Map<String, dynamic>> commandDisableFlags() async {
    try {
      developer.log('Executing disable-flags command', name: 'MigrationCLI');

      final flags = SyncFeatureFlags.instance;
      flags.disableNewSyncOrchestrator();

      return {
        'action': 'disable-flags',
        'success': true,
        'message':
            'Global feature flags disabled - all apps using legacy UnifiedSyncManager',
        'enabled_flags': {
          'use_new_sync_orchestrator': flags.useNewSyncOrchestrator,
          'enabled_apps': flags.enabledApps,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'action': 'disable-flags',
        'error': 'Failed to disable flags: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Comando: help - Mostra ajuda
  Map<String, dynamic> commandHelp() {
    return {
      'migration_cli_help': {
        'version': '1.0.0',
        'description':
            'CLI para migração do UnifiedSyncManager para nova arquitetura SOLID',
        'commands': {
          'status': {
            'description': 'Mostra status atual de migração de todos os apps',
            'usage': 'MigrationCLI.instance.commandStatus()',
            'returns': 'Status geral com informações de todos os apps',
          },
          'check <app>': {
            'description':
                'Verifica compatibilidade de migração para um app específico',
            'usage': 'MigrationCLI.instance.commandCheck("gasometer")',
            'parameters': [
              'app: Nome do app (gasometer, plantis, receituagro, petiveti)',
            ],
            'returns':
                'Relatório de compatibilidade com riscos e recomendações',
          },
          'migrate <app>': {
            'description': 'Executa migração para nova arquitetura',
            'usage':
                'MigrationCLI.instance.commandMigrate("gasometer", dryRun: false)',
            'parameters': [
              'app: Nome do app',
              'dryRun: true para simular sem executar (default: false)',
              'force: true para pular verificação de compatibilidade (default: false)',
            ],
            'returns': 'Resultado da migração com passos executados',
          },
          'rollback <app>': {
            'description': 'Faz rollback para arquitetura legacy',
            'usage': 'MigrationCLI.instance.commandRollback("gasometer")',
            'parameters': ['app: Nome do app'],
            'returns': 'Confirmação do rollback',
          },
          'enable-flags': {
            'description': 'Ativa feature flags globalmente',
            'usage': 'MigrationCLI.instance.commandEnableFlags()',
            'returns': 'Status das feature flags',
          },
          'disable-flags': {
            'description': 'Desativa feature flags globalmente',
            'usage': 'MigrationCLI.instance.commandDisableFlags()',
            'returns': 'Status das feature flags',
          },
          'help': {
            'description': 'Mostra esta ajuda',
            'usage': 'MigrationCLI.instance.commandHelp()',
            'returns': 'Documentação dos comandos',
          },
        },
        'examples': {
          'migration_flow': [
            '1. MigrationCLI.instance.commandStatus() // Ver status geral',
            '2. MigrationCLI.instance.commandCheck("gasometer") // Verificar compatibilidade',
            '3. MigrationCLI.instance.commandMigrate("gasometer", dryRun: true) // Testar migração',
            '4. MigrationCLI.instance.commandMigrate("gasometer") // Executar migração real',
            '5. MigrationCLI.instance.commandStatus() // Confirmar migração',
          ],
          'rollback_flow': [
            '1. MigrationCLI.instance.commandRollback("gasometer") // Voltar para legacy',
            '2. MigrationCLI.instance.commandStatus() // Confirmar rollback',
          ],
        },
        'supported_apps': ['gasometer', 'plantis', 'receituagro', 'petiveti'],
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _generateMigrationRecommendation(MigrationCompatibilityReport report) {
    if (!report.isCompatible) {
      return 'NOT RECOMMENDED - Resolve migration risks first: ${report.migrationRisks.join(", ")}';
    }

    if (report.migrationRisks.isEmpty) {
      return 'HIGHLY RECOMMENDED - No risks detected, safe to migrate immediately';
    }

    if (report.migrationRisks.length <= 2) {
      return 'RECOMMENDED WITH CAUTION - Minor risks detected, consider migrating at recommended time';
    }

    return 'PROCEED WITH CARE - Multiple risks detected, thorough testing recommended';
  }

  List<String> _generateNextSteps(MigrationResult result) {
    if (!result.success) {
      return [
        'Review migration errors',
        'Fix compatibility issues',
        'Retry migration or consider rollback',
      ];
    }

    if (result.dryRun) {
      return [
        'Dry run successful - ready for real migration',
        'Execute migration without dryRun flag',
        'Monitor app behavior after migration',
      ];
    }

    return [
      'Migration completed successfully',
      'Monitor app sync behavior',
      'Consider migrating other apps',
      'Plan UnifiedSyncManager removal after all apps migrated',
    ];
  }

  /// Cleanup e dispose
  Future<void> dispose() async {
    developer.log('Disposing Migration CLI', name: 'MigrationCLI');

    await AppMigrationHelper.instance.dispose();
    await LegacySyncBridge.instance.dispose();

    _isInitialized = false;
  }
}
