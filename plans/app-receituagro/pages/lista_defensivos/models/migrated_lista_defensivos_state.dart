import 'defensivo_model.dart';
import 'single_source_state.dart';
import 'view_mode.dart';

/// Migração compatível do ListaDefensivosState para SingleSourceState
/// Mantém compatibilidade com UI existente enquanto usa single source of truth internamente
class MigratedListaDefensivosState {
  final SingleSourceState _internalState;

  MigratedListaDefensivosState._(this._internalState);

  /// Constructor que aceita SingleSourceState
  factory MigratedListaDefensivosState.fromSingleSource(SingleSourceState state) {
    return MigratedListaDefensivosState._(state);
  }

  /// Constructor padrão para compatibilidade
  factory MigratedListaDefensivosState({
    String title = '',
    List<DefensivoModel> defensivosCompletos = const [],
    List<DefensivoModel> defensivosList = const [],
    List<DefensivoModel> defensivosListFiltered = const [],
    bool isLoading = true,
    bool isSearching = false,
    bool isDark = false,
    bool isAscending = true,
    String sortField = 'line1',
    ViewMode selectedViewMode = ViewMode.list,
    bool finalPage = false,
    int currentPage = 0,
    String searchText = '',
  }) {
    // Determina qual lista usar como fonte única
    List<DefensivoModel> sourceData = defensivosCompletos.isNotEmpty 
        ? defensivosCompletos 
        : (defensivosList.isNotEmpty ? defensivosList : defensivosListFiltered);

    final internalState = SingleSourceState(
      title: title,
      sourceData: sourceData,
      searchText: searchText,
      sortField: sortField,
      isAscending: isAscending,
      itemsPerPage: 20, // Valor padrão
      currentPageIndex: currentPage,
      isLoading: isLoading,
      isSearching: isSearching,
      isDark: isDark,
      selectedViewMode: selectedViewMode,
    );

    return MigratedListaDefensivosState._(internalState);
  }

  // Getters para compatibilidade com UI existente

  /// Título da tela
  String get title => _internalState.title;

  /// Lista completa original (computed property - sorted data)
  List<DefensivoModel> get defensivosCompletos => _internalState.sortedData.toList();

  /// Lista com ordenação aplicada (computed property - mesma que completos após migração)
  List<DefensivoModel> get defensivosList => _internalState.sortedData.toList();

  /// Lista filtrada e paginada para exibição (computed property)
  List<DefensivoModel> get defensivosListFiltered => _internalState.paginatedData.toList();

  /// Estado de carregamento
  bool get isLoading => _internalState.isLoading;

  /// Estado de busca
  bool get isSearching => _internalState.isSearching;

  /// Tema escuro
  bool get isDark => _internalState.isDark;

  /// Ordenação ascendente
  bool get isAscending => _internalState.isAscending;

  /// Campo de ordenação
  String get sortField => _internalState.sortField;

  /// Modo de visualização
  ViewMode get selectedViewMode => _internalState.selectedViewMode;

  /// Se chegou na última página
  bool get finalPage => _internalState.isLastPage;
  
  /// Alias para compatibilidade com estado anterior
  bool get isLastPage => _internalState.isLastPage;

  /// Página atual
  int get currentPage => _internalState.currentPageIndex;
  
  /// Alias para compatibilidade com estado anterior
  int get currentPageIndex => _internalState.currentPageIndex;
  
  /// Lista paginada para exibição - alias para compatibilidade
  List<DefensivoModel> get paginatedData => _internalState.paginatedData.toList();

  /// Texto de busca
  String get searchText => _internalState.searchText;

  // Métodos para criar novos estados (delegam para SingleSourceState)

  MigratedListaDefensivosState copyWith({
    String? title,
    List<DefensivoModel>? defensivosCompletos,
    List<DefensivoModel>? defensivosList,
    List<DefensivoModel>? defensivosListFiltered,
    bool? isLoading,
    bool? isSearching,
    bool? isDark,
    bool? isAscending,
    String? sortField,
    ViewMode? selectedViewMode,
    bool? finalPage,
    int? currentPage,
    String? searchText,
  }) {
    // Para garantir single source of truth, sempre usa defensivosCompletos como fonte
    final sourceData = defensivosCompletos ?? _internalState.sortedData.toList();

    final newInternalState = _internalState.copyWith(
      title: title,
      sourceData: sourceData,
      searchText: searchText,
      sortField: sortField,
      isAscending: isAscending,
      currentPageIndex: currentPage,
      isLoading: isLoading,
      isSearching: isSearching,
      isDark: isDark,
      selectedViewMode: selectedViewMode,
    );

    return MigratedListaDefensivosState._(newInternalState);
  }

  /// Acesso ao estado interno para operações avançadas
  SingleSourceState get internalState => _internalState;

  /// Aplica novo filtro de busca
  MigratedListaDefensivosState applySearch(String searchText) {
    final newInternalState = _internalState.applySearch(searchText);
    return MigratedListaDefensivosState._(newInternalState);
  }

  /// Aplica nova ordenação
  MigratedListaDefensivosState applySorting({
    String? sortField,
    bool? isAscending,
  }) {
    final newInternalState = _internalState.applySorting(
      newSortField: sortField,
      newIsAscending: isAscending,
    );
    return MigratedListaDefensivosState._(newInternalState);
  }

  /// Avança para próxima página
  MigratedListaDefensivosState nextPage() {
    final newInternalState = _internalState.nextPage();
    return MigratedListaDefensivosState._(newInternalState);
  }

  /// Reset de paginação
  MigratedListaDefensivosState resetPagination() {
    final newInternalState = _internalState.resetPagination();
    return MigratedListaDefensivosState._(newInternalState);
  }

  /// Validação de invariants
  void validateInvariants() {
    _internalState.validateInvariants();
    
    // Validações específicas da migração
    assert(defensivosCompletos.length == defensivosList.length,
           'After migration, defensivosCompletos and defensivosList should have same length');
    assert(defensivosListFiltered.length <= defensivosCompletos.length,
           'Filtered list should not exceed complete list');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MigratedListaDefensivosState &&
        other._internalState == _internalState;
  }

  @override
  int get hashCode => _internalState.hashCode;

  @override
  String toString() {
    return 'MigratedListaDefensivosState('
        'title: $title, '
        'completos: ${defensivosCompletos.length}, '
        'list: ${defensivosList.length}, '
        'filtered: ${defensivosListFiltered.length}, '
        'currentPage: $currentPage, '
        'searchText: "$searchText", '
        'isLoading: $isLoading'
        ')';
  }
}