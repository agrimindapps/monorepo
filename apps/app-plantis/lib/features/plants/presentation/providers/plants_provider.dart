import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/plant.dart';
import '../../domain/services/plants_care_service.dart';
import '../../domain/services/plants_crud_service.dart';
import '../../domain/services/plants_filter_service.dart';
import '../../domain/services/plants_sort_service.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
export '../../domain/services/plants_care_service.dart' show CareStatus;
export '../../domain/services/plants_sort_service.dart' show SortBy, ViewMode;

/// Provider Riverpod para PlantsProvider
final plantsProviderProvider = ChangeNotifierProvider<PlantsProvider>((ref) {
  return PlantsProvider(
    getPlantsUseCase: getIt<GetPlantsUseCase>(),
    getPlantByIdUseCase: getIt<GetPlantByIdUseCase>(),
    searchPlantsUseCase: getIt<SearchPlantsUseCase>(),
    addPlantUseCase: getIt<AddPlantUseCase>(),
    updatePlantUseCase: getIt<UpdatePlantUseCase>(),
    deletePlantUseCase: getIt<DeletePlantUseCase>(),
    authStateNotifier: AuthStateNotifier.instance,
  );
});

/// Plants Provider refactored with specialized services
/// Now follows Single Responsibility Principle using Facade pattern
///
/// Delegates to:
/// - PlantsCrudService: CRUD operations
/// - PlantsFilterService: Search & filtering
/// - PlantsSortService: Sorting & views
/// - PlantsCareService: Care analytics
class PlantsProvider extends ChangeNotifier {
  final PlantsCrudService _crudService;
  final PlantsFilterService _filterService;
  final PlantsSortService _sortService;
  final PlantsCareService _careService;
  final SearchPlantsUseCase _searchPlantsUseCase;
  final AuthStateNotifier _authStateNotifier;
  StreamSubscription<UserEntity?>? _authSubscription;
  StreamSubscription<List<dynamic>>? _realtimeDataSubscription;

  PlantsProvider({
    required GetPlantsUseCase getPlantsUseCase,
    required GetPlantByIdUseCase getPlantByIdUseCase,
    required SearchPlantsUseCase searchPlantsUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
    AuthStateNotifier? authStateNotifier,
  }) : _crudService = PlantsCrudService(
         getPlantsUseCase: getPlantsUseCase,
         getPlantByIdUseCase: getPlantByIdUseCase,
         addPlantUseCase: addPlantUseCase,
         updatePlantUseCase: updatePlantUseCase,
         deletePlantUseCase: deletePlantUseCase,
       ),
       _filterService = PlantsFilterService(),
       _sortService = PlantsSortService(),
       _careService = PlantsCareService(),
       _searchPlantsUseCase = searchPlantsUseCase,
       _authStateNotifier = authStateNotifier ?? AuthStateNotifier.instance {
    _initializeAuthListener();
    _initializeRealtimeDataStream();
  }

  List<Plant> _plants = [];
  List<Plant> get plants => _plants;

  Plant? _selectedPlant;
  Plant? get selectedPlant => _selectedPlant;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Plant> _searchResults = [];
  List<Plant> get searchResults => _searchResults;

  ViewMode _viewMode = ViewMode.grid;
  ViewMode get viewMode => _viewMode;

  SortBy _sortBy = SortBy.newest;
  SortBy get sortBy => _sortBy;

  String? _filterBySpace;
  String? get filterBySpace => _filterBySpace;

  /// Initializes the authentication state listener
  ///
  /// This method sets up a subscription to the AuthStateNotifier to listen
  /// for authentication state changes. When the user logs in/out, it
  /// automatically reloads plants to ensure data consistency.
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint(
        '🔐 PlantsProvider: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}',
      );
      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint('✅ PlantsProvider: Auth is stable, loading plants...');
        loadInitialData();
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint(
          '🔄 PlantsProvider: No user but auth initialized - clearing plants',
        );
        _plants = [];
        _selectedPlant = null;
        _clearError();
        notifyListeners();
      }
    });
  }

  /// Inicializa o stream de dados em tempo real do UnifiedSyncManager
  /// ENHANCED: Improved validation, logging and error handling
  ///
  /// Este método configura um listener para receber atualizações automáticas
  /// dos dados de plantas quando o real-time sync estiver ativo.
  void _initializeRealtimeDataStream() {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 PlantsProvider: Iniciando configuração de real-time stream...',
        );
      }

      final dataStream = UnifiedSyncManager.instance.streamAll<Plant>('plantis');

      if (dataStream == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ PlantsProvider: Stream de dados não disponível - usando polling',
          );
          debugPrint(
            '   Motivos possíveis: UnifiedSyncManager não inicializado, real-time desabilitado, ou tipo Plant não registrado',
          );
        }
        return;
      }
      _realtimeDataSubscription = dataStream.listen(
        (List<dynamic> plants) {
          if (kDebugMode) {
            debugPrint(
              '🔄 PlantsProvider: Dados em tempo real recebidos - ${plants.length} plantas',
            );
            debugPrint(
              '   Auth state: ${_authStateNotifier.isInitialized ? "initialized" : "not initialized"}',
            );
          }
          if (!_authStateNotifier.isInitialized) {
            if (kDebugMode) {
              debugPrint(
                '⏸️ PlantsProvider: Aguardando inicialização de auth, dados não processados',
              );
            }
            return;
          }
          final conversionResults = <String, dynamic>{
            'total': plants.length,
            'successful': 0,
            'failed': 0,
            'null_results': 0,
          };

          final domainPlants = <Plant>[];

          for (final syncPlant in plants) {
            final plant = _convertSyncPlantToDomain(syncPlant);
            if (plant != null) {
              domainPlants.add(plant);
              conversionResults['successful'] =
                  (conversionResults['successful'] as int) + 1;
            } else {
              conversionResults['failed'] = (conversionResults['failed'] as int) + 1;
            }
          }

          if (kDebugMode) {
            debugPrint(
              '📊 PlantsProvider: Conversão completa - ${conversionResults['successful']}/${conversionResults['total']} sucesso',
            );
            if (conversionResults['failed'] as int > 0) {
              debugPrint(
                '   ⚠️ ${conversionResults['failed']} conversões falharam',
              );
            }
          }
          if (_hasDataChanged(domainPlants)) {
            final oldCount = _plants.length;
            _plants = _sortService.sortPlants(domainPlants, _sortBy);
            _applyFilters();

            if (kDebugMode) {
              debugPrint(
                '✅ PlantsProvider: UI atualizada - $oldCount → ${_plants.length} plantas',
              );
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                '⏭️ PlantsProvider: Sem mudanças detectadas, rebuild evitado',
              );
            }
          }
        },
        onError: (dynamic error, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint(
              '❌ PlantsProvider: Erro no stream de dados em tempo real',
            );
            debugPrint('   Erro: $error');
            debugPrint('   Stack: $stackTrace');
          }
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint(
              '🔚 PlantsProvider: Stream de dados em tempo real encerrado',
            );
          }
        },
      );

      if (kDebugMode) {
        debugPrint(
          '✅ PlantsProvider: Stream de dados em tempo real configurado com sucesso',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ PlantsProvider: Erro ao configurar stream de dados',
        );
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stackTrace');
      }
    }
  }

  /// Converte entidade de sync para entidade de domínio
  /// ENHANCED: Improved error handling and validation
  Plant? _convertSyncPlantToDomain(dynamic syncPlant) {
    try {
      if (syncPlant == null) {
        if (kDebugMode) {
          debugPrint('⚠️ PlantsProvider: syncPlant is null, skipping...');
        }
        return null;
      }
      if (syncPlant is Plant) {
        if (syncPlant.id.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ PlantsProvider: Plant com ID vazio detectada, descartando',
            );
          }
          return null;
        }
        return syncPlant;
      }
      if (syncPlant is BaseSyncEntity) {
        try {
          final firebaseMap = syncPlant.toFirebaseMap();
          if (!firebaseMap.containsKey('id') ||
              !firebaseMap.containsKey('name')) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ PlantsProvider: Firebase map inválido (faltam campos essenciais)',
              );
            }
            return null;
          }

          final plant = Plant.fromJson(firebaseMap);

          if (kDebugMode) {
            debugPrint(
              '✅ PlantsProvider: Convertido BaseSyncEntity → Plant: ${plant.name}',
            );
          }

          return plant;
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '❌ PlantsProvider: Erro ao converter BaseSyncEntity: $e',
            );
          }
          return null;
        }
      }
      if (syncPlant is Map<String, dynamic>) {
        if (!syncPlant.containsKey('id') ||
            !syncPlant.containsKey('name')) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ PlantsProvider: Map inválido (faltam campos essenciais)',
            );
          }
          return null;
        }

        final plant = Plant.fromJson(syncPlant);

        if (kDebugMode) {
          debugPrint(
            '✅ PlantsProvider: Convertido Map → Plant: ${plant.name}',
          );
        }

        return plant;
      }
      if (kDebugMode) {
        debugPrint(
          '⚠️ PlantsProvider: Tipo de entidade não suportado: ${syncPlant.runtimeType}',
        );
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ PlantsProvider: Erro ao converter plant de sync para domínio: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Verifica se os dados realmente mudaram para evitar rebuilds desnecessários
  bool _hasDataChanged(List<Plant> newPlants) {
    if (_plants.length != newPlants.length) {
      return true;
    }
    for (int i = 0; i < _plants.length; i++) {
      final currentPlant = _plants[i];
      Plant? newPlant;
      try {
        newPlant = newPlants.firstWhere((p) => p.id == currentPlant.id);
      } catch (e) {
        return true;
      }
      if (currentPlant.updatedAt != newPlant.updatedAt) {
        return true;
      }
    }

    return false;
  }

  /// CRITICAL FIX: Wait for authentication initialization with timeout
  ///
  /// This method ensures that we don't attempt to load plants before the
  /// authentication system is fully initialized. This prevents race conditions
  /// that cause data not to load properly.
  ///
  /// Returns:
  /// - `true` if authentication is initialized within timeout
  /// - `false` if timeout is reached
  Future<bool> _waitForAuthenticationWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_authStateNotifier.isInitialized) {
      return true;
    }

    debugPrint('⏳ PlantsProvider: Waiting for auth initialization...');
    try {
      await _authStateNotifier.initializedStream
          .where((isInitialized) => isInitialized)
          .timeout(timeout)
          .first;

      debugPrint('✅ PlantsProvider: Auth initialization complete');
      return true;
    } on TimeoutException {
      debugPrint(
        '⚠️ PlantsProvider: Auth initialization timeout after ${timeout.inSeconds}s',
      );
      return false;
    } catch (e) {
      debugPrint('❌ PlantsProvider: Auth initialization error: $e');
      return false;
    }
  }
  Future<void> loadPlants() async {
    if (kDebugMode) {
      print(
        '📋 PlantsProvider.loadPlants() - Iniciando carregamento offline-first',
      );
    }
    if (!await _waitForAuthenticationWithTimeout()) {
      _setError('Aguardando autenticação...');
      return;
    }
    await _loadLocalDataFirst();
    _syncInBackground();
  }

  /// Loads local data immediately for instant UI response
  Future<void> _loadLocalDataFirst() async {
    try {
      if (kDebugMode) {
        print('📦 PlantsProvider: Carregando dados locais primeiro...');
      }
      final shouldShowLoading = _plants.isEmpty;
      if (shouldShowLoading) {
        _setLoading(true);
      }
      _clearError();
      final localResult = await _crudService.getAllPlants();

      localResult.fold(
        (failure) {
          if (kDebugMode) {
            print(
              '⚠️ PlantsProvider: Dados locais não disponíveis: ${_crudService.getErrorMessage(failure)}',
            );
          }
        },
        (plants) {
          if (kDebugMode) {
            print(
              '✅ PlantsProvider: Dados locais carregados: ${plants.length} plantas',
            );
          }
          _updatePlantsData(plants);
          _setLoading(false);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsProvider: Erro ao carregar dados locais: $e');
      }
    }
  }

  /// Syncs with remote data in background without blocking UI
  void _syncInBackground() {
    if (kDebugMode) {
      print('🔄 PlantsProvider: Iniciando sync em background...');
    }
    Future.delayed(const Duration(milliseconds: 100), () async {
      final result = await _crudService.getAllPlants();

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              '❌ PlantsProvider: Background sync falhou: ${_crudService.getErrorMessage(failure)}',
            );
          }
          if (_plants.isEmpty) {
            _setError(_crudService.getErrorMessage(failure));
          }
        },
        (plants) {
          if (kDebugMode) {
            print(
              '✅ PlantsProvider: Background sync bem-sucedido: ${plants.length} plantas',
            );
          }
          _updatePlantsData(plants);
        },
      );
    });
  }

  /// Updates plants data and notifies listeners
  void _updatePlantsData(List<Plant> plants) {
    _plants = _sortService.sortPlants(plants, _sortBy);
    _clearError();
    _applyFilters();
    _setLoading(false);

    if (kDebugMode) {
      print('✅ PlantsProvider: UI atualizada com ${_plants.length} plantas');
      for (final plant in plants) {
        print('   - ${plant.name} (${plant.id})');
      }
    }

    notifyListeners();
  }
  Future<Plant?> getPlantById(String id) async {
    final result = await _crudService.getPlantById(id);

    return result.fold(
      (failure) {
        _setError(_crudService.getErrorMessage(failure));
        return null;
      },
      (plant) {
        _selectedPlant = plant;
        notifyListeners();
        return plant;
      },
    );
  }
  Future<void> searchPlants(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold((failure) => _setError(_crudService.getErrorMessage(failure)), (results) {
      _searchResults = _sortService.sortPlants(results, _sortBy);
      _isSearching = false;
    });

    notifyListeners();
  }
  Future<bool> addPlant(AddPlantParams params) async {
    _setLoading(true);
    _clearError();

    final result = await _crudService.addPlant(params);

    final success = result.fold(
      (Failure failure) {
        _setError(_crudService.getErrorMessage(failure));
        return false;
      },
      (Plant plant) {
        _plants.insert(0, plant);
        _applyFilters();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }
  Future<bool> updatePlant(UpdatePlantParams params) async {
    _setLoading(true);
    _clearError();

    final result = await _crudService.updatePlant(params);

    final success = result.fold(
      (Failure failure) {
        _setError(_crudService.getErrorMessage(failure));
        return false;
      },
      (Plant updatedPlant) {
        final index = _plants.indexWhere((p) => p.id == updatedPlant.id);
        if (index != -1) {
          _plants[index] = updatedPlant;
          _plants = _sortService.sortPlants(_plants, _sortBy);
          _applyFilters();
        }
        if (_selectedPlant?.id == updatedPlant.id) {
          _selectedPlant = updatedPlant;
        }

        return true;
      },
    );

    _setLoading(false);
    return success;
  }
  Future<bool> deletePlant(String id) async {
    _setLoading(true);
    _clearError();

    final result = await _crudService.deletePlant(id);

    final success = result.fold(
      (Failure failure) {
        _setError(_crudService.getErrorMessage(failure));
        return false;
      },
      (_) {
        _plants.removeWhere((plant) => plant.id == id);
        _searchResults.removeWhere((plant) => plant.id == id);
        if (_selectedPlant?.id == id) {
          _selectedPlant = null;
        }

        _applyFilters();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }
  void setViewMode(ViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }
  void setSortBy(SortBy sort) {
    if (_sortBy != sort) {
      _sortBy = sort;
      _plants = _sortService.sortPlants(_plants, _sortBy);
      _searchResults = _sortService.sortPlants(_searchResults, _sortBy);
      _applyFilters();
    }
  }
  void setSpaceFilter(String? spaceId) {
    if (_filterBySpace != spaceId) {
      _filterBySpace = spaceId;
      _applyFilters();
    }
  }
  void clearSearch() {
    if (_searchQuery.isNotEmpty || _searchResults.isNotEmpty || _isSearching) {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final plantsToGroup = _searchQuery.isNotEmpty ? _searchResults : _plants;
    return _filterService.groupPlantsBySpaces(plantsToGroup);
  }

  /// Gets the count of plants in each space
  Map<String?, int> get plantCountsBySpace {
    final plantsToGroup = _searchQuery.isNotEmpty ? _searchResults : _plants;
    return _filterService.getPlantCountsBySpace(plantsToGroup);
  }

  /// Toggle between normal view and grouped by spaces view
  void toggleGroupedView() {
    _viewMode = _sortService.toggleGroupedView(_viewMode);
    notifyListeners();
  }

  /// Check if current view is grouped by spaces
  bool get isGroupedBySpaces => _sortService.isGroupedView(_viewMode);
  void clearSelectedPlant() {
    if (_selectedPlant != null) {
      _selectedPlant = null;
      notifyListeners();
    }
  }
  void clearError() {
    _clearError();
  }
  List<Plant> getPlantsBySpace(String spaceId) {
    return _plants.where((plant) => plant.spaceId == spaceId).toList();
  }

  /// Load initial data for the plants list page
  /// This method is responsible for the initial data loading business logic
  Future<void> loadInitialData() async {
    await loadPlants();
  }

  /// Refresh plants data and clear any existing errors
  /// This method handles refresh operations with proper error clearing
  Future<void> refreshPlants() async {
    if (kDebugMode) {
      print('🔄 PlantsProvider.refreshPlants() - Iniciando refresh');
      print(
        '🔄 PlantsProvider.refreshPlants() - Plantas antes: ${_plants.length}',
      );
    }

    clearError();
    await loadInitialData();

    if (kDebugMode) {
      print('✅ PlantsProvider.refreshPlants() - Refresh completo');
      print(
        '🔄 PlantsProvider.refreshPlants() - Plantas depois: ${_plants.length}',
      );
    }
  }
  int get plantsCount => _crudService.getPlantCount(_plants);
  List<Plant> getPlantsNeedingWater() {
    return _careService.getPlantsNeedingWater(_plants);
  }
  List<Plant> getPlantsNeedingFertilizer() {
    return _careService.getPlantsNeedingFertilizer(_plants);
  }
  List<Plant> getPlantsByCareStatus(CareStatus status) {
    return _careService.getPlantsByCareStatus(_plants, status);
  }
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<Plant> filtered = List.from(_plants);

    if (_filterBySpace != null) {
      filtered = _filterService.filterBySpace(filtered, _filterBySpace);
    }

    _plants = filtered;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _realtimeDataSubscription?.cancel();

    super.dispose();
  }
}
