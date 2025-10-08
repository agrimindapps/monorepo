import 'package:core/core.dart' show Provider, BaseSyncEntity;

import 'financial_sync_service.dart';

/// Mock implementation of FinancialSyncService for development
class _MockFinancialSyncService implements FinancialSyncService {
  @override
  FinancialSyncStatus getSyncStatus(String entityId) {
    // Return synced status for all entities in mock mode
    return FinancialSyncStatus.synced;
  }

  @override
  Stream<FinancialSyncStatus> watchSyncStatus(String entityId) {
    // Return a stream that stays synced
    return Stream.value(FinancialSyncStatus.synced);
  }

  @override
  Future<FinancialSyncResult> syncEntity(String entityId) async {
    // Mock successful sync
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return FinancialSyncResult.success(
      attemptCount: 1,
      totalTime: const Duration(milliseconds: 100),
    );
  }

  @override
  Future<FinancialSyncResult> syncAllPending() async {
    // Mock successful sync
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return FinancialSyncResult.success(
      attemptCount: 1,
      totalTime: const Duration(milliseconds: 200),
    );
  }

  @override
  Future<void> cancelSync(String entityId) async {
    // Mock cancellation
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> retryFailedSyncs() async {
    // Mock retry
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<String>> getPendingSyncEntities() async {
    // Return empty list in mock mode
    return [];
  }

  @override
  Future<List<String>> getFailedSyncEntities() async {
    // Return empty list in mock mode
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSyncStatistics() async {
    return {
      'totalSynced': 0,
      'pendingSync': 0,
      'failedSync': 0,
      'lastSyncTime': null,
    };
  }

  @override
  Future<FinancialSyncResult> queueForSync(BaseSyncEntity entity) async {
    // Mock successful queue
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return FinancialSyncResult.success(
      attemptCount: 1,
      totalTime: const Duration(milliseconds: 50),
    );
  }

  @override
  Future<FinancialSyncResult> syncImmediately(BaseSyncEntity entity) async {
    // Mock successful immediate sync
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return FinancialSyncResult.success(
      attemptCount: 1,
      totalTime: const Duration(milliseconds: 100),
    );
  }

  @override
  int get pendingFinancialSyncCount => 0;

  @override
  int get highPriorityPendingCount => 0;

  @override
  DateTime? get lastSuccessfulSync =>
      DateTime.now().subtract(const Duration(hours: 1));

  @override
  Map<String, dynamic> getQueueStats() {
    return {'queueLength': 0, 'processingItems': 0, 'failedItems': 0};
  }

  @override
  Future<void> clearFailedItems() async {
    // Mock clearing
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> initialize() async {
    // Mock initialization
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> dispose() async {
    // Mock disposal
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

final financialSyncServiceProvider = Provider<FinancialSyncService>((ref) {
  // Return mock implementation until real service is configured
  return _MockFinancialSyncService();
});
