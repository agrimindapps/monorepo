import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/defensivos/domain/entities/defensivo.dart';
import '../../../features/pragas/domain/entities/praga.dart';
import '../../data/datasources/recent_access_local_datasource.dart';
import '../../data/repositories/recent_access_repository_impl.dart';
import '../../domain/entities/recent_access.dart';
import '../../domain/repositories/recent_access_repository.dart';
import '../../domain/usecases/add_recent_access_usecase.dart';
import '../../domain/usecases/get_recent_defensivos_usecase.dart';
import '../../domain/usecases/get_recent_pragas_usecase.dart';
import '../../interfaces/usecase.dart';

part 'recent_access_provider.g.dart';

// ============================================================================
// DEPENDENCY PROVIDERS
// ============================================================================

/// SharedPreferences provider - initialized at app startup
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden with a ProviderScope at app startup',
  );
}

/// Recent access local data source provider
@riverpod
RecentAccessLocalDataSource recentAccessLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecentAccessLocalDataSourceImpl(prefs);
}

/// Recent access repository provider
@riverpod
RecentAccessRepository recentAccessRepository(Ref ref) {
  final dataSource = ref.watch(recentAccessLocalDataSourceProvider);
  return RecentAccessRepositoryImpl(dataSource);
}

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

@riverpod
GetRecentDefensivosUseCase getRecentDefensivosUseCase(Ref ref) {
  final repository = ref.watch(recentAccessRepositoryProvider);
  return GetRecentDefensivosUseCase(repository);
}

@riverpod
GetRecentPragasUseCase getRecentPragasUseCase(Ref ref) {
  final repository = ref.watch(recentAccessRepositoryProvider);
  return GetRecentPragasUseCase(repository);
}

@riverpod
AddRecentAccessUseCase addRecentAccessUseCase(Ref ref) {
  final repository = ref.watch(recentAccessRepositoryProvider);
  return AddRecentAccessUseCase(repository);
}

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// State for recent access management
class RecentAccessState {
  final List<RecentAccess> recentDefensivos;
  final List<RecentAccess> recentPragas;
  final bool isLoading;
  final String? error;

  const RecentAccessState({
    this.recentDefensivos = const [],
    this.recentPragas = const [],
    this.isLoading = false,
    this.error,
  });

  RecentAccessState copyWith({
    List<RecentAccess>? recentDefensivos,
    List<RecentAccess>? recentPragas,
    bool? isLoading,
    String? error,
  }) {
    return RecentAccessState(
      recentDefensivos: recentDefensivos ?? this.recentDefensivos,
      recentPragas: recentPragas ?? this.recentPragas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Main provider for recent access state management
@riverpod
class RecentAccessNotifier extends _$RecentAccessNotifier {
  @override
  RecentAccessState build() {
    // Load data on initialization
    _loadAll();
    return const RecentAccessState(isLoading: true);
  }

  /// Load all recent access data
  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true, error: null);

    final defensivosUseCase = ref.read(getRecentDefensivosUseCaseProvider);
    final pragasUseCase = ref.read(getRecentPragasUseCaseProvider);

    // Load both in parallel
    final results = await Future.wait([
      defensivosUseCase(const NoParams()),
      pragasUseCase(const NoParams()),
    ]);

    List<RecentAccess> defensivos = [];
    List<RecentAccess> pragas = [];
    String? error;

    // Process defensivos result
    results[0].fold(
      (failure) => error = failure.message,
      (data) => defensivos = data,
    );

    // Process pragas result
    results[1].fold(
      (failure) => error ??= failure.message,
      (data) => pragas = data,
    );

    state = RecentAccessState(
      recentDefensivos: defensivos,
      recentPragas: pragas,
      isLoading: false,
      error: error,
    );
  }

  /// Refresh all recent access data
  Future<void> refresh() async {
    await _loadAll();
  }

  /// Add a defensivo access
  Future<void> addDefensivoAccess(Defensivo defensivo) async {
    final useCase = ref.read(addRecentAccessUseCaseProvider);
    final access = RecentAccess.forDefensivo(
      itemId: defensivo.id,
      name: defensivo.nomeComum,
      subtitle: defensivo.ingredienteAtivo.isNotEmpty
          ? defensivo.ingredienteAtivo
          : defensivo.fabricante,
    );

    await useCase(AddRecentAccessParams(access));
    await _loadAll();
  }

  /// Add a praga access
  Future<void> addPragaAccess(Praga praga) async {
    final useCase = ref.read(addRecentAccessUseCaseProvider);
    final access = RecentAccess.forPraga(
      itemId: praga.id,
      name: praga.nomeComum,
      subtitle: praga.nomeCientifico,
      imageUrl: praga.imageUrl,
    );

    await useCase(AddRecentAccessParams(access));
    await _loadAll();
  }

  /// Clear defensivos history
  Future<void> clearDefensivosHistory() async {
    final repository = ref.read(recentAccessRepositoryProvider);
    await repository.clearHistory(RecentAccessType.defensivo);
    await _loadAll();
  }

  /// Clear pragas history
  Future<void> clearPragasHistory() async {
    final repository = ref.read(recentAccessRepositoryProvider);
    await repository.clearHistory(RecentAccessType.praga);
    await _loadAll();
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    final repository = ref.read(recentAccessRepositoryProvider);
    await repository.clearAllHistory();
    await _loadAll();
  }
}

// ============================================================================
// DERIVED PROVIDERS
// ============================================================================

/// Provider for recent defensivos list only
@riverpod
List<RecentAccess> recentDefensivosList(Ref ref) {
  final state = ref.watch(recentAccessProvider);
  return state.recentDefensivos;
}

/// Provider for recent pragas list only
@riverpod
List<RecentAccess> recentPragasList(Ref ref) {
  final state = ref.watch(recentAccessProvider);
  return state.recentPragas;
}

/// Provider to check if recent access is loading
@riverpod
bool recentAccessIsLoading(Ref ref) {
  final state = ref.watch(recentAccessProvider);
  return state.isLoading;
}
