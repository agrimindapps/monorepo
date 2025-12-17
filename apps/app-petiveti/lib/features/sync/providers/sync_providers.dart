import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/interfaces/usecase.dart';
import '../../../core/sync/petiveti_sync_service.dart';
import '../data/datasources/sync_local_datasource.dart';
import '../data/datasources/sync_remote_datasource.dart';
import '../data/repositories/sync_repository_impl.dart';
import '../domain/entities/sync_conflict.dart';
import '../domain/entities/sync_operation.dart';
import '../domain/entities/sync_status.dart';
import '../domain/repositories/sync_repository.dart';
import '../domain/usecases/force_sync_usecase.dart';
import '../domain/usecases/get_sync_conflicts_usecase.dart';
import '../domain/usecases/get_sync_history_usecase.dart';
import '../domain/usecases/get_sync_status_usecase.dart';
import '../domain/usecases/resolve_sync_conflict_usecase.dart';

part 'sync_providers.g.dart';

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
SyncRemoteDataSource syncRemoteDataSource(Ref ref) {
  return SyncRemoteDataSourceImpl(PetivetiSyncService.instance);
}

@riverpod
Future<SyncLocalDataSource> syncLocalDataSource(
  Ref ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  return SyncLocalDataSourceImpl(prefs);
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
Future<ISyncRepository> syncRepository(Ref ref) async {
  final localDataSource = await ref.watch(syncLocalDataSourceProvider.future);
  return SyncRepositoryImpl(
    remoteDataSource: ref.watch(syncRemoteDataSourceProvider),
    localDataSource: localDataSource,
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
Future<GetSyncStatusUseCase> getSyncStatusUseCase(
  Ref ref,
) async {
  final repository = await ref.watch(syncRepositoryProvider.future);
  return GetSyncStatusUseCase(repository);
}

@riverpod
Future<ForceSyncUseCase> forceSyncUseCase(Ref ref) async {
  final repository = await ref.watch(syncRepositoryProvider.future);
  return ForceSyncUseCase(repository);
}

@riverpod
Future<GetSyncHistoryUseCase> getSyncHistoryUseCase(
  Ref ref,
) async {
  final repository = await ref.watch(syncRepositoryProvider.future);
  return GetSyncHistoryUseCase(repository);
}

@riverpod
Future<GetSyncConflictsUseCase> getSyncConflictsUseCase(
  Ref ref,
) async {
  final repository = await ref.watch(syncRepositoryProvider.future);
  return GetSyncConflictsUseCase(repository);
}

@riverpod
Future<ResolveSyncConflictUseCase> resolveSyncConflictUseCase(
  Ref ref,
) async {
  final repository = await ref.watch(syncRepositoryProvider.future);
  return ResolveSyncConflictUseCase(repository);
}

// ============================================================================
// NOTIFIERS & STATE
// ============================================================================

/// State for sync status
class SyncStatusState {
  final Map<String, SyncStatus> statusByEntity;
  final bool isLoading;
  final String? error;

  const SyncStatusState({
    this.statusByEntity = const {},
    this.isLoading = false,
    this.error,
  });

  SyncStatusState copyWith({
    Map<String, SyncStatus>? statusByEntity,
    bool? isLoading,
    String? error,
  }) {
    return SyncStatusState(
      statusByEntity: statusByEntity ?? this.statusByEntity,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for sync status
@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  @override
  SyncStatusState build() {
    loadSyncStatus();
    return const SyncStatusState();
  }

  /// Load sync status for all entities
  Future<void> loadSyncStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = await ref.read(getSyncStatusUseCaseProvider.future);
    final result = await useCase(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (statusMap) => state = state.copyWith(
        statusByEntity: statusMap,
        isLoading: false,
        error: null,
      ),
    );
  }

  /// Force sync for specific entity or all
  Future<void> forceSync({String? entityType}) async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = await ref.read(forceSyncUseCaseProvider.future);
    final result = await useCase(ForceSyncParams(entityType: entityType));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) {
        // Reload status after sync
        loadSyncStatus();
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// DERIVED PROVIDERS
// ============================================================================

/// Watch sync status stream
@riverpod
Stream<Map<String, SyncStatus>> syncStatusStream(Ref ref) async* {
  final repository = await ref.watch(syncRepositoryProvider.future);
  yield* repository.watchSyncStatus();
}

/// Get sync history
@riverpod
Future<List<SyncOperation>> syncHistory(
  Ref ref, {
  int limit = 50,
  String? entityType,
}) async {
  final useCase = await ref.watch(getSyncHistoryUseCaseProvider.future);
  final result = await useCase(GetSyncHistoryParams(
    limit: limit,
    entityType: entityType,
  ));

  return result.fold(
    (_) => <SyncOperation>[],
    (history) => history,
  );
}

/// Get sync conflicts
@riverpod
Future<List<SyncConflict>> syncConflicts(
  Ref ref, {
  String? entityType,
}) async {
  final useCase = await ref.watch(getSyncConflictsUseCaseProvider.future);
  final result = await useCase(GetSyncConflictsParams(entityType: entityType));

  return result.fold(
    (_) => <SyncConflict>[],
    (conflicts) => conflicts,
  );
}
