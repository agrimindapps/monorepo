import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_notifier.dart';

/// Manages premium synchronization and subscription state
class PremiumSyncManager {
  final Ref ref;

  PremiumSyncManager(this.ref);

  /// Force synchronize subscription with server
  Future<void> forceSyncSubscription() async {
    final notifier = ref.read(premiumNotifierProvider.notifier);
    await notifier.forceSyncSubscription();
  }

  /// Clear sync errors
  void clearSyncErrors() {
    final notifier = ref.read(premiumNotifierProvider.notifier);
    notifier.clearSyncErrors();
  }

  /// Check if sync is in progress
  bool isSyncing(PremiumState state) {
    return state.isSyncing;
  }

  /// Check if sync has errors
  bool hasSyncErrors(PremiumState state) {
    return state.hasSyncErrors;
  }

  /// Get sync error message
  String? getSyncErrorMessage(PremiumState state) {
    return state.syncErrorMessage;
  }

  /// Get last sync time
  DateTime? getLastSyncTime(PremiumState state) {
    return state.lastSyncAt;
  }

  /// Check if subscription needs sync
  bool needsSync(PremiumState state) {
    if (state.lastSyncAt == null) return true;

    final now = DateTime.now();
    final lastSync = state.lastSyncAt!;
    final difference = now.difference(lastSync);

    // Sync needed if last sync was more than 1 hour ago
    return difference.inHours > 1;
  }

  /// Get sync retry count
  int getSyncRetryCount(PremiumState state) {
    return state.syncRetryCount;
  }

  /// Should auto-retry sync
  bool shouldAutoRetry(PremiumState state) {
    return state.syncRetryCount < 3;
  }

  /// Get debug info for sync status
  Map<String, dynamic> getDebugInfo(PremiumState state) {
    return {
      'isSyncing': state.isSyncing,
      'hasSyncErrors': state.hasSyncErrors,
      'lastSyncAt': state.lastSyncAt?.toIso8601String(),
      'syncError': state.syncErrorMessage,
      'retryCount': state.syncRetryCount,
    };
  }
}
