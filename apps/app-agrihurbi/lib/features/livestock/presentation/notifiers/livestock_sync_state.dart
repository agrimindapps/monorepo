import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestock_sync_state.freezed.dart';

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  cancelled,
}

/// Immutable state for livestock synchronization
@freezed
abstract class LivestockSyncState with _$LivestockSyncState {
  const LivestockSyncState._();
  const factory LivestockSyncState({
    @Default(false) bool isSyncing,
    @Default(null) DateTime? lastSyncTime,
    @Default(null) String? errorMessage,
    @Default(SyncStatus.idle) SyncStatus syncStatus,
    @Default(0.0) double syncProgress,
  }) = _LivestockSyncState;
}
