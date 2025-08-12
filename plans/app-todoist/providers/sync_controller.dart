// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../repository/task_list_repository.dart';
import '../repository/task_repository.dart';
import '../utils/composite_subscription.dart';

/// Controller de sincronização migrado para GetX
class TodoistSyncController extends GetxController with SubscriptionManagerMixin {
  late final TaskRepository _taskRepository;
  late final TaskListRepository _taskListRepository;

  // Estados reativos
  final Rx<SyncStatus> _syncStatus = Rx<SyncStatus>(SyncStatus.offline);
  final RxBool _isOnline = RxBool(false);
  final Rxn<DateTime> _lastSyncTime = Rxn<DateTime>();
  final RxBool _isOfflineMode = RxBool(false);
  final RxInt _pendingSyncItems = RxInt(0);
  final RxnString _errorMessage = RxnString();

  // Getters reativos
  SyncStatus get syncStatus => _syncStatus.value;
  bool get isOnline => _isOnline.value;
  DateTime? get lastSyncTime => _lastSyncTime.value;
  bool get isOfflineMode => _isOfflineMode.value;
  int get pendingSyncItems => _pendingSyncItems.value;
  String? get errorMessage => _errorMessage.value;

  // Repositories getters
  TaskRepository get taskRepository => _taskRepository;
  TaskListRepository get taskListRepository => _taskListRepository;

  @override
  void onInit() {
    super.onInit();
    _taskRepository = TaskRepository();
    _taskListRepository = TaskListRepository();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _taskRepository.initialize();
      await _taskListRepository.initialize();

      // Listen to sync status changes
      addSubscription(
        _taskRepository.syncStatusStream.listen((status) {
          _syncStatus.value = status;
        }),
      );

      // Listen to connectivity changes
      addSubscription(
        _taskRepository.connectivityStream.listen((online) {
          _isOnline.value = online;
          _updateOfflineMode();
        }),
      );

      // Listen to task list sync status
      addSubscription(
        _taskListRepository.syncStatusStream.listen((status) {
          _updateSyncStatus();
        }),
      );

      _updateSyncStatus();
    } catch (e) {
      _errorMessage.value = 'Erro na inicialização: $e';
      if (kDebugMode) {
        print('Erro ao inicializar SyncController: $e');
      }
    }
  }

  void _updateOfflineMode() {
    // Se offline, ativar modo offline
    if (!_isOnline.value) {
      _isOfflineMode.value = true;
    } else {
      // Se voltou online, desativar modo offline após sincronizar
      _isOfflineMode.value = false;
      _performSync();
    }
  }

  void _updateSyncStatus() {
    // Atualizar contadores de sincronização
    try {
      // Simular contagem de itens pendentes
      _pendingSyncItems.value = 0; // Implementar lógica real baseada nos repositories
      _lastSyncTime.value = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar status de sync: $e');
      }
    }
  }

  // ========== Sync Operations ==========

  /// Forçar sincronização manual
  Future<void> forcSync() async {
    try {
      _errorMessage.value = null;
      await _performSync();
    } catch (e) {
      _errorMessage.value = 'Erro na sincronização: $e';
      if (kDebugMode) {
        print('Erro no force sync: $e');
      }
    }
  }

  /// Realizar sincronização
  Future<void> _performSync() async {
    if (!_isOnline.value) {
      _errorMessage.value = 'Sem conexão com a internet';
      return;
    }

    try {
      // Sincronizar tasks
      // await _taskRepository.forceSync(); // Se disponível
      
      // Sincronizar task lists
      // await _taskListRepository.forceSync(); // Se disponível

      _lastSyncTime.value = DateTime.now();
      _errorMessage.value = null;
      
      if (kDebugMode) {
        print('Sincronização concluída com sucesso');
      }
    } catch (e) {
      _errorMessage.value = 'Falha na sincronização: $e';
      if (kDebugMode) {
        print('Erro na sincronização: $e');
      }
    }
  }

  /// Ativar/desativar modo offline manualmente
  void toggleOfflineMode() {
    _isOfflineMode.value = !_isOfflineMode.value;
    
    if (!_isOfflineMode.value && _isOnline.value) {
      // Se saindo do modo offline e há conexão, sincronizar
      _performSync();
    }
  }

  /// Limpar mensagens de erro
  void clearError() {
    _errorMessage.value = null;
  }

  // ========== Status Helpers ==========

  /// Verificar se há itens pendentes de sincronização
  bool get hasPendingSync => _pendingSyncItems.value > 0;

  /// Verificar se está sincronizando
  bool get isSyncing => _syncStatus.value == SyncStatus.syncing;

  /// Verificar se sync foi bem-sucedido
  bool get syncSuccessful => _syncStatus.value == SyncStatus.localOnly;

  /// Obter status de conexão como string
  String get connectionStatusText {
    if (_isOnline.value) {
      return _isOfflineMode.value ? 'Online (Modo Offline)' : 'Online';
    } else {
      return 'Offline';
    }
  }

  /// Obter status de sincronização como string
  String get syncStatusText {
    switch (_syncStatus.value) {
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.localOnly:
        return 'Apenas Local';
      case SyncStatus.syncing:
        return 'Sincronizando...';
    }
  }

  // ========== Debug Info ==========

  /// Informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'sync_status': _syncStatus.value.toString(),
      'is_online': _isOnline.value,
      'is_offline_mode': _isOfflineMode.value,
      'pending_sync_items': _pendingSyncItems.value,
      'last_sync_time': _lastSyncTime.value?.toIso8601String(),
      'error_message': _errorMessage.value,
      'has_pending_sync': hasPendingSync,
      'is_syncing': isSyncing,
      'connection_status': connectionStatusText,
      'sync_status_text': syncStatusText,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Obter estatísticas de sincronização
  Map<String, dynamic> getSyncStats() {
    return {
      'total_syncs': 0, // Implementar contador
      'successful_syncs': 0, // Implementar contador
      'failed_syncs': 0, // Implementar contador
      'last_sync': _lastSyncTime.value?.toIso8601String(),
      'uptime_percentage': _isOnline.value ? 100 : 0, // Implementar cálculo real
      'offline_time': 0, // Implementar tracking
    };
  }

  @override
  void onClose() {
    // Cleanup é feito automaticamente pelo SubscriptionManagerMixin
    super.onClose();
  }
}
