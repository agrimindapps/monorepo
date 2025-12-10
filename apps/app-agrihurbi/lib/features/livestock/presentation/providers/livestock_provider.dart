import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/animal_base_entity.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/get_equines.dart';
import '../../domain/usecases/search_animals.dart' as search_use_case;
import '../../domain/usecases/update_bovine.dart';
import 'livestock_di_providers.dart';

part 'livestock_provider.g.dart';

/// State class for Livestock
class LivestockState {
  final bool isLoading;
  final bool isLoadingBovines;
  final bool isLoadingEquines;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final List<BovineEntity> bovines;
  final List<EquineEntity> equines;
  final List<AnimalBaseEntity> searchResults;
  final BovineEntity? selectedBovine;
  final EquineEntity? selectedEquine;
  final String searchQuery;
  final String? selectedBreed;
  final String? selectedOriginCountry;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final String? errorMessage;
  final Map<String, dynamic>? statistics;

  const LivestockState({
    this.isLoading = false,
    this.isLoadingBovines = false,
    this.isLoadingEquines = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.bovines = const [],
    this.equines = const [],
    this.searchResults = const [],
    this.selectedBovine,
    this.selectedEquine,
    this.searchQuery = '',
    this.selectedBreed,
    this.selectedOriginCountry,
    this.selectedAptitude,
    this.selectedBreedingSystem,
    this.errorMessage,
    this.statistics,
  });

  LivestockState copyWith({
    bool? isLoading,
    bool? isLoadingBovines,
    bool? isLoadingEquines,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    List<BovineEntity>? bovines,
    List<EquineEntity>? equines,
    List<AnimalBaseEntity>? searchResults,
    BovineEntity? selectedBovine,
    EquineEntity? selectedEquine,
    String? searchQuery,
    String? selectedBreed,
    String? selectedOriginCountry,
    BovineAptitude? selectedAptitude,
    BreedingSystem? selectedBreedingSystem,
    String? errorMessage,
    Map<String, dynamic>? statistics,
    bool clearError = false,
    bool clearSelectedBovine = false,
    bool clearSelectedEquine = false,
    bool clearBreed = false,
    bool clearOriginCountry = false,
    bool clearAptitude = false,
    bool clearBreedingSystem = false,
  }) {
    return LivestockState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingBovines: isLoadingBovines ?? this.isLoadingBovines,
      isLoadingEquines: isLoadingEquines ?? this.isLoadingEquines,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      bovines: bovines ?? this.bovines,
      equines: equines ?? this.equines,
      searchResults: searchResults ?? this.searchResults,
      selectedBovine: clearSelectedBovine
          ? null
          : (selectedBovine ?? this.selectedBovine),
      selectedEquine: clearSelectedEquine
          ? null
          : (selectedEquine ?? this.selectedEquine),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBreed: clearBreed ? null : (selectedBreed ?? this.selectedBreed),
      selectedOriginCountry: clearOriginCountry
          ? null
          : (selectedOriginCountry ?? this.selectedOriginCountry),
      selectedAptitude: clearAptitude
          ? null
          : (selectedAptitude ?? this.selectedAptitude),
      selectedBreedingSystem: clearBreedingSystem
          ? null
          : (selectedBreedingSystem ?? this.selectedBreedingSystem),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statistics: statistics ?? this.statistics,
    );
  }

  /// Lista filtrada de bovinos baseada nos filtros ativos
  List<BovineEntity> get filteredBovines {
    var filtered = bovines.where((bovine) => bovine.isActive).toList();

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (bovine) =>
                bovine.commonName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                bovine.breed.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                bovine.registrationId.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (selectedBreed != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.breed.toLowerCase().contains(
              selectedBreed!.toLowerCase(),
            ),
          )
          .toList();
    }

    if (selectedOriginCountry != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.originCountry.toLowerCase().contains(
              selectedOriginCountry!.toLowerCase(),
            ),
          )
          .toList();
    }

    if (selectedAptitude != null) {
      filtered = filtered
          .where((bovine) => bovine.aptitude == selectedAptitude)
          .toList();
    }

    if (selectedBreedingSystem != null) {
      filtered = filtered
          .where((bovine) => bovine.breedingSystem == selectedBreedingSystem)
          .toList();
    }

    return filtered;
  }

  /// Lista filtrada de equinos
  List<EquineEntity> get filteredEquines {
    var filtered = equines.where((equine) => equine.isActive).toList();

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (equine) =>
                equine.commonName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                equine.registrationId.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  /// Total de animais
  int get totalAnimals => bovines.length + equines.length;
  int get totalActiveBovines => bovines.where((b) => b.isActive).length;
  int get totalActiveEquines => equines.where((e) => e.isActive).length;

  /// Obtém lista de raças únicas para filtros
  List<String> get uniqueBreeds {
    final breeds = <String>{};
    for (final bovine in bovines) {
      breeds.add(bovine.breed);
    }
    return breeds.toList()..sort();
  }

  /// Obtém lista de países únicos para filtros
  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    for (final bovine in bovines) {
      countries.add(bovine.originCountry);
    }
    for (final equine in equines) {
      countries.add(equine.originCountry);
    }
    return countries.toList()..sort();
  }
}

/// Livestock Notifier using Riverpod code generation
///
/// Provider principal para gerenciamento de estado do livestock
/// Gerencia bovinos, equinos e operações unificadas
@riverpod
class LivestockNotifier extends _$LivestockNotifier {
  LivestockRepository get _repository => ref.read(livestockRepositoryProvider);
  GetAllBovinesUseCase get _getAllBovines =>
      ref.read(getAllBovinesUseCaseProvider);
  GetEquinesUseCase get _getEquines => ref.read(getEquinesUseCaseProvider);
  CreateBovineUseCase get _createBovine =>
      ref.read(createBovineUseCaseProvider);
  UpdateBovineUseCase get _updateBovine =>
      ref.read(updateBovineUseCaseProvider);
  DeleteBovineUseCase get _deleteBovine =>
      ref.read(deleteBovineUseCaseProvider);
  search_use_case.SearchAnimalsUseCase get _searchAnimals =>
      ref.read(searchAnimalsUseCaseProvider);

  @override
  LivestockState build() {
    return const LivestockState();
  }

  // Convenience getters
  bool get isLoading => state.isLoading;
  bool get isLoadingBovines => state.isLoadingBovines;
  bool get isLoadingEquines => state.isLoadingEquines;
  bool get isCreating => state.isCreating;
  bool get isUpdating => state.isUpdating;
  bool get isDeleting => state.isDeleting;
  List<BovineEntity> get bovines => state.bovines;
  List<EquineEntity> get equines => state.equines;
  List<AnimalBaseEntity> get searchResults => state.searchResults;
  BovineEntity? get selectedBovine => state.selectedBovine;
  EquineEntity? get selectedEquine => state.selectedEquine;
  String get searchQuery => state.searchQuery;
  String? get selectedBreed => state.selectedBreed;
  String? get selectedOriginCountry => state.selectedOriginCountry;
  BovineAptitude? get selectedAptitude => state.selectedAptitude;
  BreedingSystem? get selectedBreedingSystem => state.selectedBreedingSystem;
  String? get errorMessage => state.errorMessage;
  Map<String, dynamic>? get statistics => state.statistics;
  List<BovineEntity> get filteredBovines => state.filteredBovines;
  List<EquineEntity> get filteredEquines => state.filteredEquines;
  int get totalAnimals => state.totalAnimals;
  int get totalActiveBovines => state.totalActiveBovines;
  int get totalActiveEquines => state.totalActiveEquines;
  List<String> get uniqueBreeds => state.uniqueBreeds;
  List<String> get uniqueOriginCountries => state.uniqueOriginCountries;

  /// Carrega todos os bovinos
  Future<void> loadBovines() async {
    state = state.copyWith(isLoadingBovines: true, clearError: true);

    final result = await _getAllBovines();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingBovines: false,
        );
        debugPrint('Erro ao carregar bovinos: ${failure.message}');
      },
      (loadedBovines) {
        state = state.copyWith(bovines: loadedBovines, isLoadingBovines: false);
        debugPrint('Bovinos carregados: ${loadedBovines.length}');
      },
    );
  }

  /// Seleciona um bovino específico
  void selectBovine(BovineEntity? bovine) {
    state = state.copyWith(
      selectedBovine: bovine,
      clearSelectedBovine: bovine == null,
    );
  }

  /// Cria um novo bovino
  Future<bool> createBovine(BovineEntity bovine) async {
    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _createBovine(CreateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isCreating: false,
        );
        debugPrint('Erro ao criar bovino: ${failure.message}');
      },
      (createdBovine) {
        final updatedBovines = [...state.bovines, createdBovine];
        state = state.copyWith(bovines: updatedBovines, isCreating: false);
        success = true;
        debugPrint('Bovino criado com sucesso: ${createdBovine.id}');
      },
    );

    return success;
  }

  /// Atualiza um bovino existente
  Future<bool> updateBovine(BovineEntity bovine) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _updateBovine(UpdateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isUpdating: false,
        );
        debugPrint('Erro ao atualizar bovino: ${failure.message}');
      },
      (updatedBovine) {
        final index = state.bovines.indexWhere((b) => b.id == updatedBovine.id);
        if (index != -1) {
          final updatedBovines = List<BovineEntity>.from(state.bovines);
          updatedBovines[index] = updatedBovine;
          state = state.copyWith(
            bovines: updatedBovines,
            selectedBovine: state.selectedBovine?.id == updatedBovine.id
                ? updatedBovine
                : state.selectedBovine,
            isUpdating: false,
          );
          success = true;
          debugPrint('Bovino atualizado com sucesso: ${updatedBovine.id}');
        }
      },
    );

    return success;
  }

  /// Remove um bovino (soft delete)
  Future<bool> deleteBovine(String bovineId) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _deleteBovine(DeleteBovineParams(bovineId: bovineId));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isDeleting: false,
        );
        debugPrint('Erro ao deletar bovino: ${failure.message}');
      },
      (_) {
        final index = state.bovines.indexWhere((b) => b.id == bovineId);
        if (index != -1) {
          final updatedBovines = List<BovineEntity>.from(state.bovines);
          updatedBovines[index] = updatedBovines[index].copyWith(
            isActive: false,
          );
          state = state.copyWith(
            bovines: updatedBovines,
            selectedBovine: state.selectedBovine?.id == bovineId
                ? null
                : state.selectedBovine,
            clearSelectedBovine: state.selectedBovine?.id == bovineId,
            isDeleting: false,
          );
          success = true;
          debugPrint('Bovino deletado com sucesso: $bovineId');
        }
      },
    );

    return success;
  }

  /// Carrega todos os equinos
  Future<void> loadEquines() async {
    state = state.copyWith(isLoadingEquines: true, clearError: true);

    final result = await _getEquines(const GetEquinesParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingEquines: false,
        );
        debugPrint('Erro ao carregar equinos: ${failure.message}');
      },
      (loadedEquines) {
        state = state.copyWith(equines: loadedEquines, isLoadingEquines: false);
        debugPrint('Equinos carregados: ${loadedEquines.length}');
      },
    );
  }

  /// Seleciona um equino específico
  void selectEquine(EquineEntity? equine) {
    state = state.copyWith(
      selectedEquine: equine,
      clearSelectedEquine: equine == null,
    );
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Atualiza filtro de raça
  void updateBreedFilter(String? breed) {
    state = state.copyWith(selectedBreed: breed, clearBreed: breed == null);
  }

  /// Atualiza filtro de país de origem
  void updateOriginCountryFilter(String? country) {
    state = state.copyWith(
      selectedOriginCountry: country,
      clearOriginCountry: country == null,
    );
  }

  /// Atualiza filtro de aptidão
  void updateAptitudeFilter(BovineAptitude? aptitude) {
    state = state.copyWith(
      selectedAptitude: aptitude,
      clearAptitude: aptitude == null,
    );
  }

  /// Atualiza filtro de sistema de criação
  void updateBreedingSystemFilter(BreedingSystem? system) {
    state = state.copyWith(
      selectedBreedingSystem: system,
      clearBreedingSystem: system == null,
    );
  }

  /// Limpa todos os filtros
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearBreed: true,
      clearOriginCountry: true,
      clearAptitude: true,
      clearBreedingSystem: true,
    );
  }

  /// Busca unificada em todos os animais
  Future<void> searchAllAnimals(String query) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final params = search_use_case.SearchAnimalsParams(query: query);
    final result = await _searchAnimals(params);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message, isLoading: false);
        debugPrint('Erro ao buscar animais: ${failure.message}');
      },
      (results) {
        state = state.copyWith(
          searchResults: results.allAnimals,
          isLoading: false,
        );
        debugPrint('Resultados da busca: ${results.totalCount}');
      },
    );
  }

  /// Carrega estatísticas do rebanho
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getLivestockStatistics();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message, isLoading: false);
        debugPrint('Erro ao carregar estatísticas: ${failure.message}');
      },
      (stats) {
        state = state.copyWith(statistics: stats, isLoading: false);
        debugPrint('Estatísticas carregadas: $stats');
      },
    );
  }

  /// Força sincronização manual
  Future<void> forceSyncNow() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.syncLivestockData();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message, isLoading: false);
        debugPrint('Erro na sincronização: ${failure.message}');
      },
      (_) {
        debugPrint('Sincronização realizada com sucesso');
        state = state.copyWith(isLoading: false);
        loadBovines();
        loadEquines();
      },
    );
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    await Future.wait([loadBovines(), loadEquines(), loadStatistics()]);
  }
}
