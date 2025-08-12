// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../repository/task_list_repository.dart';
import '../repository/task_repository.dart';
import '../utils/composite_subscription.dart';

/// Provider que encapsula os serviços de sincronização para uso com Provider pattern
class SyncProvider extends ChangeNotifier with SubscriptionManagerMixin {
  late final TaskRepository _taskRepository;
  late final TaskListRepository _taskListRepository;

  SyncStatus _syncStatus = SyncStatus.offline;
  bool _isOnline = false;
  DateTime? _lastSyncTime;
  bool _isOfflineMode = false;
  final int _pendingSyncItems = 0;
  String? _errorMessage;

  SyncProvider() {
    _taskRepository = TaskRepository();
    _taskListRepository = TaskListRepository();
    _initialize();
  }

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isOfflineMode => _isOfflineMode;
  int get pendingSyncItems => _pendingSyncItems;
  String? get errorMessage => _errorMessage;

  // Repositories getters
  TaskRepository get taskRepository => _taskRepository;
  TaskListRepository get taskListRepository => _taskListRepository;

  Future<void> _initialize() async {
    try {
      await _taskRepository.initialize();
      await _taskListRepository.initialize();

      // Listen to sync status changes
      listenTo(_taskRepository.syncStatusStream, (status) {
        _syncStatus = status;
        notifyListeners();
      });

      // Listen to connectivity changes
      listenTo(_taskRepository.connectivityStream, (online) {
        _isOnline = online;
        notifyListeners();
      });
    } catch (e) {}
  }

  /// Força sincronização manual
  Future<void> forceSync() async {
    try {
      await Future.wait([
        _taskRepository.forceSync(),
        _taskListRepository.forceSync(),
      ]);

      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {}
  }

  /// Limpa dados locais
  Future<void> clearLocalData() async {
    try {
      await Future.wait([
        _taskRepository.clear(),
        _taskListRepository.clear(),
      ]);

      notifyListeners();
    } catch (e) {}
  }

  /// Toggle offline mode
  void toggleOfflineMode(bool value) {
    _isOfflineMode = value;
    notifyListeners();
  }

  /// Sync all data
  Future<void> syncAll() => forceSync();

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'totalItems': 0, // Could be calculated from repositories
      'lastSync': _lastSyncTime?.toIso8601String(),
      'syncStatus': _syncStatus.toString(),
    };
  }

  /// Clear all data (alias for clearLocalData)
  Future<void> clearAllData() => clearLocalData();

  @override
  void dispose() {
    // Dispose all stream subscriptions to prevent memory leaks
    disposeSubscriptions();

    // Dispose repositories
    _taskRepository.dispose();
    _taskListRepository.dispose();

    super.dispose();
  }
}
