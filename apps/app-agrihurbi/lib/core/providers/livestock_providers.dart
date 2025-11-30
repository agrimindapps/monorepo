import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../core/di/injection_container.dart' as di; // Commented out - migrating to Riverpod
import '../../features/livestock/domain/entities/animal_base_entity.dart';
import '../../features/livestock/domain/entities/bovine_entity.dart';
import '../../features/livestock/domain/entities/equine_entity.dart';
import '../../features/livestock/domain/repositories/livestock_repository.dart';
import '../../features/livestock/domain/usecases/create_bovine.dart';
import '../../features/livestock/domain/usecases/delete_bovine.dart';
import '../../features/livestock/domain/usecases/get_bovines.dart';
import '../../features/livestock/domain/usecases/get_equines.dart';
import '../../features/livestock/domain/usecases/search_animals.dart'
    as search_use_case;
import '../../features/livestock/domain/usecases/update_bovine.dart';

part 'livestock_providers.g.dart';

/// State para gerenciamento de bovinos
class BovinesState {
  const BovinesState({
    this.bovines = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.selectedBovine,
    this.errorMessage,
  });

  final List<BovineEntity> bovines;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final BovineEntity? selectedBovine;
  final String? errorMessage;

  List<BovineEntity> get activeBovines =>
      bovines.where((b) => b.isActive).toList();
  int get totalBovines => bovines.length;
  int get totalActiveBovines => activeBovines.length;
  bool get hasSelectedBovine => selectedBovine != null;
  bool get isAnyOperationInProgress =>
      isLoading || isCreating || isUpdating || isDeleting;

  BovinesState copyWith({
    List<BovineEntity>? bovines,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    BovineEntity? selectedBovine,
    String? errorMessage,
  }) {
    return BovinesState(
      bovines: bovines ?? this.bovines,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      selectedBovine: selectedBovine ?? this.selectedBovine,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State para gerenciamento de equinos
class EquinesState {
  const EquinesState({
    this.equines = const [],
    this.isLoading = false,
    this.selectedEquine,
    this.errorMessage,
  });

  final List<EquineEntity> equines;
  final bool isLoading;
  final EquineEntity? selectedEquine;
  final String? errorMessage;

  List<EquineEntity> get activeEquines =>
      equines.where((e) => e.isActive).toList();
  int get totalEquines => equines.length;
  int get totalActiveEquines => activeEquines.length;

  EquinesState copyWith({
    List<EquineEntity>? equines,
    bool? isLoading,
    EquineEntity? selectedEquine,
    String? errorMessage,
  }) {
    return EquinesState(
      equines: equines ?? this.equines,
      isLoading: isLoading ?? this.isLoading,
      selectedEquine: selectedEquine ?? this.selectedEquine,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State para filtros de livestock
class LivestockFiltersState {
  const LivestockFiltersState({
    this.searchQuery = '',
    this.selectedBreed,
    this.selectedOriginCountry,
    this.selectedAptitude,
    this.selectedBreedingSystem,
  });

  final String searchQuery;
  final String? selectedBreed;
  final String? selectedOriginCountry;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedBreed != null ||
      selectedOriginCountry != null ||
      selectedAptitude != null ||
      selectedBreedingSystem != null;

  LivestockFiltersState copyWith({
    String? searchQuery,
    String? selectedBreed,
    String? selectedOriginCountry,
    BovineAptitude? selectedAptitude,
    BreedingSystem? selectedBreedingSystem,
  }) {
    return LivestockFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBreed: selectedBreed ?? this.selectedBreed,
      selectedOriginCountry:
          selectedOriginCountry ?? this.selectedOriginCountry,
      selectedAptitude: selectedAptitude ?? this.selectedAptitude,
      selectedBreedingSystem:
          selectedBreedingSystem ?? this.selectedBreedingSystem,
    );
  }
}

/// State para busca de livestock
class LivestockSearchState {
  const LivestockSearchState({
    this.searchResults = const [],
    this.isSearching = false,
    this.errorMessage,
  });

  final List<AnimalBaseEntity> searchResults;
  final bool isSearching;
  final String? errorMessage;

  LivestockSearchState copyWith({
    List<AnimalBaseEntity>? searchResults,
    bool? isSearching,
    String? errorMessage,
  }) {
    return LivestockSearchState(
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier para gerenciamento de bovinos
@riverpod
class BovinesNotifier extends _$BovinesNotifier {
  late final GetAllBovinesUseCase _getAllBovines;
  late final CreateBovineUseCase _createBovine;
  late final UpdateBovineUseCase _updateBovine;
  late final DeleteBovineUseCase _deleteBovine;

  @override
  BovinesState build() {
    Future.microtask(() => loadBovines());

    return const BovinesState();
  }

  Future<void> loadBovines() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getAllBovines();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (bovines) {
        state = state.copyWith(bovines: bovines, isLoading: false);
      },
    );
  }

  void selectBovine(BovineEntity? bovine) {
    state = state.copyWith(selectedBovine: bovine);
  }

  Future<bool> createBovine(BovineEntity bovine) async {
    state = state.copyWith(isCreating: true, errorMessage: null);

    final result = await _createBovine(CreateBovineParams(bovine: bovine));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdBovine) {
        final updatedBovines = [...state.bovines, createdBovine];
        state = state.copyWith(
          bovines: updatedBovines,
          selectedBovine: createdBovine,
          isCreating: false,
        );
        return true;
      },
    );
  }

  Future<bool> updateBovine(BovineEntity bovine) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    final result = await _updateBovine(UpdateBovineParams(bovine: bovine));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedBovine) {
        final updatedBovines = state.bovines.map((b) {
          return b.id == updatedBovine.id ? updatedBovine : b;
        }).toList();

        state = state.copyWith(
          bovines: updatedBovines,
          selectedBovine: state.selectedBovine?.id == updatedBovine.id
              ? updatedBovine
              : state.selectedBovine,
          isUpdating: false,
        );
        return true;
      },
    );
  }

  Future<bool> deleteBovine(String bovineId) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);

    final result = await _deleteBovine(DeleteBovineParams(bovineId: bovineId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final updatedBovines = state.bovines.map((b) {
          return b.id == bovineId ? b.copyWith(isActive: false) : b;
        }).toList();

        state = state.copyWith(
          bovines: updatedBovines,
          selectedBovine: state.selectedBovine?.id == bovineId
              ? null
              : state.selectedBovine,
          isDeleting: false,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSelection() {
    state = state.copyWith(selectedBovine: null);
  }

  List<String> get uniqueBreeds {
    final breeds = <String>{};
    for (final bovine in state.bovines) {
      breeds.add(bovine.breed);
    }
    return breeds.toList()..sort();
  }

  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    for (final bovine in state.bovines) {
      countries.add(bovine.originCountry);
    }
    return countries.toList()..sort();
  }
}

/// StateNotifier para gerenciamento de equinos
@riverpod
class EquinesNotifier extends _$EquinesNotifier {
  late final GetEquinesUseCase _getEquines;

  @override
  EquinesState build() {
    Future.microtask(() => loadEquines());

    return const EquinesState();
  }

  Future<void> loadEquines() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getEquines(const GetEquinesParams());
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (equines) {
        state = state.copyWith(equines: equines, isLoading: false);
      },
    );
  }

  void selectEquine(EquineEntity? equine) {
    state = state.copyWith(selectedEquine: equine);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// StateNotifier para filtros de livestock
@riverpod
class LivestockFiltersNotifier extends _$LivestockFiltersNotifier {
  @override
  LivestockFiltersState build() {
    return const LivestockFiltersState();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateBreedFilter(String? breed) {
    state = state.copyWith(selectedBreed: breed);
  }

  void updateOriginCountryFilter(String? country) {
    state = state.copyWith(selectedOriginCountry: country);
  }

  void updateAptitudeFilter(BovineAptitude? aptitude) {
    state = state.copyWith(selectedAptitude: aptitude);
  }

  void updateBreedingSystemFilter(BreedingSystem? system) {
    state = state.copyWith(selectedBreedingSystem: system);
  }

  void clearFilters() {
    state = const LivestockFiltersState();
  }

  List<BovineEntity> applyFilters(List<BovineEntity> bovines) {
    var filtered = bovines.where((bovine) => bovine.isActive).toList();

    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (bovine) =>
                bovine.commonName.toLowerCase().contains(
                      state.searchQuery.toLowerCase(),
                    ) ||
                bovine.breed.toLowerCase().contains(
                      state.searchQuery.toLowerCase(),
                    ) ||
                bovine.registrationId.toLowerCase().contains(
                      state.searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    if (state.selectedBreed != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.breed.toLowerCase().contains(
                  state.selectedBreed!.toLowerCase(),
                ),
          )
          .toList();
    }

    if (state.selectedOriginCountry != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.originCountry.toLowerCase().contains(
                  state.selectedOriginCountry!.toLowerCase(),
                ),
          )
          .toList();
    }

    if (state.selectedAptitude != null) {
      filtered = filtered
          .where((bovine) => bovine.aptitude == state.selectedAptitude)
          .toList();
    }

    if (state.selectedBreedingSystem != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.breedingSystem == state.selectedBreedingSystem,
          )
          .toList();
    }

    return filtered;
  }
}

/// StateNotifier para busca de livestock
@riverpod
class LivestockSearchNotifier extends _$LivestockSearchNotifier {
  late final search_use_case.SearchAnimalsUseCase _searchAnimals;

  @override
  LivestockSearchState build() {
    return const LivestockSearchState();
  }

  Future<void> searchAllAnimals(String query) async {
    state = state.copyWith(isSearching: true, errorMessage: null);

    final params = search_use_case.SearchAnimalsParams(query: query);
    final result = await _searchAnimals(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isSearching: false,
          errorMessage: failure.message,
        );
      },
      (results) {
        state = state.copyWith(
          searchResults: results.allAnimals,
          isSearching: false,
        );
      },
    );
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: const []);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider derivado para bovinos filtrados
@riverpod
List<BovineEntity> filteredBovines(Ref ref) {
  final bovines = ref.watch(bovinesProvider).bovines;
  return ref
      .read(livestockFiltersProvider.notifier)
      .applyFilters(bovines);
}

/// Provider derivado para total de animais
@riverpod
int totalAnimals(Ref ref) {
  final bovinesCount = ref.watch(bovinesProvider).totalBovines;
  final equinesCount = ref.watch(equinesProvider).totalEquines;
  return bovinesCount + equinesCount;
}

/// Provider para verificar se há operações em andamento
@riverpod
bool isAnyLivestockOperationInProgress(Ref ref) {
  final bovinesState = ref.watch(bovinesProvider);
  final equinesState = ref.watch(equinesProvider);
  final searchState = ref.watch(livestockSearchProvider);

  return bovinesState.isAnyOperationInProgress ||
      equinesState.isLoading ||
      searchState.isSearching;
}

/// Provider para erros consolidados
@riverpod
String? consolidatedLivestockError(Ref ref) {
  final bovinesError = ref.watch(bovinesProvider).errorMessage;
  final equinesError = ref.watch(equinesProvider).errorMessage;
  final searchError = ref.watch(livestockSearchProvider).errorMessage;

  final errors = <String>[];

  if (bovinesError != null) errors.add('Bovinos: $bovinesError');
  if (equinesError != null) errors.add('Equinos: $equinesError');
  if (searchError != null) errors.add('Busca: $searchError');

  return errors.isEmpty ? null : errors.join('\n');
}

/// State para estatísticas de livestock
class LivestockStatisticsState {
  const LivestockStatisticsState({
    this.statistics,
    this.isLoading = false,
    this.errorMessage,
  });

  final Map<String, dynamic>? statistics;
  final bool isLoading;
  final String? errorMessage;

  LivestockStatisticsState copyWith({
    Map<String, dynamic>? statistics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LivestockStatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier para estatísticas de livestock
@riverpod
class LivestockStatisticsNotifier extends _$LivestockStatisticsNotifier {
  late final LivestockRepository _repository;

  @override
  LivestockStatisticsState build() {
    return const LivestockStatisticsState();
  }

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getLivestockStatistics();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (stats) {
        state = state.copyWith(statistics: stats, isLoading: false);
      },
    );
  }

  void clearStatistics() {
    state = state.copyWith(statistics: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// State para sincronização de livestock
class LivestockSyncState {
  const LivestockSyncState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.syncProgress = 0.0,
    this.errorMessage,
  });

  final bool isSyncing;
  final DateTime? lastSyncTime;
  final double syncProgress;
  final String? errorMessage;

  LivestockSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    double? syncProgress,
    String? errorMessage,
  }) {
    return LivestockSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncProgress: syncProgress ?? this.syncProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier para sincronização de livestock
@riverpod
class LivestockSyncNotifier extends _$LivestockSyncNotifier {
  late final LivestockRepository _repository;

  @override
  LivestockSyncState build() {
    return const LivestockSyncState();
  }

  Future<bool> forceSyncNow({void Function(double)? onProgress}) async {
    state = state.copyWith(
      isSyncing: true,
      errorMessage: null,
      syncProgress: 0.0,
    );

    final result = await _repository.syncLivestockData();

    return result.fold(
      (failure) {
        state = state.copyWith(isSyncing: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isSyncing: false,
          lastSyncTime: DateTime.now(),
          syncProgress: 1.0,
        );
        return true;
      },
    );
  }

  Future<bool> backgroundSync() async {
    return await forceSyncNow();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetSyncState() {
    state = const LivestockSyncState();
  }
}

/// Provider atualizado para verificar se há operações em andamento (incluindo stats e sync)
@riverpod
bool isAnyLivestockOperationInProgressComplete(Ref ref) {
  final bovinesState = ref.watch(bovinesProvider);
  final equinesState = ref.watch(equinesProvider);
  final searchState = ref.watch(livestockSearchProvider);
  final statsState = ref.watch(livestockStatisticsProvider);
  final syncState = ref.watch(livestockSyncProvider);

  return bovinesState.isAnyOperationInProgress ||
      equinesState.isLoading ||
      searchState.isSearching ||
      statsState.isLoading ||
      syncState.isSyncing;
}

/// Provider atualizado para erros consolidados (incluindo stats e sync)
@riverpod
String? consolidatedLivestockErrorComplete(Ref ref) {
  final bovinesError = ref.watch(bovinesProvider).errorMessage;
  final equinesError = ref.watch(equinesProvider).errorMessage;
  final searchError = ref.watch(livestockSearchProvider).errorMessage;
  final statsError =
      ref.watch(livestockStatisticsProvider).errorMessage;
  final syncError = ref.watch(livestockSyncProvider).errorMessage;

  final errors = <String>[];

  if (bovinesError != null) errors.add('Bovinos: $bovinesError');
  if (equinesError != null) errors.add('Equinos: $equinesError');
  if (searchError != null) errors.add('Busca: $searchError');
  if (statsError != null) errors.add('Estatísticas: $statsError');
  if (syncError != null) errors.add('Sincronização: $syncError');

  return errors.isEmpty ? null : errors.join('\n');
}

/// Ações coordenadas para o sistema de livestock
class LivestockCoordinatorActions {
  const LivestockCoordinatorActions(this.ref);

  final Ref ref;

  /// Inicialização completa do sistema livestock
  Future<void> initializeSystem() async {
    await Future.wait([
      ref.read(bovinesProvider.notifier).loadBovines(),
      ref.read(equinesProvider.notifier).loadEquines(),
      ref.read(livestockStatisticsProvider.notifier).loadStatistics(),
    ]);
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    await Future.wait([
      ref.read(bovinesProvider.notifier).loadBovines(),
      ref.read(equinesProvider.notifier).loadEquines(),
      ref.read(livestockStatisticsProvider.notifier).loadStatistics(),
    ]);
  }

  /// Sincronização completa com callback de progresso
  Future<bool> performCompleteSync({void Function(double)? onProgress}) async {
    final syncSuccess = await ref
        .read(livestockSyncProvider.notifier)
        .forceSyncNow(onProgress: onProgress);

    if (syncSuccess) {
      await refreshAllData();
    }

    return syncSuccess;
  }

  /// Limpa todos os erros dos providers especializados
  void clearAllErrors() {
    ref.read(bovinesProvider.notifier).clearError();
    ref.read(equinesProvider.notifier).clearError();
    ref.read(livestockSearchProvider.notifier).clearError();
    ref.read(livestockStatisticsProvider.notifier).clearError();
    ref.read(livestockSyncProvider.notifier).clearError();
  }

  /// Reset completo do sistema
  void resetSystem() {
    ref.read(bovinesProvider.notifier).clearSelection();
    ref.read(equinesProvider.notifier).clearError();
    ref.read(livestockFiltersProvider.notifier).clearFilters();
    ref.read(livestockSearchProvider.notifier).clearSearchResults();
    ref.read(livestockStatisticsProvider.notifier).clearStatistics();
    ref.read(livestockSyncProvider.notifier).resetSyncState();
  }
}

/// Provider para ações coordenadas
@riverpod
LivestockCoordinatorActions livestockCoordinatorActions(Ref ref) {
  return LivestockCoordinatorActions(ref);
}
