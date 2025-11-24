import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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

/// Provider Riverpod para LivestockProvider
final livestockProviderProvider =
    ChangeNotifierProvider<LivestockProvider>((ref) {
  return LivestockProvider(
    repository: ref.watch(livestockRepositoryProvider),
    getAllBovines: ref.watch(getAllBovinesUseCaseProvider),
    getEquines: ref.watch(getEquinesUseCaseProvider),
    createBovine: ref.watch(createBovineUseCaseProvider),
    updateBovine: ref.watch(updateBovineUseCaseProvider),
    deleteBovine: ref.watch(deleteBovineUseCaseProvider),
    searchAnimals: ref.watch(searchAnimalsUseCaseProvider),
  );
});

/// Provider específico para operações de bovinos
final bovinesProviderProvider = ChangeNotifierProvider<BovinesProvider>((ref) {
  return BovinesProvider(ref.watch(livestockRepositoryProvider));
});

/// Provider específico para operações de equinos
final equinesProviderProvider = ChangeNotifierProvider<EquinesProvider>((ref) {
  return EquinesProvider(ref.watch(livestockRepositoryProvider));
});

/// Provider principal para gerenciamento de estado do livestock
///
/// Substitui os antigos controllers GetX por ChangeNotifier
/// Implementa padrões clean architecture com Provider pattern
/// Gerencia bovinos, equinos e operações unificadas
class LivestockProvider extends ChangeNotifier {
  final LivestockRepository _repository;
  final GetAllBovinesUseCase _getAllBovines;
  final GetEquinesUseCase _getEquines;
  final CreateBovineUseCase _createBovine;
  final UpdateBovineUseCase _updateBovine;
  final DeleteBovineUseCase _deleteBovine;
  final search_use_case.SearchAnimalsUseCase _searchAnimals;

  LivestockProvider({
    required LivestockRepository repository,
    required GetAllBovinesUseCase getAllBovines,
    required GetEquinesUseCase getEquines,
    required CreateBovineUseCase createBovine,
    required UpdateBovineUseCase updateBovine,
    required DeleteBovineUseCase deleteBovine,
    required search_use_case.SearchAnimalsUseCase searchAnimals,
  })  : _repository = repository,
        _getAllBovines = getAllBovines,
        _getEquines = getEquines,
        _createBovine = createBovine,
        _updateBovine = updateBovine,
        _deleteBovine = deleteBovine,
        _searchAnimals = searchAnimals;

  /// Estados de loading
  bool _isLoading = false;
  bool _isLoadingBovines = false;
  bool _isLoadingEquines = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  /// Dados dos animais
  List<BovineEntity> _bovines = [];
  List<EquineEntity> _equines = [];
  List<AnimalBaseEntity> _searchResults = [];

  /// Animais selecionados
  BovineEntity? _selectedBovine;
  EquineEntity? _selectedEquine;

  /// Filtros e busca
  String _searchQuery = '';
  String? _selectedBreed;
  String? _selectedOriginCountry;
  BovineAptitude? _selectedAptitude;
  BreedingSystem? _selectedBreedingSystem;

  /// Erro handling
  String? _errorMessage;

  /// Estatísticas
  Map<String, dynamic>? _statistics;

  bool get isLoading => _isLoading;
  bool get isLoadingBovines => _isLoadingBovines;
  bool get isLoadingEquines => _isLoadingEquines;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

  List<BovineEntity> get bovines => _bovines;
  List<EquineEntity> get equines => _equines;
  List<AnimalBaseEntity> get searchResults => _searchResults;

  BovineEntity? get selectedBovine => _selectedBovine;
  EquineEntity? get selectedEquine => _selectedEquine;

  String get searchQuery => _searchQuery;
  String? get selectedBreed => _selectedBreed;
  String? get selectedOriginCountry => _selectedOriginCountry;
  BovineAptitude? get selectedAptitude => _selectedAptitude;
  BreedingSystem? get selectedBreedingSystem => _selectedBreedingSystem;

  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;

  /// Lista filtrada de bovinos baseada nos filtros ativos
  List<BovineEntity> get filteredBovines {
    var filtered = _bovines.where((bovine) => bovine.isActive).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (bovine) =>
                bovine.commonName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                bovine.breed.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                bovine.registrationId.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    if (_selectedBreed != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.breed.toLowerCase().contains(
                  _selectedBreed!.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedOriginCountry != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.originCountry.toLowerCase().contains(
                  _selectedOriginCountry!.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedAptitude != null) {
      filtered = filtered
          .where((bovine) => bovine.aptitude == _selectedAptitude)
          .toList();
    }

    if (_selectedBreedingSystem != null) {
      filtered = filtered
          .where(
            (bovine) => bovine.breedingSystem == _selectedBreedingSystem,
          )
          .toList();
    }

    return filtered;
  }

  /// Lista filtrada de equinos
  List<EquineEntity> get filteredEquines {
    var filtered = _equines.where((equine) => equine.isActive).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (equine) =>
                equine.commonName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                equine.registrationId.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    return filtered;
  }

  /// Total de animais
  int get totalAnimals => _bovines.length + _equines.length;
  int get totalActiveBovines => _bovines.where((b) => b.isActive).length;
  int get totalActiveEquines => _equines.where((e) => e.isActive).length;

  /// Carrega todos os bovinos
  Future<void> loadBovines() async {
    _isLoadingBovines = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllBovines();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao carregar bovinos: ${failure.message}');
      },
      (bovines) {
        _bovines = bovines;
        debugPrint('Bovinos carregados: ${bovines.length}');
      },
    );

    _isLoadingBovines = false;
    notifyListeners();
  }

  /// Seleciona um bovino específico
  void selectBovine(BovineEntity? bovine) {
    _selectedBovine = bovine;
    notifyListeners();
  }

  /// Cria um novo bovino
  Future<bool> createBovine(BovineEntity bovine) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _createBovine(CreateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao criar bovino: ${failure.message}');
      },
      (createdBovine) {
        _bovines.add(createdBovine);
        success = true;
        debugPrint('Bovino criado com sucesso: ${createdBovine.id}');
      },
    );

    _isCreating = false;
    notifyListeners();
    return success;
  }

  /// Atualiza um bovino existente
  Future<bool> updateBovine(BovineEntity bovine) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateBovine(UpdateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao atualizar bovino: ${failure.message}');
      },
      (updatedBovine) {
        final index = _bovines.indexWhere((b) => b.id == updatedBovine.id);
        if (index != -1) {
          _bovines[index] = updatedBovine;
          if (_selectedBovine?.id == updatedBovine.id) {
            _selectedBovine = updatedBovine;
          }

          success = true;
          debugPrint('Bovino atualizado com sucesso: ${updatedBovine.id}');
        }
      },
    );

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  /// Remove um bovino (soft delete)
  Future<bool> deleteBovine(String bovineId) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteBovine(DeleteBovineParams(bovineId: bovineId));

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao deletar bovino: ${failure.message}');
      },
      (_) {
        final index = _bovines.indexWhere((b) => b.id == bovineId);
        if (index != -1) {
          _bovines[index] = _bovines[index].copyWith(isActive: false);
          if (_selectedBovine?.id == bovineId) {
            _selectedBovine = null;
          }

          success = true;
          debugPrint('Bovino deletado com sucesso: $bovineId');
        }
      },
    );

    _isDeleting = false;
    notifyListeners();
    return success;
  }

  /// Carrega todos os equinos
  Future<void> loadEquines() async {
    _isLoadingEquines = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getEquines(const GetEquinesParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao carregar equinos: ${failure.message}');
      },
      (equines) {
        _equines = equines;
        debugPrint('Equinos carregados: ${equines.length}');
      },
    );

    _isLoadingEquines = false;
    notifyListeners();
  }

  /// Seleciona um equino específico
  void selectEquine(EquineEntity? equine) {
    _selectedEquine = equine;
    notifyListeners();
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Atualiza filtro de raça
  void updateBreedFilter(String? breed) {
    _selectedBreed = breed;
    notifyListeners();
  }

  /// Atualiza filtro de país de origem
  void updateOriginCountryFilter(String? country) {
    _selectedOriginCountry = country;
    notifyListeners();
  }

  /// Atualiza filtro de aptidão
  void updateAptitudeFilter(BovineAptitude? aptitude) {
    _selectedAptitude = aptitude;
    notifyListeners();
  }

  /// Atualiza filtro de sistema de criação
  void updateBreedingSystemFilter(BreedingSystem? system) {
    _selectedBreedingSystem = system;
    notifyListeners();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedBreed = null;
    _selectedOriginCountry = null;
    _selectedAptitude = null;
    _selectedBreedingSystem = null;
    notifyListeners();
  }

  /// Busca unificada em todos os animais
  Future<void> searchAllAnimals(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = search_use_case.SearchAnimalsParams(query: query);
    final result = await _searchAnimals(params);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao buscar animais: ${failure.message}');
      },
      (results) {
        _searchResults = results.allAnimals;
        debugPrint('Resultados da busca: ${results.totalCount}');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega estatísticas do rebanho
  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getLivestockStatistics();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro ao carregar estatísticas: ${failure.message}');
      },
      (stats) {
        _statistics = stats;
        debugPrint('Estatísticas carregadas: $stats');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Força sincronização manual
  Future<void> forceSyncNow() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.syncLivestockData();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Erro na sincronização: ${failure.message}');
      },
      (_) {
        debugPrint('Sincronização realizada com sucesso');
        loadBovines();
        loadEquines();
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    await Future.wait([loadBovines(), loadEquines(), loadStatistics()]);
  }

  /// Obtém lista de raças únicas para filtros
  List<String> get uniqueBreeds {
    final breeds = <String>{};

    for (final bovine in _bovines) {
      breeds.add(bovine.breed);
    }

    return breeds.toList()..sort();
  }

  /// Obtém lista de países únicos para filtros
  List<String> get uniqueOriginCountries {
    final countries = <String>{};

    for (final bovine in _bovines) {
      countries.add(bovine.originCountry);
    }

    for (final equine in _equines) {
      countries.add(equine.originCountry);
    }

    return countries.toList()..sort();
  }
}

/// Provider específico para operações de bovinos
///
/// Separado do provider principal para otimização e especialização
class BovinesProvider extends ChangeNotifier {
  final LivestockRepository _repository;

  BovinesProvider(this._repository);

  List<BovineEntity> _bovines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BovineEntity> get bovines => _bovines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBovines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getBovines();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (bovines) => _bovines = bovines,
    );

    _isLoading = false;
    notifyListeners();
  }
}

/// Provider específico para operações de equinos
///
/// Separado do provider principal para otimização e especialização
class EquinesProvider extends ChangeNotifier {
  final LivestockRepository _repository;

  EquinesProvider(this._repository);

  List<EquineEntity> _equines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EquineEntity> get equines => _equines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEquines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getEquines();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (equines) => _equines = equines,
    );

    _isLoading = false;
    notifyListeners();
  }
}
