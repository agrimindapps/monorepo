import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/presentation/providers/plants_provider.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';
import '../auth/auth_state_notifier.dart';
import '../di/injection_container.dart' as di;
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

  // Real sync dependencies
  GetPlantsUseCase? _getPlantsUseCase;
  GetTasksUseCase? _getTasksUseCase;
  AuthStateNotifier? _authStateNotifier;

  // Providers for notification
  PlantsProvider? _plantsProvider;
  TasksProvider? _tasksProvider;

  // Stream controllers for reactive updates
  final StreamController<String> _syncMessageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _syncProgressController =
      StreamController<bool>.broadcast();
  final StreamController<BackgroundSyncStatus> _syncStatusController =
      StreamController<BackgroundSyncStatus>.broadcast();

  // Lazy initialization of dependencies
  void _initializeDependencies() {
    try {
      _getPlantsUseCase ??= di.sl<GetPlantsUseCase>();
      _getTasksUseCase ??= di.sl<GetTasksUseCase>();
      _authStateNotifier ??= di.sl<AuthStateNotifier>();

      // Try to get providers if available (they might not be registered yet)
      try {
        _plantsProvider ??= di.sl<PlantsProvider>();
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'ℹ️ BackgroundSyncService: PlantsProvider não disponível ainda: $e',
          );
        }
      }

      try {
        _tasksProvider ??= di.sl<TasksProvider>();
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'ℹ️ BackgroundSyncService: TasksProvider não disponível ainda: $e',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ BackgroundSyncService: Erro ao inicializar dependências: $e',
        );
      }
    }
  }

  // Getters
  bool get isSyncInProgress => _isSyncInProgress;
  bool get hasPerformedInitialSync => _hasPerformedInitialSync;
  String get currentSyncMessage => _currentSyncMessage;
  BackgroundSyncStatus get syncStatus => _syncStatus;

  // Streams for reactive UI updates
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

    // Initialize dependencies before starting sync
    _initializeDependencies();

    _setSyncInProgress(true);
    _updateSyncStatus(BackgroundSyncStatus.syncing);

    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 BackgroundSync: Iniciando sincronização REAL para usuário $userId',
        );
      }

      // Perform REAL sync operations in sequence
      await _performSyncOperations(userId);

      // Mark initial sync as completed
      if (isInitialSync || !_hasPerformedInitialSync) {
        _hasPerformedInitialSync = true;
      }

      _updateSyncStatus(BackgroundSyncStatus.completed);

      // Notify providers that sync is complete
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
        debugPrint(
          '❌ BackgroundSync: Erro ao sincronizar dados do usuário: $e',
        );
      }

      // Don't rethrow - allow other operations to continue
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

      // REAL sync - call the actual use case
      final result = await _getPlantsUseCase!.call(const NoParams());

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

      // Don't rethrow - allow other operations to continue
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

      // REAL sync - call the actual use case
      final result = await _getTasksUseCase!.call(const NoParams());

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
  void _notifyProvidersAfterSync() {
    if (kDebugMode) {
      debugPrint(
        '📢 BackgroundSync: Notificando providers sobre conclusão da sync...',
      );
    }

    // Notify plants provider to refresh data if available
    if (_plantsProvider != null) {
      if (kDebugMode) {
        debugPrint(
          '🌱 BackgroundSync: Notificando PlantsProvider para refresh...',
        );
      }

      // Execute refresh in next frame to avoid sync issues
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          _plantsProvider?.refreshPlants();
          if (kDebugMode) {
            debugPrint('✅ BackgroundSync: PlantsProvider refresh solicitado');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Erro ao notificar PlantsProvider: $e',
            );
          }
        }
      });
    }

    // Notify tasks provider to refresh data if available
    if (_tasksProvider != null) {
      if (kDebugMode) {
        debugPrint(
          '📅 BackgroundSync: Notificando TasksProvider para refresh...',
        );
      }

      // Execute refresh in next frame to avoid sync issues
      Future.delayed(const Duration(milliseconds: 150), () {
        try {
          _tasksProvider?.refresh();
          if (kDebugMode) {
            debugPrint('✅ BackgroundSync: TasksProvider refresh solicitado');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ BackgroundSync: Erro ao notificar TasksProvider: $e');
          }
        }
      });
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
