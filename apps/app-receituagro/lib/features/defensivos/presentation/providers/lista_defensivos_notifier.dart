import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/fitossanitario_drift_extension.dart';
import '../../../../core/providers/core_providers.dart' as core_providers;
import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../data/view_mode.dart';

part 'lista_defensivos_notifier.g.dart';

/// Lista defensivos state
class ListaDefensivosState {
  final List<Fitossanitario> allDefensivos;
  final List<Fitossanitario> filteredDefensivos;
  final List<Fitossanitario> displayedDefensivos;
  final ViewMode selectedViewMode;
  final bool isLoading;
  final bool isSearching;
  final bool isAscending;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchText;
  final int currentPage;

  const ListaDefensivosState({
    required this.allDefensivos,
    required this.filteredDefensivos,
    required this.displayedDefensivos,
    required this.selectedViewMode,
    required this.isLoading,
    required this.isSearching,
    required this.isAscending,
    required this.isLoadingMore,
    this.errorMessage,
    required this.searchText,
    required this.currentPage,
  });

  factory ListaDefensivosState.initial() {
    return const ListaDefensivosState(
      allDefensivos: [],
      filteredDefensivos: [],
      displayedDefensivos: [],
      selectedViewMode: ViewMode.list,
      isLoading: true,
      isSearching: false,
      isAscending: true,
      isLoadingMore: false,
      errorMessage: null,
      searchText: '',
      currentPage: 0,
    );
  }

  ListaDefensivosState copyWith({
    List<Fitossanitario>? allDefensivos,
    List<Fitossanitario>? filteredDefensivos,
    List<Fitossanitario>? displayedDefensivos,
    ViewMode? selectedViewMode,
    bool? isLoading,
    bool? isSearching,
    bool? isAscending,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchText,
    int? currentPage,
  }) {
    return ListaDefensivosState(
      allDefensivos: allDefensivos ?? this.allDefensivos,
      filteredDefensivos: filteredDefensivos ?? this.filteredDefensivos,
      displayedDefensivos: displayedDefensivos ?? this.displayedDefensivos,
      selectedViewMode: selectedViewMode ?? this.selectedViewMode,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isAscending: isAscending ?? this.isAscending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  ListaDefensivosState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get hasData => allDefensivos.isNotEmpty;
  bool get hasFilteredData => displayedDefensivos.isNotEmpty;
  bool get canLoadMore =>
      displayedDefensivos.length < filteredDefensivos.length;

  /// Get header subtitle text
  String getHeaderSubtitle() {
    final total = allDefensivos.length;
    final filtered = filteredDefensivos.length;

    if (isLoading && total == 0) {
      return 'Carregando defensivos...';
    }

    if (errorMessage != null) {
      return 'Erro no carregamento';
    }

    if (filtered < total) {
      return '$filtered de $total defensivos';
    }

    return '$total defensivos disponíveis';
  }
}

/// Notifier following SOLID principles for Lista Defensivos functionality
/// Implements Dependency Inversion Principle by injecting repository
/// Optimizes performance by consolidating state updates
@riverpod
class ListaDefensivosNotifier extends _$ListaDefensivosNotifier {
  late final FitossanitariosRepository _repository;
  Timer? _debounceTimer;

  static const int _itemsPerPage = 50;

  @override
  Future<ListaDefensivosState> build() async {
    _repository = ref.watch(core_providers.fitossanitariosRepositoryProvider);
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return await _loadData();
  }

  /// Load initial data
  Future<ListaDefensivosState> _loadData() async {
    try {
      final defensivos = await _repository.findElegiveis();
      defensivos.sort(
        (Fitossanitario a, Fitossanitario b) =>
            (a.displayName).compareTo(b.displayName),
      );
      final endIndex = _itemsPerPage.clamp(0, defensivos.length);
      final displayedDefensivos = defensivos.sublist(0, endIndex);

      return ListaDefensivosState(
        allDefensivos: defensivos,
        filteredDefensivos: defensivos,
        displayedDefensivos: displayedDefensivos,
        selectedViewMode: ViewMode.list,
        isLoading: false,
        isSearching: false,
        isAscending: true,
        isLoadingMore: false,
        errorMessage: null,
        searchText: '',
        currentPage: 0,
      );
    } catch (e) {
      return ListaDefensivosState.initial().copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar defensivos: $e',
      );
    }
  }

  /// Reload data
  Future<void> loadData() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    final newState = await _loadData();
    state = AsyncValue.data(newState);
  }

  /// Perform search with debouncing
  void search(String searchText) {
    final currentState = state.value;
    if (currentState == null) return;

    _debounceTimer?.cancel();

    if (searchText.isEmpty) {
      state = AsyncValue.data(
        _updateSearchState(
          currentState: currentState,
          searchText: '',
          isSearching: false,
          filteredData: List.from(currentState.allDefensivos),
        ),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(searchText: searchText, isSearching: true),
    );

    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      _performSearch(searchText);
    });
  }

  /// Clear search
  void clearSearch() {
    final currentState = state.value;
    if (currentState == null) return;

    _debounceTimer?.cancel();

    state = AsyncValue.data(
      _updateSearchState(
        currentState: currentState,
        searchText: '',
        isSearching: false,
        filteredData: List.from(currentState.allDefensivos),
      ),
    );
  }

  /// Toggle sort order
  void toggleSort() {
    final currentState = state.value;
    if (currentState == null) return;

    final isAscending = !currentState.isAscending;
    final sortedFiltered = List<Fitossanitario>.from(
      currentState.filteredDefensivos,
    );
    sortedFiltered.sort((Fitossanitario a, Fitossanitario b) {
      return isAscending
          ? (a.displayName).compareTo(b.displayName)
          : (b.displayName).compareTo(a.displayName);
    });
    final endIndex = _itemsPerPage.clamp(0, sortedFiltered.length);
    final displayedDefensivos = sortedFiltered.sublist(0, endIndex);

    state = AsyncValue.data(
      currentState.copyWith(
        isAscending: isAscending,
        filteredDefensivos: sortedFiltered,
        displayedDefensivos: displayedDefensivos,
        currentPage: 0,
      ),
    );
  }

  /// Toggle view mode
  void toggleViewMode(ViewMode viewMode) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.selectedViewMode != viewMode) {
      state = AsyncValue.data(
        currentState.copyWith(selectedViewMode: viewMode),
      );
    }
  }

  /// Load more items for pagination
  Future<void> loadMoreItems() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.isLoadingMore || !currentState.canLoadMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final nextPage = currentState.currentPage + 1;
    final startIndex = nextPage * _itemsPerPage;
    final endIndex = ((nextPage + 1) * _itemsPerPage).clamp(
      0,
      currentState.filteredDefensivos.length,
    );

    if (startIndex < currentState.filteredDefensivos.length) {
      final newItems = currentState.filteredDefensivos.sublist(
        startIndex,
        endIndex,
      );
      final updatedDisplayed = List<Fitossanitario>.from(
        currentState.displayedDefensivos,
      )..addAll(newItems);

      state = AsyncValue.data(
        currentState.copyWith(
          displayedDefensivos: updatedDisplayed,
          currentPage: nextPage,
          isLoadingMore: false,
        ),
      );
    } else {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Clear current error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.clearError());
    }
  }

  /// Perform the actual search
  void _performSearch(String searchText) {
    final currentState = state.value;
    if (currentState == null) return;

    final searchLower = searchText.toLowerCase();

    final filtered = currentState.allDefensivos.where((defensivo) {
      return defensivo.displayName.toLowerCase().contains(searchLower) ||
          defensivo.displayIngredient.toLowerCase().contains(searchLower) ||
          defensivo.displayClass.toLowerCase().contains(searchLower) ||
          defensivo.displayFabricante.toLowerCase().contains(searchLower);
    }).toList();
    filtered.sort((a, b) => a.displayName.compareTo(b.displayName));

    state = AsyncValue.data(
      _updateSearchState(
        currentState: currentState,
        searchText: searchText,
        isSearching: false,
        filteredData: filtered,
      ),
    );
  }

  /// Update search state with single notification
  ListaDefensivosState _updateSearchState({
    required ListaDefensivosState currentState,
    required String searchText,
    required bool isSearching,
    required List<Fitossanitario> filteredData,
  }) {
    final endIndex = _itemsPerPage.clamp(0, filteredData.length);
    final displayedDefensivos = filteredData.sublist(0, endIndex);

    return currentState.copyWith(
      searchText: searchText,
      isSearching: isSearching,
      filteredDefensivos: filteredData,
      displayedDefensivos: displayedDefensivos,
      currentPage: 0,
    );
  }
}
