import 'praga_cultura_item_model.dart';
import 'praga_view_mode.dart';

class ListaPragasCulturaState {
  final String culturaNome;
  final String culturaId;
  final bool isLoading;
  final bool isSearching;
  final bool isDark;
  final bool isAscending;
  final PragaViewMode viewMode;
  final int tabIndex;
  final List<PragaCulturaItemModel> pragasList;
  final List<PragaCulturaItemModel> pragasFiltered;
  final String searchText;

  const ListaPragasCulturaState({
    this.culturaNome = '',
    this.culturaId = '',
    this.isLoading = false,
    this.isSearching = false,
    this.isDark = false,
    this.isAscending = true,
    this.viewMode = PragaViewMode.grid,
    this.tabIndex = 0,
    this.pragasList = const [],
    this.pragasFiltered = const [],
    this.searchText = '',
  });

  int get totalRegistros => pragasList.length;
  int get filteredCount => pragasFiltered.length;
  bool get hasData => pragasList.isNotEmpty;
  bool get hasFilteredData => pragasFiltered.isNotEmpty;
  bool get isEmpty => pragasFiltered.isEmpty && !isLoading && !isSearching;

  static const List<String> tabTitles = ['Plantas', 'Doenças', 'Insetos'];
  static const List<String> tipoPragaValues = ['3', '2', '1'];

  String get currentTipoPraga => tipoPragaValues[tabIndex];
  String get currentTabTitle => tabTitles[tabIndex];

  List<PragaCulturaItemModel> getPragasPorTipoAtual() {
    return getPragasPorTipo(currentTipoPraga);
  }

  List<PragaCulturaItemModel> getPragasPorTipo(String tipo) {
    return pragasFiltered.where((praga) => praga.tipoPraga == tipo).toList();
  }

  ListaPragasCulturaState copyWith({
    String? culturaNome,
    String? culturaId,
    bool? isLoading,
    bool? isSearching,
    bool? isDark,
    bool? isAscending,
    PragaViewMode? viewMode,
    int? tabIndex,
    List<PragaCulturaItemModel>? pragasList,
    List<PragaCulturaItemModel>? pragasFiltered,
    String? searchText,
  }) {
    return ListaPragasCulturaState(
      culturaNome: culturaNome ?? this.culturaNome,
      culturaId: culturaId ?? this.culturaId,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isDark: isDark ?? this.isDark,
      isAscending: isAscending ?? this.isAscending,
      viewMode: viewMode ?? this.viewMode,
      tabIndex: tabIndex ?? this.tabIndex,
      pragasList: pragasList ?? this.pragasList,
      pragasFiltered: pragasFiltered ?? this.pragasFiltered,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  String toString() {
    return 'ListaPragasCulturaState('
        'culturaNome: $culturaNome, '
        'culturaId: $culturaId, '
        'isLoading: $isLoading, '
        'isSearching: $isSearching, '
        'pragasList: ${pragasList.length}, '
        'filtered: ${pragasFiltered.length}'
        ')';
  }
}
