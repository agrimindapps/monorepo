// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../models/praga_unica_model.dart';
import '../../../repository/pragas_repository.dart';
import '../../home_pragas/utils/route_guards.dart';
import '../models/lista_pragas_cultura_state.dart';
import '../models/praga_cultura_item_model.dart';
import '../models/view_mode.dart';
import '../services/lista_pragas_service.dart';
import '../utils/praga_cultura_constants.dart';
import '../utils/praga_cultura_utils.dart';

/// Simple cancellation token for async operations
class CancelToken {
  bool _isCancelled = false;
  
  bool get isCancelled => _isCancelled;
  
  void cancel() {
    _isCancelled = true;
  }
}

class ListaPragasPorCulturaController extends GetxController
    with GetSingleTickerProviderStateMixin, RouteGuardMixin, PragasPorCulturaRouteGuard {
  // Dependencies
  late PragasRepository _pragasRepository;
  late ListaPragasService _listaPragasService;
  final TextEditingController searchController = TextEditingController();
  late TabController tabController;

  // Debounce functionality
  Timer? _searchDebounceTimer;
  
  // Race condition prevention
  CancelToken? _loadDataCancelToken;
  bool _isLoadingData = false;
  final Map<String, CancelToken> _operationTokens = {};
  Completer<void>? _currentLoadOperation;

  // State
  ListaPragasCulturaState _state = const ListaPragasCulturaState();
  ListaPragasCulturaState get state => _state;

  // Reactive variables for compatibility (migration from RxList to immutable state)
  final RxString culturaSelecionada = ''.obs;
  final RxString culturaSelecionadaId = ''.obs;
  // RxList replaced with computed getter for legacy compatibility

  /// Computed getter for legacy RxList compatibility
  /// Returns immutable state data as List<dynamic> for backward compatibility
  List<dynamic> get pragasLista => _state.pragasLegacyData;

  void _updateState(ListaPragasCulturaState newState) {
    _state = newState;
    update(['lista_pragas_cultura']);
  }

  @override
  void onInit() {
    super.onInit();
    _initRepository();
    _setupTabController();
    _setupListeners();
    _initializeTheme();
  }

  @override
  void onClose() {
    _cancelAllOperations();
    _cleanupTimers();
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Robust timer cleanup to prevent memory leaks
  void _cleanupTimers() {
    // Cancel search debounce timer with null checks
    if (_searchDebounceTimer != null) {
      if (_searchDebounceTimer!.isActive) {
        _searchDebounceTimer!.cancel();
      }
      _searchDebounceTimer = null;
    }
  }

  void _cancelAllOperations() {
    _loadDataCancelToken?.cancel();
    _loadDataCancelToken = null;
    
    for (final token in _operationTokens.values) {
      token.cancel();
    }
    _operationTokens.clear();
    
    if (_currentLoadOperation != null && !_currentLoadOperation!.isCompleted) {
      _currentLoadOperation!.complete();
    }
    _currentLoadOperation = null;
    _isLoadingData = false;
  }

  void _initRepository() {
    try {
      _pragasRepository = Get.find<PragasRepository>();
      _listaPragasService = Get.find<ListaPragasService>();
    } catch (e) {
      throw Exception('Dependencies not available - check bindings configuration');
    }
  }

  void _setupTabController() {
    tabController = TabController(
      length: PragaCulturaUtils.tabTitles.length,
      vsync: this,
    );
    tabController.addListener(_onTabChanged);
  }

  void _setupListeners() {
    searchController.addListener(onSearchChanged);
  }

  void _initializeTheme() {
    _updateState(_state.copyWith(isDark: ThemeManager().isDark.value));
    ThemeManager().isDark.listen((value) {
      _updateState(_state.copyWith(isDark: value));
    });
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      _updateState(_state.copyWith(tabIndex: tabController.index));
      _applyFilter(); // Apply filter when tab changes via TabController
    }
  }

  void onSearchChanged() {
    // Cancel current timer
    _cancelCurrentSearchTimer();
    
    // Get current search text
    final searchText = searchController.text;
    
    // Update state immediately with current search text
    _updateState(_state.copyWith(
      searchText: searchText,
      isSearching: searchText.isNotEmpty,
    ));

    // Start new debounce timer
    _searchDebounceTimer = Timer(PragaCulturaConstants.searchDebounceDelay, () {
      _performSearch(searchText);
    });
  }

  /// Safely cancel current search timer to prevent memory leaks
  void _cancelCurrentSearchTimer() {
    if (_searchDebounceTimer != null) {
      if (_searchDebounceTimer!.isActive) {
        _searchDebounceTimer!.cancel();
      }
      _searchDebounceTimer = null;
    }
  }

  void _performSearch(String searchText) {
    try {
      _applyFilter();
      // Note: _applyFilter() already calls _updateState() with the filtered results
      // No need to call _updateState() again here as it would overwrite the results
    } catch (e) {
      _updateState(_state.copyWith(isSearching: false));
    }
  }

  Future<void> loadInitialData() async {
    // Prevent concurrent loading operations
    if (_isLoadingData) {
      return;
    }

    // If there's an ongoing operation, wait for it to complete
    if (_currentLoadOperation != null && !_currentLoadOperation!.isCompleted) {
      await _currentLoadOperation!.future;
      return;
    }

    _currentLoadOperation = Completer<void>();
    _isLoadingData = true;
    
    _updateState(_state.copyWith(isLoading: true));

    try {
      await loadPragasPorCulturaData();
      _updateState(_state.copyWith(
        culturaNome: culturaSelecionada.value,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false));
    } finally {
      _isLoadingData = false;
      if (!_currentLoadOperation!.isCompleted) {
        _currentLoadOperation!.complete();
      }
    }
  }

  Future<void> loadPragasPorCulturaData() async {
    final String culturaId = culturaSelecionadaId.value;

    if (culturaId.isEmpty) {
      return;
    }

    // Cancel any previous load operation for this cultura
    final operationKey = 'load_pragas_$culturaId';
    _operationTokens[operationKey]?.cancel();
    
    final cancelToken = CancelToken();
    _operationTokens[operationKey] = cancelToken;

    try {
      // Check if operation was cancelled before starting
      if (cancelToken.isCancelled) return;

      // Use service layer for business logic
      final pragas = await _listaPragasService.loadPragasPorCultura(culturaId);
      
      // Check if operation was cancelled after first async call
      if (cancelToken.isCancelled) return;
      
      // Update compatibility lists (legacy support) - now stored in immutable state
      final pragasRelacionadas = await _pragasRepository.getPragasPorCultura(culturaId);
      
      // Final cancellation check before updating state
      if (cancelToken.isCancelled) return;
      
      // Store legacy data in immutable state instead of RxList
      _updateState(_state.copyWith(
        pragasList: pragas,
        pragasFiltered: pragas,
        culturaId: culturaId,
        pragasLegacyData: List<dynamic>.from(pragasRelacionadas),
      ));
      

      _applyFilter();
    } catch (e) {
      if (!cancelToken.isCancelled) {
        _showErrorSnackBar(PragaCulturaConstants.errorLoadingPragasMessage);
      }
    } finally {
      _operationTokens.remove(operationKey);
    }
  }

  void _applyFilter() {
    final searchText = _state.searchText;
    final tabIndex = _state.tabIndex;
    
    // Map tab index to tipoPraga
    String? tipoPragaFilter;
    switch (tabIndex) {
      case 0: // Plantas
        tipoPragaFilter = '3';
        break;
      case 1: // Doenças
        tipoPragaFilter = '2';
        break;
      case 2: // Insetos
        tipoPragaFilter = '1';
        break;
    }
    
    
    // First filter by tab (praga type)
    List<PragaCulturaItemModel> filteredPragas = _state.pragasList;
    
    if (tipoPragaFilter != null) {
      filteredPragas = _listaPragasService.filterPragasByType(filteredPragas, tipoPragaFilter);
    }
    
    // Then filter by search text
    if (searchText.isNotEmpty) {
      filteredPragas = _listaPragasService.filterPragas(filteredPragas, searchText);
    }
    
    _updateState(_state.copyWith(
      pragasFiltered: filteredPragas,
      isSearching: false,
    ));
  }


  void setTabIndex(int index) {
    if (index != _state.tabIndex) {
      _updateState(_state.copyWith(tabIndex: index));
      if (tabController.index != index) {
        tabController.index = index;
      }
      // Apply filter when tab changes to update the displayed data
      _applyFilter();
    }
  }

  void toggleViewMode(ViewMode mode) {
    _updateState(_state.copyWith(viewMode: mode));
  }

  void clearSearch() {
    // Use robust timer cleanup
    _cancelCurrentSearchTimer();
    
    // Clear the search field
    searchController.clear();
    
    // Immediately apply filter with empty search
    _updateState(_state.copyWith(
      searchText: '',
      isSearching: false,
    ));
    _applyFilter();
  }

  List<PragaCulturaItemModel> getPragasPorTipoAtual() {
    // _state.pragasFiltered already contains data filtered by tab type and search text
    // No need to filter again - this was causing the visual update issue
    return _state.pragasFiltered;
  }

  List<PragaCulturaItemModel> getPragasPorTipo(String tipoFiltro) {
    return _listaPragasService.filterPragasByType(_state.pragasFiltered, tipoFiltro);
  }

  PragaUnica? getPragaById(String idReg) {
    try {
      // Use immutable state instead of RxList
      final pragaData = _state.pragasLegacyData.firstWhere(
        (praga) => praga['idReg'].toString() == idReg,
        orElse: () => null,
      );

      if (pragaData != null) {
        return PragaUnica.fromJson(pragaData);
      }
    } catch (e) {
      // Error handled silently
    }
    return null;
  }

  Future<void> navegarParaDetalhes(String idReg) async {
    final operationKey = 'navigate_details_$idReg';
    
    // Cancel any previous navigation operation
    _operationTokens[operationKey]?.cancel();
    
    final cancelToken = CancelToken();
    _operationTokens[operationKey] = cancelToken;
    
    try {
      if (cancelToken.isCancelled) return;
      
      
      // Use immutable state instead of RxList
      await _listaPragasService.getPragaById(idReg, _state.pragasLegacyData);
      
      if (cancelToken.isCancelled) return;
      
      // Pass the praga ID as argument to the details page
      Get.toNamed(
        PragaCulturaConstants.routePragaDetails,
        arguments: {'idReg': idReg},
      );
    } catch (e) {
      if (!cancelToken.isCancelled) {
        _showErrorSnackBar(PragaCulturaConstants.errorLoadingDetailsMessage);
      }
    } finally {
      _operationTokens.remove(operationKey);
    }
  }

  int calculateCrossAxisCount(double screenWidth) {
    return PragaCulturaUtils.calculateCrossAxisCount(screenWidth);
  }

  /// Updates cultura info from navigation arguments
  void updateCulturaInfo(String culturaId, String culturaNome) {
    _updateState(_state.copyWith(
      culturaId: culturaId,
      culturaNome: culturaNome,
    ));
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      PragaCulturaConstants.errorTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  // Compatibility getters
  String get culturaNome => _state.culturaNome;
  ViewMode get viewMode => _state.viewMode;
  int get tabIndex => _state.tabIndex;
  bool get isLoading => _state.isLoading;
  bool get isSearching => _state.isSearching;
}
