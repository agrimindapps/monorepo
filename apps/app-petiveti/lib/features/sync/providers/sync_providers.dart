import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_services_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../animals/domain/repositories/isync_manager.dart';
// TODO: Restore when unified_sync_manager is implemented
// import '../../animals/data/sync/unified_sync_manager.dart';

// part 'sync_providers.g.dart'; // Commented out until provider is restored

/// Provider for sync manager
/// TODO: Temporarily commented out - needs UnifiedSyncManager implementation
// @riverpod
// ISyncManager syncManager(SyncManagerRef ref) {
//   return UnifiedSyncManager(
//     firestore: ref.watch(firebaseFirestoreProvider),
//     authRepository: ref.watch(authRepositoryProvider),
//     analyticsRepository: ref.watch(analyticsRepositoryProvider),
//   );
// }
