// Project imports:
import 'praga_cultura_item_model.dart';
import 'view_mode.dart';

class ListaPragasCulturaState {
  final String culturaNome;
  final String culturaId;
  final bool isLoading;
  final bool isSearching;
  final bool isDark;
  final ViewMode viewMode;
  final int tabIndex;
  final List<PragaCulturaItemModel> pragasList;
  final List<PragaCulturaItemModel> pragasFiltered;
  final String searchText;
  final List<dynamic> pragasLegacyData;

  const ListaPragasCulturaState({
    this.culturaNome = '',
    this.culturaId = '',
    this.isLoading = false,
    this.isSearching = false,
    this.isDark = false,
    this.viewMode = ViewMode.grid,
    this.tabIndex = 0,
    this.pragasList = const [],
    this.pragasFiltered = const [],
    this.searchText = '',
    this.pragasLegacyData = const [],
  });

  ListaPragasCulturaState copyWith({
    String? culturaNome,
    String? culturaId,
    bool? isLoading,
    bool? isSearching,
    bool? isDark,
    ViewMode? viewMode,
    int? tabIndex,
    List<PragaCulturaItemModel>? pragasList,
    List<PragaCulturaItemModel>? pragasFiltered,
    String? searchText,
    List<dynamic>? pragasLegacyData,
  }) {
    return ListaPragasCulturaState(
      culturaNome: culturaNome ?? this.culturaNome,
      culturaId: culturaId ?? this.culturaId,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isDark: isDark ?? this.isDark,
      viewMode: viewMode ?? this.viewMode,
      tabIndex: tabIndex ?? this.tabIndex,
      pragasList: pragasList ?? this.pragasList,
      pragasFiltered: pragasFiltered ?? this.pragasFiltered,
      searchText: searchText ?? this.searchText,
      pragasLegacyData: pragasLegacyData ?? this.pragasLegacyData,
    );
  }

  // Computed properties
  int get totalRegistros => pragasList.length;
  int get filteredCount => pragasFiltered.length;
  bool get hasData => pragasList.isNotEmpty;
  bool get hasFilteredData => pragasFiltered.isNotEmpty;
  bool get isEmpty => pragasFiltered.isEmpty && !isLoading && !isSearching;

  // Tab titles and types
  static const List<String> tabTitles = ['Plantas', 'Doenças', 'Insetos'];
  static const List<String> tipoPragaValues = ['3', '2', '1'];

  String get currentTipoPraga => tipoPragaValues[tabIndex];
  String get currentTabTitle => tabTitles[tabIndex];

  // Get pragas by current tab type
  List<PragaCulturaItemModel> getPragasPorTipoAtual() {
    return getPragasPorTipo(currentTipoPraga);
  }

  List<PragaCulturaItemModel> getPragasPorTipo(String tipo) {
    return pragasFiltered.where((praga) => praga.tipoPraga == tipo).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListaPragasCulturaState &&
        other.culturaNome == culturaNome &&
        other.culturaId == culturaId &&
        other.isLoading == isLoading &&
        other.isSearching == isSearching &&
        other.isDark == isDark &&
        other.viewMode == viewMode &&
        other.tabIndex == tabIndex &&
        other.searchText == searchText;
  }

  @override
  int get hashCode {
    return culturaNome.hashCode ^
        culturaId.hashCode ^
        isLoading.hashCode ^
        isSearching.hashCode ^
        isDark.hashCode ^
        viewMode.hashCode ^
        tabIndex.hashCode ^
        searchText.hashCode;
  }

  @override
  String toString() {
    return 'ListaPragasCulturaState(cultura: $culturaNome, isLoading: $isLoading, isSearching: $isSearching, pragas: ${pragasList.length}, filtered: ${pragasFiltered.length})';
  }
}
