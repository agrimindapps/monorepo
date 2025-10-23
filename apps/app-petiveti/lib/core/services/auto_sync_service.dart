import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../sync/petiveti_sync_config.dart';

/// AutoSyncService for app-petiveti
///
/// Responsabilidades:
/// 1. Inicializar UnifiedSyncManager com PetivetiSyncConfig
/// 2. Registrar todas as entidades (Animal, Medication, Appointment, Weight, Settings)
/// 3. Gerenciar background sync automático
/// 4. Fornecer interface para sync manual
///
/// **Quando usar:**
/// - Chamar `initialize()` no app startup (main.dart)
/// - Chamar `forceSync()` quando usuário fizer pull-to-refresh
/// - Chamar `pauseSync()` / `resumeSync()` para controle manual
///
/// **Exemplo:**
/// ```dart
/// // No main.dart
/// await AutoSyncService.instance.initialize(
///   syncConfig: PetivetiSyncConfig.development(),
/// );
///
/// // Pull-to-refresh
/// await AutoSyncService.instance.forceSync();
/// ```
class AutoSyncService {
  /// Singleton instance
  static AutoSyncService? _instance;
  static AutoSyncService get instance => _instance ??= AutoSyncService._();

  AutoSyncService._();

  /// UnifiedSyncManager instance
  UnifiedSyncManager? _syncManager;

  /// Configuração atual
  PetivetiSyncConfig? _currentConfig;

  /// Se está inicializado
  bool _isInitialized = false;

  /// Se sync está pausado
  bool _isPaused = false;

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  /// Inicializa AutoSyncService com configuração
  Future<void> initialize({
    PetivetiSyncConfig? syncConfig,
    bool startImmediately = true,
  }) async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] Already initialized, skipping...');
      }
      return;
    }

    try {
      // 1. Usar configuração padrão se não fornecida
      _currentConfig = syncConfig ??
          (kDebugMode
              ? PetivetiSyncConfig.development()
              : PetivetiSyncConfig.simple());

      if (kDebugMode) {
        debugPrint('[AutoSyncService] Initializing with config:');
        debugPrint(_currentConfig!.toDebugMap().toString());
      }

      // 2. Obter UnifiedSyncManager instance
      _syncManager = UnifiedSyncManager.instance;

      // 3. TODO: Registrar configuração do app quando API estiver disponível
      // await _syncManager!.registerApp(_currentConfig!.appSyncConfig);

      // 4. TODO: Registrar entidades quando API estiver disponível
      // for (final registration in _currentConfig!.entityRegistrations) {
      //   await _syncManager!.registerEntity(
      //     _currentConfig!.appSyncConfig.appName,
      //     registration,
      //   );
      // }

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('[AutoSyncService] ✅ Initialized successfully (stub mode)');
        debugPrint(
          '[AutoSyncService] Config ready for ${_currentConfig!.entityRegistrations.length} entities',
        );
        debugPrint(
          '[AutoSyncService] ⚠️ UnifiedSyncManager API not yet implemented',
        );
      }

      // 5. TODO: Iniciar sync automático quando API estiver disponível
      // if (startImmediately) {
      //   await startAutoSync();
      // }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] ❌ Initialization failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Inicia sync automático em background
  Future<void> startAutoSync() async {
    if (!_isInitialized) {
      throw StateError('AutoSyncService not initialized');
    }

    if (_isPaused) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] Sync is paused, not starting auto sync');
      }
      return;
    }

    try {
      // TODO: Implementar quando UnifiedSyncManager tiver API completa
      // await _syncManager!.startAutoSync(_currentConfig!.appSyncConfig.appName);

      if (kDebugMode) {
        debugPrint('[AutoSyncService] ✅ Auto sync started (stub mode)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] ❌ Failed to start auto sync: $e');
      }
      rethrow;
    }
  }

  /// Para sync automático em background
  Future<void> stopAutoSync() async {
    if (!_isInitialized) return;

    try {
      // TODO: Implementar quando UnifiedSyncManager tiver API completa
      // await _syncManager!.stopAutoSync(_currentConfig!.appSyncConfig.appName);

      if (kDebugMode) {
        debugPrint('[AutoSyncService] ⏸️ Auto sync stopped (stub mode)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] ❌ Failed to stop auto sync: $e');
      }
    }
  }

  // ========================================================================
  // MANUAL SYNC
  // ========================================================================

  /// Force sync manual de todas as entidades
  ///
  /// **Retorna**: true se sync foi bem-sucedido, false caso contrário
  Future<bool> forceSync() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] Not initialized, cannot force sync');
      }
      return false;
    }

    if (_isPaused) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] Sync is paused, cannot force sync');
      }
      return false;
    }

    try {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] 🔄 Starting manual sync...');
      }

      // TODO: Implementar quando UnifiedSyncManager tiver API completa
      // await _syncManager!.forceSyncApp(_currentConfig!.appSyncConfig.appName);

      if (kDebugMode) {
        debugPrint('[AutoSyncService] ✅ Manual sync completed (stub mode)');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] ❌ Manual sync failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// Force sync de uma entidade específica
  ///
  /// **Exemplo:**
  /// ```dart
  /// await AutoSyncService.instance.forceSyncEntity('medications');
  /// ```
  Future<bool> forceSyncEntity(String collectionName) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
          '[AutoSyncService] Not initialized, cannot force sync entity',
        );
      }
      return false;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[AutoSyncService] 🔄 Starting manual sync for $collectionName...',
        );
      }

      // TODO: Implementar quando UnifiedSyncManager tiver API completa
      // await _syncManager!.syncCollection(
      //   _currentConfig!.appSyncConfig.appName,
      //   collectionName,
      // );

      if (kDebugMode) {
        debugPrint(
          '[AutoSyncService] ✅ Manual sync completed for $collectionName (stub mode)',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] ❌ Manual sync failed: $e');
      }
      return false;
    }
  }

  // ========================================================================
  // PAUSE/RESUME
  // ========================================================================

  /// Pausa sync (útil para economizar bateria ou dados)
  Future<void> pauseSync() async {
    if (!_isInitialized) return;

    _isPaused = true;
    await stopAutoSync();

    if (kDebugMode) {
      debugPrint('[AutoSyncService] ⏸️ Sync paused');
    }
  }

  /// Resume sync após pausar
  Future<void> resumeSync() async {
    if (!_isInitialized) return;

    _isPaused = false;
    await startAutoSync();

    if (kDebugMode) {
      debugPrint('[AutoSyncService] ▶️ Sync resumed');
    }
  }

  // ========================================================================
  // STATUS
  // ========================================================================

  /// Retorna se está inicializado
  bool get isInitialized => _isInitialized;

  /// Retorna se sync está pausado
  bool get isPaused => _isPaused;

  /// Retorna configuração atual
  PetivetiSyncConfig? get currentConfig => _currentConfig;

  /// Retorna status de sync
  Future<Map<String, dynamic>> getSyncStatus() async {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'paused': false,
        'entities': 0,
      };
    }

    try {
      // TODO: Implementar quando UnifiedSyncManager tiver API completa
      // final status = await _syncManager!
      //     .getSyncStatus(_currentConfig!.appSyncConfig.appName);

      return {
        'initialized': true,
        'paused': _isPaused,
        'entities': _currentConfig!.entityRegistrations.length,
        'stub_mode': true,
        // 'last_sync': status['last_sync'],
        // 'pending_sync': status['pending_sync'],
        // 'sync_errors': status['sync_errors'],
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] Failed to get sync status: $e');
      }
      return {
        'initialized': true,
        'paused': _isPaused,
        'entities': _currentConfig!.entityRegistrations.length,
        'error': e.toString(),
      };
    }
  }

  // ========================================================================
  // CLEANUP
  // ========================================================================

  /// Limpa recursos e para sync
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await stopAutoSync();
      _isInitialized = false;
      _isPaused = false;
      _currentConfig = null;

      if (kDebugMode) {
        debugPrint('[AutoSyncService] 🗑️ Disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSyncService] ❌ Error during dispose: $e');
      }
    }
  }

  // ========================================================================
  // CONVENIENCE METHODS
  // ========================================================================

  /// Atalho para sync de medicações (dados críticos)
  Future<bool> syncMedications() => forceSyncEntity('medications');

  /// Atalho para sync de animais
  Future<bool> syncAnimals() => forceSyncEntity('animals');

  /// Atalho para sync de consultas
  Future<bool> syncAppointments() => forceSyncEntity('appointments');

  /// Atalho para sync de pesos
  Future<bool> syncWeights() => forceSyncEntity('weights');

  /// Atalho para sync de configurações
  Future<bool> syncSettings() => forceSyncEntity('user_settings');
}
