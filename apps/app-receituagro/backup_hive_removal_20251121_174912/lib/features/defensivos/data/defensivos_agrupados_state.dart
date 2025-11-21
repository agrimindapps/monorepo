import 'defensivo_agrupado_item_model.dart';
import 'defensivos_agrupados_view_mode.dart';

class DefensivosAgrupadosState {
  final String categoria;
  final String title;
  final List<DefensivoAgrupadoItemModel> defensivosList;
  final List<DefensivoAgrupadoItemModel> defensivosListFiltered;
  final bool isLoading;
  final bool isSearching;
  final bool isDark;
  final bool finalPage;
  final bool isAscending;
  final String sortField;
  final DefensivosAgrupadosViewMode selectedViewMode;
  final String searchText;
  final int currentPage;
  final int navigationLevel;
  final String selectedGroupId;
  final List<DefensivoAgrupadoItemModel> categoriesList;

  const DefensivosAgrupadosState({
    this.categoria = '',
    this.title = '',
    this.defensivosList = const [],
    this.defensivosListFiltered = const [],
    this.isLoading = true,
    this.isSearching = false,
    this.isDark = false,
    this.finalPage = false,
    this.isAscending = true,
    this.sortField = 'line1',
    this.selectedViewMode = DefensivosAgrupadosViewMode.list,
    this.searchText = '',
    this.currentPage = 0,
    this.navigationLevel = 0,
    this.selectedGroupId = '',
    this.categoriesList = const [],
  });
  int get totalItems => defensivosList.length;
  int get filteredItems => defensivosListFiltered.length;
  bool get hasData => defensivosList.isNotEmpty;
  bool get hasFilteredData => defensivosListFiltered.isNotEmpty;
  bool get isEmpty => defensivosListFiltered.isEmpty && !isLoading && !isSearching;
  bool get canNavigateBack => navigationLevel > 0;
  bool get isInGroup => navigationLevel > 0;
  bool get isInCategoryLevel => navigationLevel == 0;

  DefensivosAgrupadosState copyWith({
    String? categoria,
    String? title,
    List<DefensivoAgrupadoItemModel>? defensivosList,
    List<DefensivoAgrupadoItemModel>? defensivosListFiltered,
    bool? isLoading,
    bool? isSearching,
    bool? isDark,
    bool? finalPage,
    bool? isAscending,
    String? sortField,
    DefensivosAgrupadosViewMode? selectedViewMode,
    String? searchText,
    int? currentPage,
    int? navigationLevel,
    String? selectedGroupId,
    List<DefensivoAgrupadoItemModel>? categoriesList,
  }) {
    return DefensivosAgrupadosState(
      categoria: categoria ?? this.categoria,
      title: title ?? this.title,
      defensivosList: defensivosList ?? this.defensivosList,
      defensivosListFiltered: defensivosListFiltered ?? this.defensivosListFiltered,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isDark: isDark ?? this.isDark,
      finalPage: finalPage ?? this.finalPage,
      isAscending: isAscending ?? this.isAscending,
      sortField: sortField ?? this.sortField,
      selectedViewMode: selectedViewMode ?? this.selectedViewMode,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      navigationLevel: navigationLevel ?? this.navigationLevel,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      categoriesList: categoriesList ?? this.categoriesList,
    );
  }

  @override
  String toString() {
    return 'DefensivosAgrupadosState('
        'categoria: $categoria, '
        'title: $title, '
        'isLoading: $isLoading, '
        'defensivosList: ${defensivosList.length}, '
        'filtered: ${defensivosListFiltered.length}, '
        'navigationLevel: $navigationLevel'
        ')';
  }
}
