import 'dart:async';

/// Sync status states following SOLID principles
enum SyncStatus {
  idle,
  syncing,
  error,
  success,
  conflict,
  offline
}

/// Service responsible for sync status management following SOLID principles
/// 
/// Follows SRP: Single responsibility of status and message management
/// Follows OCP: Open for extension via additional status types
class SyncStatusManager {
  final StreamController<SyncStatus> _statusController = 
      StreamController<SyncStatus>.broadcast();
  
  final StreamController<String> _messageController = 
      StreamController<String>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<String> get messageStream => _messageController.stream;
  
  /// Exposes controllers for direct access (used internally)
  StreamController<SyncStatus> get statusController => _statusController;
  StreamController<String> get messageController => _messageController;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  String _currentMessage = '';
  String get currentMessage => _currentMessage;

  /// Updates sync status and notifies listeners
  void updateStatus(SyncStatus status) {
    if (_currentStatus == status) return;
    
    _currentStatus = status;
    
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  /// Updates sync message and notifies listeners
  void updateMessage(String message) {
    if (_currentMessage == message) return;
    
    _currentMessage = message;
    
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  /// Updates both status and message atomically
  void updateStatusAndMessage(SyncStatus status, String message) {
    updateStatus(status);
    updateMessage(message);
  }

  /// Gets user-friendly status description
  String getStatusDescription(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Aguardando sincronização';
      case SyncStatus.syncing:
        return 'Sincronizando dados...';
      case SyncStatus.error:
        return 'Erro na sincronização';
      case SyncStatus.success:
        return 'Sincronização concluída';
      case SyncStatus.conflict:
        return 'Conflito de dados detectado';
      case SyncStatus.offline:
        return 'Modo offline';
    }
  }

  /// Checks if currently syncing
  bool get isSyncing => _currentStatus == SyncStatus.syncing;

  /// Checks if has error
  bool get hasError => _currentStatus == SyncStatus.error;

  /// Checks if is offline
  bool get isOffline => _currentStatus == SyncStatus.offline;

  /// Checks if has conflicts
  bool get hasConflicts => _currentStatus == SyncStatus.conflict;

  /// Disposes all resources
  void dispose() {
    _statusController.close();
    _messageController.close();
  }
}