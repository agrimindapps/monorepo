import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_services_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../animals/domain/repositories/isync_manager.dart';
import '../../animals/data/sync/unified_sync_manager.dart';

part 'sync_providers.g.dart';

/// Provider for sync manager
@riverpod
ISyncManager syncManager(SyncManagerRef ref) {
  return UnifiedSyncManager(
    firestore: ref.watch(firebaseFirestoreProvider),
    authRepository: ref.watch(authRepositoryProvider),
    analyticsRepository: ref.watch(analyticsRepositoryProvider),
  );
}
