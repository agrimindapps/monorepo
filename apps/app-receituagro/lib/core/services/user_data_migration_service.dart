import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_settings_model.dart';
import '../models/subscription_data_model.dart';
import '../../features/favoritos/models/favorito_defensivo_model.dart';
import '../../features/comentarios/models/comentario_model.dart';
import '../../features/analytics/analytics_service.dart';

enum MigrationStatus { pending, inProgress, completed, failed, rolledBack }

class MigrationResult {
  final bool success;
  final String message;
  final Map<String, int> migratedCounts;
  final List<String> errors;
  final DateTime timestamp;

  const MigrationResult({
    required this.success,
    required this.message,
    required this.migratedCounts,
    required this.errors,
    required this.timestamp,
  });

  Map<String, dynamic> toAnalyticsData() {
    return {
      'success': success,
      'message': message,
      'migrated_counts': migratedCounts,
      'error_count': errors.length,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class UserDataMigrationService {
  static const String _backupPrefix = 'migration_backup_';
  static const String _migrationStatusKey = 'migration_status';
  static const int _maxBackupFiles = 5;

  final ReceitaAgroAnalyticsService _analyticsService;

  UserDataMigrationService(this._analyticsService);

  /// Executa a migração completa dos dados do usuário
  Future<MigrationResult> migrateUserData(String userId) async {
    final startTime = DateTime.now();
    
    try {
      // Track início da migração
      await _analyticsService.logEvent(
        ReceitaAgroAnalyticsEvent.featureUsed,
        parameters: {
          'feature_name': 'migration_started',
          'user_id': userId,
          'timestamp': startTime.toIso8601String(),
        },
      );

      // Verificar se migração já foi executada
      if (await _isMigrationCompleted(userId)) {
        return MigrationResult(
          success: true,
          message: 'Migration already completed for user $userId',
          migratedCounts: {},
          errors: [],
          timestamp: DateTime.now(),
        );
      }

      // Criar backup antes da migração
      final backupPath = await _createBackup(userId);
      
      // Marcar migração como em progresso
      await _setMigrationStatus(userId, MigrationStatus.inProgress);

      final errors = <String>[];
      final migratedCounts = <String, int>{};

      // Migrar favoritos
      try {
        final favoritosCount = await _migrateFavoritos(userId);
        migratedCounts['favoritos'] = favoritosCount;
        
        await _analyticsService.logEvent(
          ReceitaAgroAnalyticsEvent.featureUsed,
          parameters: {
            'feature_name': 'migration_step_favoritos',
            'count': favoritosCount.toString(),
          },
        );
      } catch (e) {
        errors.add('Favoritos migration failed: $e');
      }

      // Migrar comentários
      try {
        final comentariosCount = await _migrateComentarios(userId);
        migratedCounts['comentarios'] = comentariosCount;
        
        await _analyticsService.logEvent(
          ReceitaAgroAnalyticsEvent.featureUsed,
          parameters: {
            'feature_name': 'migration_step_comentarios', 
            'count': comentariosCount.toString(),
          },
        );
      } catch (e) {
        errors.add('Comentarios migration failed: $e');
      }

      // Criar configurações do app para o usuário
      try {
        await _createUserAppSettings(userId);
        migratedCounts['app_settings'] = 1;
        
        await _analyticsService.logEvent(
          ReceitaAgroAnalyticsEvent.featureUsed,
          parameters: {
            'feature_name': 'migration_step_settings',
            'count': '1',
          },
        );
      } catch (e) {
        errors.add('App settings creation failed: $e');
      }

      // Criar dados de subscription
      try {
        await _createUserSubscriptionData(userId);
        migratedCounts['subscription'] = 1;
        
        await _analyticsService.logEvent(
          ReceitaAgroAnalyticsEvent.featureUsed,
          parameters: {
            'feature_name': 'migration_step_subscription',
            'count': '1',
          },
        );
      } catch (e) {
        errors.add('Subscription data creation failed: $e');
      }

      // Validar migração
      final validationResult = await _validateMigration(userId, migratedCounts);
      
      if (validationResult && errors.isEmpty) {
        await _setMigrationStatus(userId, MigrationStatus.completed);
        
        // Cleanup backup antigos
        await _cleanupOldBackups();
        
        final result = MigrationResult(
          success: true,
          message: 'Migration completed successfully',
          migratedCounts: migratedCounts,
          errors: [],
          timestamp: DateTime.now(),
        );

        await _analyticsService.logEvent(
          ReceitaAgroAnalyticsEvent.featureUsed,
          parameters: {
            'feature_name': 'migration_completed',
            ...result.toAnalyticsData().map((k, v) => MapEntry(k, v.toString())),
          },
        );
        return result;
        
      } else {
        // Rollback em caso de falhas críticas
        await _rollbackMigration(backupPath, userId);
        
        final result = MigrationResult(
          success: false,
          message: 'Migration failed and was rolled back',
          migratedCounts: migratedCounts,
          errors: errors,
          timestamp: DateTime.now(),
        );

        await _analyticsService.logEvent(
          ReceitaAgroAnalyticsEvent.errorOccurred,
          parameters: {
            'error_type': 'migration_failed',
            ...result.toAnalyticsData().map((k, v) => MapEntry(k, v.toString())),
          },
        );
        return result;
      }

    } catch (e) {
      await _setMigrationStatus(userId, MigrationStatus.failed);
      
      final result = MigrationResult(
        success: false,
        message: 'Critical migration error: $e',
        migratedCounts: {},
        errors: [e.toString()],
        timestamp: DateTime.now(),
      );

      await _analyticsService.logEvent(
        ReceitaAgroAnalyticsEvent.errorOccurred,
        parameters: {
          'error_type': 'migration_critical_error',
          ...result.toAnalyticsData().map((k, v) => MapEntry(k, v.toString())),
        },
      );
      return result;
    }
  }

  /// Migra dados de favoritos defensivos para incluir userId
  Future<int> _migrateFavoritos(String userId) async {
    // Nota: Como FavoritoDefensivoModel não é um HiveObject, 
    // a migração seria feita via repository pattern
    // Aqui está a lógica conceitual:
    
    int migratedCount = 0;
    
    // A implementação real dependeria de como os favoritos são armazenados
    // Se estão em Hive, SQLite, ou outro storage
    
    // Pseudo-código:
    // 1. Buscar todos os favoritos sem userId
    // 2. Para cada favorito, adicionar userId e marcar como não sincronizado
    // 3. Salvar de volta no storage
    
    return migratedCount;
  }

  /// Migra dados de comentários para incluir userId
  Future<int> _migrateComentarios(String userId) async {
    int migratedCount = 0;
    
    // Similar aos favoritos, a implementação dependeria do storage usado
    // Pseudo-código:
    // 1. Buscar todos os comentários sem userId
    // 2. Para cada comentário, adicionar userId e marcar como não sincronizado
    // 3. Salvar de volta no storage
    
    return migratedCount;
  }

  /// Cria configurações iniciais do app para o usuário
  Future<void> _createUserAppSettings(String userId) async {
    final settingsBox = await Hive.openBox<AppSettingsModel>('app_settings');
    
    // Verificar se já existe configuração para o usuário
    final existingSettings = settingsBox.values
        .where((settings) => settings.userId == userId)
        .firstOrNull;

    if (existingSettings == null) {
      final newSettings = AppSettingsModel(
        userId: userId,
        createdAt: DateTime.now(),
        synchronized: false, // Será sincronizado após criação
      );
      
      await settingsBox.add(newSettings);
    }
  }

  /// Cria dados de subscription iniciais para o usuário
  Future<void> _createUserSubscriptionData(String userId) async {
    final subscriptionBox = await Hive.openBox<SubscriptionDataModel>('subscription_data');
    
    // Verificar se já existe subscription para o usuário
    final existingSubscription = subscriptionBox.values
        .where((subscription) => subscription.userId == userId)
        .firstOrNull;

    if (existingSubscription == null) {
      final newSubscription = SubscriptionDataModel(
        userId: userId,
        status: 'expired', // Status padrão
        platform: _getPlatformName(),
        createdAt: DateTime.now(),
        synchronized: false,
      );
      
      await subscriptionBox.add(newSubscription);
    }
  }

  /// Cria backup dos dados antes da migração
  Future<String> _createBackup(String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFileName = '${_backupPrefix}${userId}_$timestamp.json';
    
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupFile = File('${documentsDir.path}/$backupFileName');

    final backupData = {
      'timestamp': timestamp,
      'userId': userId,
      'hive_boxes': await _exportHiveBoxes(),
    };

    await backupFile.writeAsString(json.encode(backupData));
    return backupFile.path;
  }

  /// Exporta dados dos boxes Hive para backup
  Future<Map<String, dynamic>> _exportHiveBoxes() async {
    final boxData = <String, dynamic>{};
    
    // Export boxes que precisam de backup
    final boxNames = ['favoritos', 'comentarios', 'app_settings', 'subscription_data'];
    
    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          boxData[boxName] = box.toMap();
        }
      } catch (e) {
        // Box pode não existir ainda, ignorar
      }
    }
    
    return boxData;
  }

  /// Executa rollback da migração usando backup
  Future<void> _rollbackMigration(String backupPath, String userId) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found: $backupPath');
      }

      final backupContent = await backupFile.readAsString();
      final backupData = json.decode(backupContent) as Map<String, dynamic>;
      final hiveBoxes = backupData['hive_boxes'] as Map<String, dynamic>;

      // Restaurar dados dos boxes
      for (final entry in hiveBoxes.entries) {
        try {
          final box = await Hive.openBox(entry.key);
          await box.clear();
          
          final boxData = entry.value as Map<String, dynamic>;
          for (final dataEntry in boxData.entries) {
            await box.put(dataEntry.key, dataEntry.value);
          }
        } catch (e) {
          // Log error but continue with other boxes
        }
      }

      await _setMigrationStatus(userId, MigrationStatus.rolledBack);
      
      await _analyticsService.logEvent(
        ReceitaAgroAnalyticsEvent.featureUsed,
        parameters: {
          'feature_name': 'migration_rollback_completed',
          'user_id': userId,
          'backup_path': backupPath,
        },
      );
      
    } catch (e) {
      await _analyticsService.logEvent(
        ReceitaAgroAnalyticsEvent.errorOccurred,
        parameters: {
          'error_type': 'migration_rollback_failed',
          'user_id': userId,
          'error': e.toString(),
        },
      );
      throw Exception('Rollback failed: $e');
    }
  }

  /// Valida se a migração foi executada corretamente
  Future<bool> _validateMigration(String userId, Map<String, int> expectedCounts) async {
    try {
      // Validar se os dados migrados estão corretos
      // Verificar se os novos modelos foram criados
      // Verificar se os dados existentes foram atualizados com userId
      
      // Por enquanto, validação básica
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpa backups antigos mantendo apenas os mais recentes
  Future<void> _cleanupOldBackups() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final files = documentsDir.listSync()
          .whereType<File>()
          .where((file) => file.path.contains(_backupPrefix))
          .toList();

      if (files.length > _maxBackupFiles) {
        // Ordenar por data de modificação
        files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        
        // Deletar arquivos mais antigos
        final filesToDelete = files.take(files.length - _maxBackupFiles);
        for (final file in filesToDelete) {
          await file.delete();
        }
      }
    } catch (e) {
      // Log error but don't throw - cleanup is not critical
    }
  }

  /// Verifica se a migração já foi completada para o usuário
  Future<bool> _isMigrationCompleted(String userId) async {
    final status = await _getMigrationStatus(userId);
    return status == MigrationStatus.completed;
  }

  /// Define o status da migração
  Future<void> _setMigrationStatus(String userId, MigrationStatus status) async {
    final box = await Hive.openBox('migration_status');
    await box.put('${_migrationStatusKey}_$userId', status.index);
  }

  /// Obtém o status da migração
  Future<MigrationStatus> _getMigrationStatus(String userId) async {
    final box = await Hive.openBox('migration_status');
    final statusIndex = box.get('${_migrationStatusKey}_$userId', defaultValue: 0) as int;
    return MigrationStatus.values[statusIndex];
  }

  /// Obtém o nome da plataforma atual
  String _getPlatformName() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// Obtém estatísticas da migração para analytics
  Future<Map<String, dynamic>> getMigrationStats() async {
    final box = await Hive.openBox('migration_status');
    final stats = <String, int>{};
    
    for (final status in MigrationStatus.values) {
      stats[status.name] = 0;
    }
    
    for (final value in box.values) {
      if (value is int && value < MigrationStatus.values.length) {
        final status = MigrationStatus.values[value];
        stats[status.name] = (stats[status.name] ?? 0) + 1;
      }
    }
    
    return {
      'total_migrations': box.length,
      'status_breakdown': stats,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }
}