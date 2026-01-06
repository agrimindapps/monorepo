import 'package:core/core.dart' hide SyncEvent;

import '../../domain/repositories/isync_manager.dart';

/// No-op implementation of ISyncManager for compilation
/// TODO: Implement proper sync manager or integrate with core
class NoOpSyncManager implements ISyncManager {
  const NoOpSyncManager();

  @override
  Future<void> triggerBackgroundSync(String moduleName) async {
    // No-op
  }

  @override
  Future<Either<Failure, void>> forceSync(String moduleName) async {
    return right(null);
  }

  @override
  bool get isSyncing => false;

  @override
  Stream<SyncEvent> get syncEvents => const Stream.empty();
}
