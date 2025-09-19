import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../sync/background_sync_status.dart';

/// Dedicated service for background synchronization operations
/// Separates sync concerns from authentication flow
@singleton
class BackgroundSyncService extends ChangeNotifier {
  bool _isSyncInProgress = false;
  bool _hasPerformedInitialSync = false;
  String _currentSyncMessage = 'Inicializando sincronização...';
  BackgroundSyncStatus _syncStatus = BackgroundSyncStatus.idle;
  final Map<String, bool> _operationStatus = {};

  // Stream controllers for reactive updates
  final StreamController<String> _syncMessageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _syncProgressController =
      StreamController<bool>.broadcast();
  final StreamController<BackgroundSyncStatus> _syncStatusController =
      StreamController<BackgroundSyncStatus>.broadcast();

  // Getters
  bool get isSyncInProgress => _isSyncInProgress;
  bool get hasPerformedInitialSync => _hasPerformedInitialSync;
  String get currentSyncMessage => _currentSyncMessage;
  BackgroundSyncStatus get syncStatus => _syncStatus;

  // Streams for reactive UI updates
  Stream<String> get syncMessageStream => _syncMessageController.stream;
  Stream<bool> get syncProgressStream => _syncProgressController.stream;
  Stream<BackgroundSyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Starts background synchronization for authenticated users
  Future<void> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    if (_isSyncInProgress) {
      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Sync já em progresso, ignorando nova solicitação');
      }
      return;
    }

    if (!isInitialSync && _hasPerformedInitialSync) {
      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Sync inicial já realizada nesta sessão');
      }
      return;
    }

    _setSyncInProgress(true);
    _updateSyncStatus(BackgroundSyncStatus.syncing);

    try {
      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Iniciando sincronização para usuário $userId');
      }

      // Perform sync operations in sequence
      await _performSyncOperations(userId);

      // Mark initial sync as completed
      if (isInitialSync || !_hasPerformedInitialSync) {
        _hasPerformedInitialSync = true;
      }

      _updateSyncStatus(BackgroundSyncStatus.completed);

      if (kDebugMode) {
        debugPrint('✅ BackgroundSync: Sincronização completada com sucesso');
      }

    } catch (e) {
      _updateSyncStatus(BackgroundSyncStatus.error);

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro durante sincronização: $e');
      }

      // Don't mark as completed if there was an error

    } finally {
      _setSyncInProgress(false);
    }
  }

  /// Performs all sync operations in background
  Future<void> _performSyncOperations(String userId) async {
    // 1. Sync user data
    await _syncUserData(userId);

    // 2. Sync plants data
    await _syncPlantsData(userId);

    // 3. Sync tasks data
    await _syncTasksData(userId);

    // 4. Sync settings
    await _syncSettingsData(userId);
  }

  /// Sync user account data
  Future<void> _syncUserData(String userId) async {
    _updateSyncMessage('Sincronizando informações da conta...');
    _operationStatus['user_data'] = false;

    try {
      // Simulate user data sync - replace with actual implementation
      await Future<void>.delayed(const Duration(milliseconds: 800));

      _operationStatus['user_data'] = true;

      if (kDebugMode) {
        debugPrint('✅ BackgroundSync: Dados do usuário sincronizados');
      }
    } catch (e) {
      _operationStatus['user_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar dados do usuário: $e');
      }

      // Don't rethrow - allow other operations to continue
    }
  }

  /// Sync plants data
  Future<void> _syncPlantsData(String userId) async {
    _updateSyncMessage('Sincronizando suas plantas...');
    _operationStatus['plants_data'] = false;

    try {
      // Simulate plants data sync - replace with actual implementation
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      _operationStatus['plants_data'] = true;

      if (kDebugMode) {
        debugPrint('✅ BackgroundSync: Dados das plantas sincronizados');
      }
    } catch (e) {
      _operationStatus['plants_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar plantas: $e');
      }

      // Don't rethrow - allow other operations to continue
    }
  }

  /// Sync tasks data
  Future<void> _syncTasksData(String userId) async {
    _updateSyncMessage('Sincronizando tarefas pendentes...');
    _operationStatus['tasks_data'] = false;

    try {
      // Simulate tasks data sync - replace with actual implementation
      await Future<void>.delayed(const Duration(milliseconds: 900));

      _operationStatus['tasks_data'] = true;

      if (kDebugMode) {
        debugPrint('✅ BackgroundSync: Dados das tarefas sincronizados');
      }
    } catch (e) {
      _operationStatus['tasks_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar tarefas: $e');
      }

      // Don't rethrow - allow other operations to continue
    }
  }

  /// Sync settings data
  Future<void> _syncSettingsData(String userId) async {
    _updateSyncMessage('Sincronizando preferências...');
    _operationStatus['settings_data'] = false;

    try {
      // Simulate settings data sync - replace with actual implementation
      await Future<void>.delayed(const Duration(milliseconds: 600));

      _operationStatus['settings_data'] = true;

      if (kDebugMode) {
        debugPrint('✅ BackgroundSync: Configurações sincronizadas');
      }
    } catch (e) {
      _operationStatus['settings_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar configurações: $e');
      }

      // Don't rethrow - allow other operations to continue
    }
  }

  /// Updates sync progress state
  void _setSyncInProgress(bool inProgress) {
    _isSyncInProgress = inProgress;
    _syncProgressController.add(inProgress);
    notifyListeners();
  }

  /// Updates current sync message
  void _updateSyncMessage(String message) {
    _currentSyncMessage = message;
    _syncMessageController.add(message);
    notifyListeners();
  }

  /// Updates overall sync status
  void _updateSyncStatus(BackgroundSyncStatus status) {
    _syncStatus = status;
    _syncStatusController.add(status);
    notifyListeners();
  }

  /// Cancels ongoing sync operation
  void cancelSync() {
    if (_isSyncInProgress) {
      _setSyncInProgress(false);
      _updateSyncMessage('Sincronização cancelada');
      _updateSyncStatus(BackgroundSyncStatus.cancelled);

      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Sincronização cancelada pelo usuário');
      }
    }
  }

  /// Retries failed sync operations
  Future<void> retrySync(String userId) async {
    if (_isSyncInProgress) {
      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Não é possível repetir - sync em progresso');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 BackgroundSync: Repetindo sincronização...');
    }

    await startBackgroundSync(userId: userId, isInitialSync: false);
  }

  /// Gets sync operation status
  Map<String, bool> getOperationStatus() {
    return Map.from(_operationStatus);
  }

  /// Checks if specific operation was successful
  bool isOperationSuccessful(String operation) {
    return _operationStatus[operation] ?? false;
  }

  /// Resets sync state (useful for logout)
  void resetSyncState() {
    _isSyncInProgress = false;
    _hasPerformedInitialSync = false;
    _currentSyncMessage = 'Inicializando sincronização...';
    _syncStatus = BackgroundSyncStatus.idle;
    _operationStatus.clear();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('🔄 BackgroundSync: Estado de sincronização resetado');
    }
  }

  /// Triggers manual sync for specific data type
  Future<void> syncSpecificData({
    required String userId,
    required String dataType,
  }) async {
    if (_isSyncInProgress) {
      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Sync específico ignorado - sync principal em progresso');
      }
      return;
    }

    _setSyncInProgress(true);
    _updateSyncStatus(BackgroundSyncStatus.syncing);

    try {
      switch (dataType) {
        case 'user':
          await _syncUserData(userId);
          break;
        case 'plants':
          await _syncPlantsData(userId);
          break;
        case 'tasks':
          await _syncTasksData(userId);
          break;
        case 'settings':
          await _syncSettingsData(userId);
          break;
        default:
          throw Exception('Tipo de dados não suportado: $dataType');
      }

      _updateSyncStatus(BackgroundSyncStatus.completed);

    } catch (e) {
      _updateSyncStatus(BackgroundSyncStatus.error);

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro no sync específico ($dataType): $e');
      }

    } finally {
      _setSyncInProgress(false);
    }
  }

  @override
  void dispose() {
    _syncMessageController.close();
    _syncProgressController.close();
    _syncStatusController.close();
    super.dispose();
  }
}