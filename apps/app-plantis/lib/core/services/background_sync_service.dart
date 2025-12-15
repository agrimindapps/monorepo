import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/settings/domain/usecases/sync_settings_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../sync/background_sync_status.dart';

/// Dedicated service for background synchronization operations
/// Pure business logic - no state management (state managed by Riverpod)
/// Separates sync concerns from authentication flow
class BackgroundSyncService {
  final GetPlantsUseCase? _getPlantsUseCase;
  final GetTasksUseCase? _getTasksUseCase;
  final SyncUserProfileUseCase? _syncUserProfileUseCase;
  final SyncSettingsUseCase? _syncSettingsUseCase;

  BackgroundSyncService({
    GetPlantsUseCase? getPlantsUseCase,
    GetTasksUseCase? getTasksUseCase,
    SyncUserProfileUseCase? syncUserProfileUseCase,
    SyncSettingsUseCase? syncSettingsUseCase,
  }) : _getPlantsUseCase = getPlantsUseCase,
       _getTasksUseCase = getTasksUseCase,
       _syncUserProfileUseCase = syncUserProfileUseCase,
       _syncSettingsUseCase = syncSettingsUseCase;

  /// Starts background synchronization for authenticated users
  /// Returns SyncResult with status and operation details
  Future<SyncResult> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 BackgroundSync: Iniciando sincronização REAL para usuário $userId',
        );
      }

      final operationResults = await _performSyncOperations(userId);

      if (kDebugMode) {
        debugPrint(
          '✅ BackgroundSync: Sincronização REAL completada com sucesso',
        );
      }

      return SyncResult(
        status: BackgroundSyncStatus.completed,
        message: 'Sincronização completada',
        operationStatus: operationResults,
        isInitialSync: isInitialSync,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro durante sincronização REAL: $e');
      }

      return SyncResult(
        status: BackgroundSyncStatus.error,
        message: 'Erro na sincronização: $e',
        operationStatus: {},
        isInitialSync: isInitialSync,
      );
    }
  }

  /// Performs all sync operations in background
  /// Returns Map with operation status for each data type
  Future<Map<String, bool>> _performSyncOperations(String userId) async {
    final results = <String, bool>{};

    results['user_data'] = await _syncUserData(userId);
    results['plants_data'] = await _syncPlantsData(userId);
    results['tasks_data'] = await _syncTasksData(userId);
    results['settings_data'] = await _syncSettingsData(userId);

    return results;
  }

  /// Sync user account data - REAL IMPLEMENTATION
  /// Returns true if successful, false otherwise
  Future<bool> _syncUserData(String userId) async {
    try {
      if (_syncUserProfileUseCase == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ BackgroundSync: SyncUserProfileUseCase não disponível',
          );
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('👤 BackgroundSync: Executando sync REAL do perfil...');
      }

      final result = await _syncUserProfileUseCase.call();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar perfil: ${failure.message}',
            );
          }
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ BackgroundSync: Perfil sincronizado - ${user?.email ?? "usuário anônimo"}',
            );
          }
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ BackgroundSync: Erro ao sincronizar dados do usuário: $e',
        );
      }
      return false;
    }
  }

  /// Sync plants data - REAL IMPLEMENTATION
  /// Returns true if successful, false otherwise
  Future<bool> _syncPlantsData(String userId) async {
    try {
      if (_getPlantsUseCase == null) {
        if (kDebugMode) {
          debugPrint('⚠️ BackgroundSync: GetPlantsUseCase não disponível');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('📱 BackgroundSync: Executando sync REAL das plantas...');
      }

      final result = await _getPlantsUseCase.call(const NoParams());

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar plantas: ${failure.message}',
            );
          }
          return false;
        },
        (plants) {
          if (kDebugMode) {
            debugPrint(
              '✅ BackgroundSync: ${plants.length} plantas sincronizadas com sucesso',
            );
          }
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar plantas: $e');
      }
      return false;
    }
  }

  /// Sync tasks data - REAL IMPLEMENTATION
  /// Returns true if successful, false otherwise
  Future<bool> _syncTasksData(String userId) async {
    try {
      if (_getTasksUseCase == null) {
        if (kDebugMode) {
          debugPrint('⚠️ BackgroundSync: GetTasksUseCase não disponível');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('📅 BackgroundSync: Executando sync REAL das tarefas...');
      }

      final result = await _getTasksUseCase.call(const NoParams());

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar tarefas: ${failure.message}',
            );
          }
          return false;
        },
        (tasks) {
          if (kDebugMode) {
            debugPrint(
              '✅ BackgroundSync: ${tasks.length} tarefas sincronizadas com sucesso',
            );
          }
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar tarefas: $e');
      }
      return false;
    }
  }

  /// Sync settings data - REAL IMPLEMENTATION
  /// Returns true if successful, false otherwise
  Future<bool> _syncSettingsData(String userId) async {
    try {
      if (_syncSettingsUseCase == null) {
        if (kDebugMode) {
          debugPrint('⚠️ BackgroundSync: SyncSettingsUseCase não disponível');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint(
          '⚙️ BackgroundSync: Executando sync REAL das configurações...',
        );
      }

      final result = await _syncSettingsUseCase.call();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ BackgroundSync: Falha ao sincronizar configurações: ${failure.message}',
            );
          }
          return false;
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ BackgroundSync: Configurações sincronizadas');
          }
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro ao sincronizar configurações: $e');
      }
      return false;
    }
  }

  /// Triggers manual sync for specific data type
  /// Returns SyncResult with operation status
  Future<SyncResult> syncSpecificData({
    required String userId,
    required String dataType,
  }) async {
    try {
      bool success;
      final operationResults = <String, bool>{};

      switch (dataType) {
        case 'user':
          success = await _syncUserData(userId);
          operationResults['user_data'] = success;
          break;
        case 'plants':
          success = await _syncPlantsData(userId);
          operationResults['plants_data'] = success;
          break;
        case 'tasks':
          success = await _syncTasksData(userId);
          operationResults['tasks_data'] = success;
          break;
        case 'settings':
          success = await _syncSettingsData(userId);
          operationResults['settings_data'] = success;
          break;
        default:
          throw Exception('Tipo de dados não suportado: $dataType');
      }

      return SyncResult(
        status: success
            ? BackgroundSyncStatus.completed
            : BackgroundSyncStatus.error,
        message: success
            ? 'Sync de $dataType completado'
            : 'Erro no sync de $dataType',
        operationStatus: operationResults,
        isInitialSync: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BackgroundSync: Erro no sync específico ($dataType): $e');
      }

      return SyncResult(
        status: BackgroundSyncStatus.error,
        message: 'Erro no sync específico: $e',
        operationStatus: {},
        isInitialSync: false,
      );
    }
  }
}

/// Result object returned by sync operations
class SyncResult {
  final BackgroundSyncStatus status;
  final String message;
  final Map<String, bool> operationStatus;
  final bool isInitialSync;

  const SyncResult({
    required this.status,
    required this.message,
    required this.operationStatus,
    required this.isInitialSync,
  });

  bool get isSuccess => status == BackgroundSyncStatus.completed;
  bool get hasErrors => status == BackgroundSyncStatus.error;
}
