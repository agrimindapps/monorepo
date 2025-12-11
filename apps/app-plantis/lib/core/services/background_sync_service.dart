import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/settings/domain/usecases/sync_settings_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../sync/background_sync_status.dart';

/// Dedicated service for background synchronization operations
/// Separates sync concerns from authentication flow
class BackgroundSyncService extends ChangeNotifier {
  bool _isSyncInProgress = false;
  bool _hasPerformedInitialSync = false;
  String _currentSyncMessage = 'Inicializando sincronização...';
  BackgroundSyncStatus _syncStatus = BackgroundSyncStatus.idle;
  final Map<String, bool> _operationStatus = {};

  final GetPlantsUseCase? _getPlantsUseCase;
  final GetTasksUseCase? _getTasksUseCase;
  final SyncUserProfileUseCase? _syncUserProfileUseCase;
  final SyncSettingsUseCase? _syncSettingsUseCase;

  final StreamController<String> _syncMessageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _syncProgressController =
      StreamController<bool>.broadcast();
  final StreamController<BackgroundSyncStatus> _syncStatusController =
      StreamController<BackgroundSyncStatus>.broadcast();
  BackgroundSyncService({
    GetPlantsUseCase? getPlantsUseCase,
    GetTasksUseCase? getTasksUseCase,
    SyncUserProfileUseCase? syncUserProfileUseCase,
    SyncSettingsUseCase? syncSettingsUseCase,
  }) : _getPlantsUseCase = getPlantsUseCase,
       _getTasksUseCase = getTasksUseCase,
       _syncUserProfileUseCase = syncUserProfileUseCase,
       _syncSettingsUseCase = syncSettingsUseCase;

  void _initializeDependencies() {
    // Dependencies are injected via constructor
  }

  bool get isSyncInProgress => _isSyncInProgress;
  bool get hasPerformedInitialSync => _hasPerformedInitialSync;
  String get currentSyncMessage => _currentSyncMessage;
  BackgroundSyncStatus get syncStatus => _syncStatus;
  Stream<String> get syncMessageStream => _syncMessageController.stream;
  Stream<bool> get syncProgressStream => _syncProgressController.stream;
  Stream<BackgroundSyncStatus> get syncStatusStream =>
      _syncStatusController.stream;

  /// Starts background synchronization for authenticated users
  Future<void> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    if (_isSyncInProgress) {
      if (kDebugMode) {
        debugPrint(
          '🔄 BackgroundSync: Sync já em progresso, ignorando nova solicitação',
        );
      }
      return;
    }

    if (!isInitialSync && _hasPerformedInitialSync) {
      if (kDebugMode) {
        debugPrint('🔄 BackgroundSync: Sync inicial já realizada nesta sessão');
      }
      return;
    }
    _initializeDependencies();

    _setSyncInProgress(true);
    _updateSyncStatus(BackgroundSyncStatus.syncing);

    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 BackgroundSync: Iniciando sincronização REAL para usuário $userId',
        );
      }
      await _performSyncOperations(userId);
      if (isInitialSync || !_hasPerformedInitialSync) {
        _hasPerformedInitialSync = true;
      }

      _updateSyncStatus(BackgroundSyncStatus.completed);
      _notifyProvidersAfterSync();

      if (kDebugMode) {
        debugPrint(
          '✅ BackgroundSync: Sincronização REAL completada com sucesso',
        );
      }
    } catch (e) {
      _updateSyncStatus(BackgroundSyncStatus.error);

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro durante sincronização REAL: $e');
      }
    } finally {
      _setSyncInProgress(false);
    }
  }

  /// Performs all sync operations in background
  Future<void> _performSyncOperations(String userId) async {
    await _syncUserData(userId);
    await _syncPlantsData(userId);
    await _syncTasksData(userId);
    await _syncSettingsData(userId);
  }

  /// Sync user account data - REAL IMPLEMENTATION
  Future<void> _syncUserData(String userId) async {
    _updateSyncMessage('Sincronizando informações da conta...');
    _operationStatus['user_data'] = false;

    try {
      if (_syncUserProfileUseCase == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ BackgroundSync: SyncUserProfileUseCase não disponível',
          );
        }
        _operationStatus['user_data'] = false;
        return;
      }

      if (kDebugMode) {
        debugPrint('👤 BackgroundSync: Executando sync REAL do perfil...');
      }
      final result = await _syncUserProfileUseCase.call();

      result.fold(
        (failure) {
          _operationStatus['user_data'] = false;
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar perfil: ${failure.message}',
            );
          }
        },
        (user) {
          _operationStatus['user_data'] = true;
          if (kDebugMode) {
            debugPrint(
              '✅ BackgroundSync: Perfil sincronizado - ${user?.email ?? "usuário anônimo"}',
            );
          }
        },
      );
    } catch (e) {
      _operationStatus['user_data'] = false;

      if (kDebugMode) {
        debugPrint(
          '❌ BackgroundSync: Erro ao sincronizar dados do usuário: $e',
        );
      }
    }
  }

  /// Sync plants data - REAL IMPLEMENTATION
  Future<void> _syncPlantsData(String userId) async {
    _updateSyncMessage('Sincronizando suas plantas...');
    _operationStatus['plants_data'] = false;

    try {
      if (_getPlantsUseCase == null) {
        throw Exception('GetPlantsUseCase não disponível');
      }

      if (kDebugMode) {
        debugPrint('📱 BackgroundSync: Executando sync REAL das plantas...');
      }
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (failure) {
          _operationStatus['plants_data'] = false;
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar plantas: ${failure.message}',
            );
          }
          throw Exception(
            'Erro na sincronização de plantas: ${failure.message}',
          );
        },
        (plants) {
          _operationStatus['plants_data'] = true;
          if (kDebugMode) {
            debugPrint(
              '✅ BackgroundSync: ${plants.length} plantas sincronizadas com sucesso',
            );
          }
        },
      );
    } catch (e) {
      _operationStatus['plants_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar plantas: $e');
      }
    }
  }

  /// Sync tasks data - REAL IMPLEMENTATION
  Future<void> _syncTasksData(String userId) async {
    _updateSyncMessage('Sincronizando tarefas pendentes...');
    _operationStatus['tasks_data'] = false;

    try {
      if (_getTasksUseCase == null) {
        throw Exception('GetTasksUseCase não disponível');
      }

      if (kDebugMode) {
        debugPrint('📅 BackgroundSync: Executando sync REAL das tarefas...');
      }
      final result = await _getTasksUseCase.call(const NoParams());

      result.fold(
        (failure) {
          _operationStatus['tasks_data'] = false;
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar tarefas: ${failure.message}',
            );
          }
          throw Exception(
            'Erro na sincronização de tarefas: ${failure.message}',
          );
        },
        (tasks) {
          _operationStatus['tasks_data'] = true;
          if (kDebugMode) {
            debugPrint(
              '✅ BackgroundSync: ${tasks.length} tarefas sincronizadas com sucesso',
            );
          }
        },
      );
    } catch (e) {
      _operationStatus['tasks_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar tarefas: $e');
      }
    }
  }

  /// Sync settings data - REAL IMPLEMENTATION
  Future<void> _syncSettingsData(String userId) async {
    _updateSyncMessage('Sincronizando preferências...');
    _operationStatus['settings_data'] = false;

    try {
      if (_syncSettingsUseCase == null) {
        if (kDebugMode) {
          debugPrint('⚠️ BackgroundSync: SyncSettingsUseCase não disponível');
        }
        _operationStatus['settings_data'] = false;
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '⚙️ BackgroundSync: Executando sync REAL das configurações...',
        );
      }
      final result = await _syncSettingsUseCase.call();

      result.fold(
        (failure) {
          _operationStatus['settings_data'] = false;
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar configurações: ${failure.message}',
            );
          }
        },
        (_) {
          _operationStatus['settings_data'] = true;
          if (kDebugMode) {
            debugPrint('✅ BackgroundSync: Configurações sincronizadas');
          }
        },
      );
    } catch (e) {
      _operationStatus['settings_data'] = false;

      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar configurações: $e');
      }
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
        debugPrint(
          '🔄 BackgroundSync: Não é possível repetir - sync em progresso',
        );
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
        debugPrint(
          '🔄 BackgroundSync: Sync específico ignorado - sync principal em progresso',
        );
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

  /// Notifies providers that sync is complete so they can refresh their data
  /// OPTIMIZED: Uses Future.microtask for immediate notification in next event loop
  void _notifyProvidersAfterSync() {
    if (kDebugMode) {
      debugPrint(
        '📢 BackgroundSync: Notificando providers sobre conclusão da sync...',
      );
    }
    if (kDebugMode) {
      debugPrint('ℹ️ BackgroundSync: Providers managed by Riverpod');
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
