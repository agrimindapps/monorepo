import 'package:equatable/equatable.dart';

enum SyncState {
  pending,
  syncing,
  synced,
  error,
}

class SyncStatus extends Equatable {
  final SyncState state;
  final String? errorMessage;
  final DateTime lastSyncedAt;

  const SyncStatus({
    required this.state,
    this.errorMessage,
    required this.lastSyncedAt,
  });

  factory SyncStatus.pending() {
    return SyncStatus(
      state: SyncState.pending,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory SyncStatus.syncing() {
    return SyncStatus(
      state: SyncState.syncing,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory SyncStatus.synced() {
    return SyncStatus(
      state: SyncState.synced,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory SyncStatus.error(String message) {
    return SyncStatus(
      state: SyncState.error,
      errorMessage: message,
      lastSyncedAt: DateTime.now(),
    );
  }

  bool get isPending => state == SyncState.pending;
  bool get isSyncing => state == SyncState.syncing;
  bool get isSynced => state == SyncState.synced;
  bool get hasError => state == SyncState.error;

  @override
  List<Object?> get props => [state, errorMessage, lastSyncedAt];
}
