// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../repository/defensivos_repository.dart';
import '../config/ui_constants.dart';
import '../models/defensivo_item_model.dart';
import '../models/defensivos_state.dart';
import '../models/view_mode.dart';
import '../services/monitoring_service.dart';
import '../utils/defensivos_category.dart';
import '../utils/defensivos_helpers.dart';

/// Controller for Lista Defensivos Agrupados page

class ListaDefensivosAgrupadosController extends GetxController {
  late final DefensivosRepository _repository;
  final IMonitoringService _monitoringService;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  // Estado reativo usando GetX
  final Rx<DefensivosState> _state = const DefensivosState().obs;
  DefensivosState get state => _state.value;

  BuildContext? context;

  // Controle de listeners para cleanup adequado
  Worker? _themeWorker;
  
  // Timer para debounce na busca
  Timer? _searchDebounceTimer;
  
  // ID único do controller para tracking
  late final String _controllerId;

  ListaDefensivosAgrupadosController({
    IMonitoringService? monitoringService,
  }) : _monitoringService = monitoringService ?? MonitoringService();

  void _updateState(DefensivosState newState) {
    _state.value = newState;
    update(); // Força atualização do GetBuilder
  }

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  @override
  void onInit() {
    super.onInit();
    
    // Gerar ID único para tracking
    _controllerId = 'DefensivosController_${DateTime.now().millisecondsSinceEpoch}';
    _monitoringService.initializeMonitoring(_controllerId);
    
    _initRepository();
    setupControllers();
    _loadInitialDataAsync();
  }

  void _initRepository() {
    try {
      _repository = Get.find<DefensivosRepository>();
    } catch (e) {
      _repository = DefensivosRepository();
    }
  }

  void setupControllers() {
    // Adicionar listeners com tracking para cleanup
    scrollController.addListener(scrollListener);
    _monitoringService.registerListener('scroll', () => scrollController.removeListener(scrollListener));
    
    textController.addListener(filterItems);
    _monitoringService.registerListener('text', () => textController.removeListener(filterItems));
    
    _initializeTheme();
    
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    
    // Usar Worker do GetX para observar mudanças de tema
    _themeWorker = ever(ThemeManager().isDark, (bool isDark) {
      _updateState(state.copyWith(isDark: isDark));
    });
    _monitoringService.registerWorker('theme');
  }

  void _loadInitialDataAsync() {
    Future.delayed(DefensivosPageConstants.initialDataDelay, () async {
      try {
        try {
          _repository.getDatabaseRepository();
        } catch (e) {
          Future.delayed(const Duration(milliseconds: PerformanceConstants.retryTimeoutMillis), () {
            _loadInitialDataAsync();
          });
          return;
        }

        final dbRepo = _repository.getDatabaseRepository();

        if (!dbRepo.isLoaded.value) {
          int attempts = 0;
          while (!dbRepo.isLoaded.value &&
              attempts < DefensivosPageConstants.maxDatabaseLoadAttempts) {
            await Future.delayed(DefensivosPageConstants.databaseLoadDelay);
            attempts++;
          }

          if (!dbRepo.isLoaded.value) {
            throw Exception(
                'Timeout waiting for database to load');
          }
        }

        loadInitialData();
      } catch (e) {
        _updateState(state.copyWith(isLoading: false));
      }
    });
  }

  void loadInitialData() {
    // Só chama filtrarRegistros se a lista filtrada estiver vazia
    if (state.defensivosListFiltered.isEmpty) {
      filtrarRegistros(false, textController.text);
    }
  }

  void filterItems() {
    // Cancela timer anterior se existir
    _searchDebounceTimer?.cancel();

    final searchText = textController.text;

    // Se busca está vazia, aplica filtro imediatamente
    if (searchText.isEmpty) {
      _updateState(state.copyWith(isSearching: false, searchText: searchText));
      filtrarRegistros(true, searchText);
      return;
    }

    // Indica que uma busca está em andamento (para mostrar loading)
    _updateState(state.copyWith(isSearching: true, searchText: searchText));

    // Aplica debounce para buscas com texto (300ms como na lista_defensivos)
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateState(state.copyWith(isSearching: false));
      filtrarRegistros(true, searchText);
    });
  }

  void scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent -
                DefensivosPageConstants.scrollThreshold &&
        !state.finalPage && 
        !state.isLoading) {
      onScrollEnd();
    }
  }

  void toggleSort() {
    final newIsAscending = !state.isAscending;
    final sortedList = _sortDefensivos(
        state.defensivosListFiltered, state.sortField, newIsAscending);

    _updateState(state.copyWith(
      isAscending: newIsAscending,
      defensivosListFiltered: sortedList,
    ));
  }

  void toggleViewMode(ViewMode mode) {
    _updateState(state.copyWith(selectedViewMode: mode));
  }

  /// Limpa o campo de busca e cancela qualquer debounce ativo
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    textController.clear();
  }

  void handleItemTap(DefensivoItemModel item) {
    // Limpa o campo de pesquisa ao clicar em um item (sem disparar o listener)
    _clearSearchFieldSilently();
    
    if (item.isDefensivo) {
      Get.toNamed(
        '/receituagro/defensivos/detalhes',
        arguments: item.idReg,
      );
    } else {
      // Navegação hierárquica: entrar no grupo
      _navigateToGroup(item);
    }
  }

  void _clearSearchFieldSilently() {
    // Remove o listener temporariamente para evitar interferência
    textController.removeListener(filterItems);
    _searchDebounceTimer?.cancel();
    textController.clear();
    // Readic iona o listener
    textController.addListener(filterItems);
  }

  void _navigateToGroup(DefensivoItemModel item) {
    // Salva o estado atual das categorias antes de navegar
    final currentCategories = List<DefensivoItemModel>.from(state.defensivosList);
    
    
    resetPage();
    
    // Atualiza o estado para nível 1 (dentro do grupo)
    _updateState(state.copyWith(
      navigationLevel: 1,
      selectedGroupId: item.idReg,
      categoriesList: currentCategories,
    ));
    
    // Carrega os dados do grupo
    carregaDados(state.categoria, item.idReg);
  }

  bool canNavigateBack() {
    final canNavigate = state.navigationLevel > 0;
    return canNavigate;
  }

  void navigateBack() {
    if (state.navigationLevel == 1) {
      // Voltar do nível do grupo para as categorias
      _backToCategories();
    }
  }

  void _backToCategories() {
    
    // Limpa o campo de pesquisa silenciosamente
    _clearSearchFieldSilently();
    
    // Restaura a lista de categorias
    final categoriesTitle = _getCategoriesTitle();
    
    
    _updateState(state.copyWith(
      navigationLevel: 0,
      selectedGroupId: '',
      title: categoriesTitle,
      defensivosList: state.categoriesList,
      defensivosListFiltered: [],
      currentPage: 0,
      finalPage: false,
    ));


    // Carrega as categorias novamente
    _resetListState();
    filtrarRegistros(false, '');
  }

  String _getCategoriesTitle() {
    switch (state.categoria) {
      case 'fabricantes':
        return 'Fabricantes';
      case 'classeAgronomica':
        return 'Classes Agronômicas';
      case 'ingredienteAtivo':
        return 'Ingredientes Ativos';
      case 'modoAcao':
        return 'Modos de Ação';
      default:
        return 'Defensivos';
    }
  }

  void resetPage() {
    _updateState(state.copyWith(
      currentPage: 0,
      defensivosListFiltered: [],
      finalPage: false,
    ));
    _repository.resetPage();
  }

  void filtrarRegistros(bool isSearch, String searchText) {
    if (isSearch) {
      _updateState(state.copyWith(
        defensivosListFiltered: [],
        currentPage: 0,
      ));
    }

    final tempFiltered = _filterByText(searchText);
    _updateFilteredList(tempFiltered, isSearch);
  }

  List<DefensivoItemModel> _filterByText(String searchText) {
    return _filterByTextFromList(state.defensivosList, searchText);
  }

  List<DefensivoItemModel> _filterByTextFromList(
      List<DefensivoItemModel> sourceList, String searchText) {
    
    if (searchText.length < DefensivosPageConstants.minSearchLength) {
      return sourceList;
    }

    final searchLower = searchText.toLowerCase();
    final filtered = sourceList
        .where((item) =>
            item.line1.toLowerCase().contains(searchLower) ||
            item.line2.toLowerCase().contains(searchLower))
        .toList();
    
    return filtered;
  }

  List<DefensivoItemModel> _sortDefensivos(
      List<DefensivoItemModel> defensivosToSort,
      String sortField,
      bool isAscending) {
    final sortedList = List<DefensivoItemModel>.from(defensivosToSort);
    sortedList.sort((a, b) {
      String aValue;
      String bValue;

      switch (sortField) {
        case 'line1':
          aValue = a.line1;
          bValue = b.line1;
          break;
        case 'line2':
          aValue = a.line2;
          bValue = b.line2;
          break;
        default:
          aValue = a.line1;
          bValue = b.line1;
      }

      if (isAscending) {
        return aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else {
        return bValue.toLowerCase().compareTo(aValue.toLowerCase());
      }
    });
    return sortedList;
  }

  void onScrollEnd() {
    _loadMoreItems();
  }

  void _loadMoreItems() {
    if (state.isLoading || state.finalPage) {
      return;
    }

    _updateState(state.copyWith(isLoading: true));

    final newPage = state.currentPage + 1;
    final startIndex = newPage * DefensivosPageConstants.itemsPerScroll;

    if (startIndex >= state.defensivosList.length) {
      _updateState(state.copyWith(finalPage: true, isLoading: false));
      return;
    }

    final endIndex = (newPage + 1) * DefensivosPageConstants.itemsPerScroll <
            state.defensivosList.length
        ? (newPage + 1) * DefensivosPageConstants.itemsPerScroll
        : state.defensivosList.length;

    final newItems = state.defensivosList.sublist(startIndex, endIndex);
    final updatedFiltered =
        List<DefensivoItemModel>.from(state.defensivosListFiltered);
    updatedFiltered.addAll(newItems);

    final isFinalPage = endIndex >= state.defensivosList.length;

    _updateState(state.copyWith(
      currentPage: newPage,
      defensivosListFiltered: updatedFiltered,
      finalPage: isFinalPage,
      isLoading: false,
    ));
  }

  void _updateFilteredList(
      List<DefensivoItemModel> filteredItems, bool isSearch) {
    final itemsToAdd = _calculateItemsToAdd(filteredItems);
    final itemsToAddList = filteredItems.take(itemsToAdd).toList();

    List<DefensivoItemModel> newFiltered;
    if (isSearch) {
      newFiltered = itemsToAddList;
    } else {
      newFiltered =
          List<DefensivoItemModel>.from(state.defensivosListFiltered);
      newFiltered.addAll(itemsToAddList);
    }

    _updateState(state.copyWith(
      defensivosListFiltered: newFiltered,
      isLoading: false,
    ));
  }

  int _calculateItemsToAdd(List<DefensivoItemModel> itemsList) {
    if (state.currentPage == 0 || state.defensivosListFiltered.isEmpty) {
      return DefensivosPageConstants.itemsPerScroll < itemsList.length
          ? DefensivosPageConstants.itemsPerScroll
          : itemsList.length;
    }
    final remaining = itemsList.length - state.defensivosListFiltered.length;
    return remaining < DefensivosPageConstants.itemsPerScroll
        ? remaining
        : DefensivosPageConstants.itemsPerScroll;
  }

  Future<void> getDefensivoById(String idReg) async {
    try {
      await _repository.getDefensivoById(idReg);
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: const Text('Erro ao carregar detalhes do defensivo'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void carregaDados(String categoryType, String textoFiltro) {
    
    resetPage();

    final category = DefensivosCategory.fromString(categoryType);
    
    // Se textoFiltro está vazio, estamos carregando as categorias (nível 0)
    // Se textoFiltro não está vazio, estamos dentro de um grupo (nível 1)
    final navLevel = textoFiltro.isEmpty ? 0 : state.navigationLevel;
    
    _updateState(state.copyWith(
      categoria: categoryType,
      isLoading: true,
      navigationLevel: navLevel,
    ));

    if (textoFiltro.isEmpty) {
      _carregarListaCategorias(category);
    } else {
      _carregarDefensivosFiltrados(category, textoFiltro);
    }
  }

  void _carregarListaCategorias(DefensivosCategory category) {
    final dbRepo = _repository.getDatabaseRepository();

    if (!dbRepo.isLoaded.value || dbRepo.gFitossanitarios.isEmpty) {
      _updateState(state.copyWith(isLoading: true));
      Future.delayed(DefensivosPageConstants.retryDelay, () {
        _carregarListaCategorias(category);
      });
      return;
    }

    final title = category.title;

    switch (category) {
      case DefensivosCategory.defensivos:
        _loadDefensivos(false, title);
        break;
      case DefensivosCategory.fabricantes:
        _loadFabricante(false, title);
        break;
      case DefensivosCategory.classeAgronomica:
        _loadClasseAgronomica(false, title);
        break;
      case DefensivosCategory.ingredienteAtivo:
        _loadIngredienteAtivo(false, title);
        break;
      case DefensivosCategory.modoAcao:
        _loadModoDeAcao(false, title);
        break;
    }
  }

  void _carregarDefensivosFiltrados(
      DefensivosCategory category, String textoFiltro) {
    final title = DefensivosHelpers.getTitleWithFilter(category, textoFiltro);

    switch (category) {
      case DefensivosCategory.defensivos:
        _loadDefensivos(false, title);
        break;
      case DefensivosCategory.fabricantes:
        _loadFabricanteById(textoFiltro, title);
        break;
      case DefensivosCategory.classeAgronomica:
        _loadClasseAgronomicaById(textoFiltro, title);
        break;
      case DefensivosCategory.ingredienteAtivo:
        _loadIngredienteAtivoById(textoFiltro, title);
        break;
      case DefensivosCategory.modoAcao:
        _loadModoDeAcaoById(textoFiltro, title);
        break;
    }
  }

  void _loadDefensivos(bool count, String title) {
    if (!count) {
      final items = _repository.getDefensivos();
      _updateDefensivosList(items, true, title);
    }
  }

  void _loadFabricante(bool count, String title) {
    if (!count) {
      try {
        final items = _repository.getFabricante();
        _updateDefensivosList(items, false, title);
      } catch (e) {
        _updateState(state.copyWith(isLoading: false));
      }
    }
  }

  void _loadFabricanteById(String value, String title) {
    final items = _repository.getFabricanteById(value);
    _updateDefensivosList(items, false, title);
  }

  void _loadClasseAgronomica(bool count, String title) {
    if (!count) {
      try {
        final items = _repository.getClasseAgronomica();
        _updateDefensivosList(items, false, title);
      } catch (e) {
        _updateState(state.copyWith(isLoading: false));
      }
    }
  }

  void _loadClasseAgronomicaById(String value, String title) {
    final items = _repository.getClasseAgronomicaById(value);
    _updateDefensivosList(items, false, title);
  }

  void _loadIngredienteAtivo(bool count, String title) {
    if (!count) {
      final items = _repository.getIngredienteAtivo();
      _updateDefensivosList(items, false, title);
    }
  }

  void _loadIngredienteAtivoById(String value, String title) {
    final items = _repository.getIngredienteAtivoById(value);
    _updateDefensivosList(items, false, title);
  }

  void _loadModoDeAcao(bool count, String title) {
    if (!count) {
      final items = _repository.getModoDeAcao();
      _updateDefensivosList(items, false, title);
    }
  }

  void _loadModoDeAcaoById(String value, String title) {
    final items = _repository.getModoDeAcaoById(value);
    _updateDefensivosList(items, false, title);
  }

  void _updateDefensivosList(List<Map<String, dynamic>> defensivoItems,
      bool isFinalPage, String title) {
    _repository.setFinalPage(isFinalPage);

    final defensivos =
        defensivoItems.map((item) => DefensivoItemModel.fromMap(item)).toList();

    _updateState(state.copyWith(
      title: title,
      finalPage: isFinalPage,
      defensivosList: defensivos,
      defensivosListFiltered: [],
      currentPage: 0,
    ));

    _resetListState();
    _updateState(state.copyWith(isLoading: false));
  }


  void _resetListState() {
    // Carrega o lote inicial de itens para exibir
    _loadInitialBatch();
  }

  void _loadInitialBatch() {
    if (state.defensivosList.isNotEmpty) {
      final initialCount =
          DefensivosPageConstants.itemsPerScroll < state.defensivosList.length
              ? DefensivosPageConstants.itemsPerScroll
              : state.defensivosList.length;

      final initialItems = state.defensivosList.take(initialCount).toList();
      
      
      _updateState(state.copyWith(
        defensivosListFiltered: initialItems,
        currentPage: 1,
        isLoading: false
      ));
    } else {
      _updateState(state.copyWith(isLoading: false));
    }
  }


  /// Limpa todos os recursos e listeners de forma segura
  void _cleanupResources() {
    // Cancelar Worker do tema
    if (_themeWorker != null) {
      _themeWorker?.dispose();
      _themeWorker = null;
      _monitoringService.unregisterWorker('theme');
    }
    
    // Limpar controllers
    try {
      textController.removeListener(filterItems);
      textController.dispose();
    } catch (e) {
      // Silently handle cleanup errors
    }
    
    try {
      scrollController.removeListener(scrollListener);
      scrollController.dispose();
    } catch (e) {
      // Silently handle cleanup errors
    }
    
    // Limpar contexto
    context = null;
    
    // Cleanup completo através do service
    _monitoringService.cleanupAllResources();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    _cleanupResources();
    super.onClose();
  }
}
