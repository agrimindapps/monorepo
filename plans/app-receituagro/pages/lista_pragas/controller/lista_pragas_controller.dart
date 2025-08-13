// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../core/navigation/navigation_service.dart';
import '../models/lista_pragas_state.dart';
import '../models/praga_item_model.dart';
import '../models/view_mode.dart';
import '../services/praga_data_service.dart';
import '../services/praga_filter_service.dart';
import '../services/praga_sort_service.dart';
import '../utils/praga_constants.dart';
import '../utils/praga_type_helper.dart';

class ListaPragasController extends GetxController {
  final IPragaDataService _dataService;
  final IPragaFilterService _filterService;
  final IPragaSortService _sortService;
  final NavigationService _navigationService;
  final TextEditingController searchController = TextEditingController();

  // Debounce functionality
  Timer? _searchDebounceTimer;
  
  // Loading operation control
  bool _isLoadingInProgress = false;
  Completer<void>? _loadingCompleter;

  final Rx<ListaPragasState> _state = const ListaPragasState().obs;
  ListaPragasState get state => _state.value;

  ListaPragasController({
    IPragaDataService? dataService,
    IPragaFilterService? filterService,
    IPragaSortService? sortService,
    NavigationService? navigationService,
  })  : _dataService = dataService ?? PragaDataService(),
        _filterService = filterService ?? PragaFilterService(),
        _sortService = sortService ?? PragaSortService(),
        _navigationService = navigationService ?? NavigationService() {
    _initializeController();
  }

  void _initializeController() {
    searchController.addListener(_onSearchChanged);
    _initializeTheme();
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    ThemeManager().isDark.listen((value) {
      _updateState(state.copyWith(isDark: value));
    });
  }

  void _updateState(ListaPragasState newState) {
    _state.value = newState;
  }

  void loadInitialData() {
    final routeArguments = Get.arguments; // Use Get.arguments
    final pragaType = PragaTypeHelper.getTypeFromArguments(routeArguments);

    _updateState(state.copyWith(pragaType: pragaType));
    _safeLoadPragas();
  }

  Future<void> _safeLoadPragas() async {
    // Prevent race conditions by checking if loading is already in progress
    if (_isLoadingInProgress) {
      // Wait for the current loading operation to complete
      await _loadingCompleter?.future;
      return;
    }

    _isLoadingInProgress = true;
    _loadingCompleter = Completer<void>();

    try {
      await _loadPragas();
    } finally {
      _isLoadingInProgress = false;
      if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
        _loadingCompleter!.complete();
      }
      _loadingCompleter = null;
    }
  }

  Future<void> _loadPragas() async {
    if (state.isLoading) return;

    _updateState(state.copyWith(isLoading: true));

    try {
      final pragas = await _dataService.loadPragas(state.pragaType);

      _updateState(state.copyWith(
        pragas: pragas,
        pragasFiltered: pragas,
        isLoading: false,
      ));

      _applyCurrentFilter();
    } catch (e) {
      _updateState(state.copyWith(isLoading: false));
      _showErrorSnackBar('Erro ao carregar pragas. Tente novamente.');
    }
  }

  @Deprecated('Use _safeLoadPragas() instead to prevent race conditions')
  Future<void> loadPragas() async {
    await _safeLoadPragas();
  }

  Future<void> getPragaById(String id) async {
    try {
      await _dataService.getPragaById(id);
    } catch (e) {
      // Error handled silently
    }
  }

  void _onSearchChanged() {
    onSearchChanged();
  }

  void onSearchChanged() {
    // Cancel previous timer if it exists
    _searchDebounceTimer?.cancel();
    
    final searchText = searchController.text;
    
    // Update search text immediately for UI feedback
    _updateState(state.copyWith(
      searchText: searchText,
      isSearching: searchText.isNotEmpty,
    ));

    // Start new debounce timer for actual filtering
    _searchDebounceTimer = Timer(PragaConstants.searchDebounce, () {
      _performDebouncedSearch(searchText);
    });
  }

  void _performDebouncedSearch(String searchText) {
    try {
      _applyCurrentFilter();
      _updateState(state.copyWith(isSearching: false));
    } catch (e) {
      _updateState(state.copyWith(isSearching: false));
    }
  }

  void _applyCurrentFilter() {
    final filtered = _filterService.filterPragas(state.pragas, state.searchText);
    _updateState(state.copyWith(pragasFiltered: filtered));
  }

  void toggleSort() {
    final newIsAscending = !state.isAscending;
    final sortedList = _sortService.sortPragas(state.pragasFiltered, newIsAscending);

    _updateState(state.copyWith(
      isAscending: newIsAscending,
      pragasFiltered: sortedList,
    ));
  }

  void toggleViewMode(ViewMode mode) {
    _updateState(state.copyWith(viewMode: mode));
  }

  void clearSearch() {
    // Cancel any pending search
    _searchDebounceTimer?.cancel();
    
    // Clear the search field
    searchController.clear();
    
    // Immediately apply filter with empty search
    _updateState(state.copyWith(
      searchText: '',
      isSearching: false,
    ));
    _applyCurrentFilter();
  }

  void ensureDataLoaded() {
    if (state.pragas.isEmpty && !_isLoadingInProgress) {
      _safeLoadPragas();
    }
  }

  void handleItemTap(PragaItemModel praga) {
    getPragaById(praga.idReg);
    _navigationService.navigateToPragaDetails(praga.idReg);
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      PragaConstants.errorTitle,
      message,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: PragaConstants.defaultSnackPosition,
      margin: PragaConstants.snackBarMargin,
    );
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    
    // Complete any pending loading operations to prevent memory leaks
    if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
      _loadingCompleter!.complete();
    }
    
    super.onClose();
  }
}
