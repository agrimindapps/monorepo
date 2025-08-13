// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../core/navigation/i_navigation_service.dart';
import '../../../repository/defensivos_repository.dart';
import '../interfaces/i_filter_service.dart';
import '../interfaces/i_scroll_service.dart';
import '../models/defensivo_model.dart';
import '../models/lista_defensivos_state.dart';
import '../models/view_mode.dart';
import '../utils/defensivos_constants.dart';

/// Controller refatorado seguindo Single Responsibility Principle
/// Responsabilidades: APENAS gerenciamento de estado reativo da UI e coordenação entre services
class ListaDefensivosController extends GetxController {
  final DefensivosRepository _repository;
  final IFilterService _filterService;
  final IScrollService _scrollService;
  final INavigationService _navigationService;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Estado reativo usando GetX
  final Rx<ListaDefensivosState> _state = const ListaDefensivosState().obs;
  ListaDefensivosState get state => _state.value;

  BuildContext? context;

  // Worker para cleanup adequado de listeners
  Worker? _themeWorker;

  // Timer para debounce na busca
  Timer? _searchDebounceTimer;

  ListaDefensivosController({
    required DefensivosRepository repository,
    required IFilterService filterService,
    required IScrollService scrollService,
    required INavigationService navigationService,
  })  : _repository = repository,
        _filterService = filterService,
        _scrollService = scrollService,
        _navigationService = navigationService;

  void _updateState(ListaDefensivosState newState) {
    _state.value = newState;
  }

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  void initialize() {
    _configureStatusBar();
    _setupListeners();
    _initializeTheme();
  }

  void _configureStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  void _setupListeners() {
    scrollController.addListener(_scrollListener);
    textController.addListener(_filterItems);
  }

  void _scrollListener() {
    if (_scrollService.shouldLoadMore(
      scrollController.position.pixels,
      scrollController.position.maxScrollExtent,
      DefensivosConstants.scrollThreshold,
      state.isLoading,
      state.finalPage,
      state.defensivosListFiltered.isNotEmpty,
    )) {
      _loadMoreItems();
    }
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    _themeWorker = ever(ThemeManager().isDark, (bool isDark) {
      _updateState(state.copyWith(isDark: isDark));
    });
  }

  Future<void> loadInitialData() async {
    try {
      _updateState(state.copyWith(
        isLoading: true,
        title: 'Defensivos',
      ));

      final databaseRepository = _repository.getDatabaseRepository();
      if (!databaseRepository.isLoaded.value) {
        int attempts = 0;
        while (!databaseRepository.isLoaded.value &&
            attempts < DefensivosConstants.maxDatabaseLoadAttempts) {
          await Future.delayed(DefensivosConstants.databaseLoadDelay);
          attempts++;
        }

        if (!databaseRepository.isLoaded.value) {
          throw Exception('Timeout ao aguardar carregamento do banco de dados');
        }
      }

      final defensivosData = _repository.getDefensivos();
      final defensivos =
          defensivosData.map((item) => DefensivoModel.fromMap(item)).toList();

      _updateState(state.copyWith(
        defensivosCompletos: defensivos,
        defensivosList: defensivos,
      ));

      _filtrarRegistros(false, textController.text);
    } catch (e) {
      _updateState(state.copyWith(isLoading: false));
      _showErrorSnackBar(
          'Erro ao carregar dados. Tente novamente.', () => loadInitialData());
    }
  }

  /// Filtra itens com debounce de 300ms para otimizar performance
  /// Aplica filtro imediatamente se a busca estiver vazia
  void _filterItems() {
    // Cancela timer anterior se existir
    _searchDebounceTimer?.cancel();

    final searchText = textController.text;

    // Se busca está vazia, aplica filtro imediatamente
    if (searchText.isEmpty) {
      _updateState(state.copyWith(isSearching: false));
      _filtrarRegistros(true, searchText);
      return;
    }

    // Indica que uma busca está em andamento (para mostrar loading)
    _updateState(state.copyWith(isSearching: true));

    // Aplica debounce para buscas com texto
    _searchDebounceTimer = Timer(DefensivosConstants.searchDebounceDelay, () {
      _updateState(state.copyWith(isSearching: false));
      _filtrarRegistros(true, searchText);
    });
  }

  void _filtrarRegistros(bool isSearch, String searchText) {
    if (isSearch) {
      _updateState(state.copyWith(
        defensivosListFiltered: [],
        currentPage: 0,
      ));
    }

    final tempFiltered = _filterByText(searchText);
    _updateFilteredList(tempFiltered, isSearch);
  }

  void _filtrarRegistrosComOrdenacao(
      bool isSearch, String searchText, String sortField, bool isAscending) {
    if (isSearch) {
      _updateState(state.copyWith(
        defensivosListFiltered: [],
        currentPage: 0,
      ));
    }

    final sortedCompleteList =
        _sortCompleteList(state.defensivosCompletos, sortField, isAscending);
    final tempFiltered = _filterByTextFromList(sortedCompleteList, searchText);

    _updateState(state.copyWith(defensivosList: sortedCompleteList));
    _updateFilteredList(tempFiltered, isSearch);
  }

  List<DefensivoModel> _filterByText(String searchText) {
    return _filterByTextFromList(state.defensivosList, searchText);
  }

  List<DefensivoModel> _filterByTextFromList(
      List<DefensivoModel> sourceList, String searchText) {
    return _filterService.filterByText<DefensivoModel>(
      sourceList,
      searchText,
      (defensivo) => defensivo.line1,
      (defensivo) => defensivo.line2,
    );
  }

  void _updateFilteredList(List<DefensivoModel> filteredItems, bool isSearch) {
    // Se é uma busca, limpa a lista filtrada e reseta a página
    if (isSearch) {
      _updateState(state.copyWith(
        defensivosListFiltered: [],
        currentPage: 0,
      ));
    }

    // Se não há itens para filtrar, apenas atualiza o loading
    if (filteredItems.isEmpty) {
      _updateState(state.copyWith(
        defensivosListFiltered: [],
        isLoading: false,
        finalPage: true,
      ));
      return;
    }

    // Carrega o lote inicial se a lista filtrada estiver vazia
    if (state.defensivosListFiltered.isEmpty) {
      final initialCount = DefensivosConstants.itemsPerScroll < filteredItems.length
          ? DefensivosConstants.itemsPerScroll
          : filteredItems.length;

      final initialItems = filteredItems.take(initialCount).toList();
      
      _updateState(state.copyWith(
        defensivosListFiltered: initialItems,
        currentPage: 1,
        isLoading: false,
        finalPage: initialItems.length >= filteredItems.length,
      ));
    } else {
      // Adiciona mais itens se já existe conteúdo na lista filtrada
      final itemsToAdd = _filterService.calculateItemsToAdd(
        state.currentPage,
        state.defensivosListFiltered.length,
        filteredItems.length,
        DefensivosConstants.itemsPerScroll,
      );

      if (itemsToAdd > 0) {
        final startIndex = state.defensivosListFiltered.length;
        final endIndex = (startIndex + itemsToAdd).clamp(0, filteredItems.length);
        
        if (startIndex < endIndex) {
          final newItems = filteredItems.sublist(startIndex, endIndex);
          final updatedFiltered = List<DefensivoModel>.from(state.defensivosListFiltered);
          updatedFiltered.addAll(newItems);

          _updateState(state.copyWith(
            defensivosListFiltered: updatedFiltered,
            currentPage: state.currentPage + 1,
            isLoading: false,
            finalPage: endIndex >= filteredItems.length,
          ));
        } else {
          _updateState(state.copyWith(
            isLoading: false,
            finalPage: true,
          ));
        }
      } else {
        _updateState(state.copyWith(
          isLoading: false,
          finalPage: true,
        ));
      }
    }
  }

  List<DefensivoModel> _sortCompleteList(
      List<DefensivoModel> inputList, String sortField, bool isAscending) {
    return _filterService.sortList<DefensivoModel>(
      inputList,
      sortField,
      isAscending,
      (defensivo) => defensivo.line1,
      (defensivo) => defensivo.line2,
    );
  }

  void toggleSort() {
    final newIsAscending = !state.isAscending;
    _updateState(state.copyWith(isAscending: newIsAscending));
    _resetAndReloadWithSort();
  }

  void toggleViewMode(ViewMode mode) {
    _updateState(state.copyWith(selectedViewMode: mode));
  }

  void _resetPage() {
    _updateState(state.copyWith(
      currentPage: 0,
      finalPage: false,
    ));
    _repository.resetPage();
  }

  void _resetAndReloadWithSort() {
    _resetPage();
    _updateState(state.copyWith(
      defensivosList: [],
      defensivosListFiltered: [],
      isLoading: true,
    ));

    try {
      _filtrarRegistrosComOrdenacao(
          false, textController.text, state.sortField, state.isAscending);
    } catch (e) {
      _showErrorSnackBar(
          'Erro ao reordenar dados', () => _resetAndReloadWithSort());
    }
  }

  /// Limpa o campo de busca e cancela qualquer debounce ativo
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    textController.clear();
  }

  void handleItemTap(DefensivoModel defensivo) {
    _navigationService.navigateToDefensivoDetails(defensivo.idReg);
  }

  void _loadMoreItems() {
    if (!_scrollService.shouldLoadMore(
      scrollController.position.pixels,
      scrollController.position.maxScrollExtent,
      DefensivosConstants.scrollThreshold,
      state.isLoading,
      state.finalPage,
      state.defensivosListFiltered.isNotEmpty,
    )) {
      return;
    }

    _updateState(state.copyWith(isLoading: true));
    try {
      _onScrollEnd();
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar mais itens', null);
    } finally {
      _updateState(state.copyWith(isLoading: false));
    }
  }

  void _onScrollEnd() {
    // Obtém a lista atualmente sendo exibida (filtrada ou completa)
    final currentList = textController.text.isEmpty 
        ? state.defensivosList 
        : _filterByText(textController.text);
    
    final startIndex = state.defensivosListFiltered.length;

    if (startIndex >= currentList.length) {
      _updateState(state.copyWith(finalPage: true));
      return;
    }

    final endIndex = (startIndex + DefensivosConstants.itemsPerScroll)
        .clamp(0, currentList.length);

    if (startIndex < endIndex) {
      final newItems = currentList.sublist(startIndex, endIndex);
      final updatedFiltered =
          List<DefensivoModel>.from(state.defensivosListFiltered);
      updatedFiltered.addAll(newItems);

      final isFinalPage = endIndex >= currentList.length;

      _updateState(state.copyWith(
        currentPage: state.currentPage + 1,
        defensivosListFiltered: updatedFiltered,
        finalPage: isFinalPage,
      ));
    }
  }

  void _showErrorSnackBar(String message, VoidCallback? onRetry) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade800,
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Tentar novamente',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
              : null,
        ),
      );
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    _themeWorker?.dispose();
    scrollController.removeListener(_scrollListener);
    textController.removeListener(_filterItems);
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
