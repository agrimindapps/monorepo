// Project imports:
import 'defensivo_item_model.dart';
import 'view_mode.dart';

class DefensivosState {
  final String categoria;
  final String title;
  final List<DefensivoItemModel> defensivosList;
  final List<DefensivoItemModel> defensivosListFiltered;
  final bool isLoading;
  final bool isSearching;
  final bool isDark;
  final bool finalPage;
  final bool isAscending;
  final String sortField;
  final ViewMode selectedViewMode;
  final String searchText;
  final int currentPage;
  // Navegação hierárquica
  final int navigationLevel; // 0 = categoria, 1 = itens do grupo
  final String selectedGroupId; // ID do grupo selecionado
  final List<DefensivoItemModel>
      categoriesList; // Lista de categorias para voltar

  const DefensivosState({
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
    this.selectedViewMode = ViewMode.list,
    this.searchText = '',
    this.currentPage = 0,
    this.navigationLevel = 0,
    this.selectedGroupId = '',
    this.categoriesList = const [],
  });

  DefensivosState copyWith({
    String? categoria,
    String? title,
    List<DefensivoItemModel>? defensivosList,
    List<DefensivoItemModel>? defensivosListFiltered,
    bool? isLoading,
    bool? isSearching,
    bool? isDark,
    bool? finalPage,
    bool? isAscending,
    String? sortField,
    ViewMode? selectedViewMode,
    String? searchText,
    int? currentPage,
    int? navigationLevel,
    String? selectedGroupId,
    List<DefensivoItemModel>? categoriesList,
  }) {
    return DefensivosState(
      categoria: categoria ?? this.categoria,
      title: title ?? this.title,
      defensivosList: defensivosList ?? this.defensivosList,
      defensivosListFiltered:
          defensivosListFiltered ?? this.defensivosListFiltered,
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivosState &&
        other.categoria == categoria &&
        other.title == title &&
        other.defensivosList == defensivosList &&
        other.defensivosListFiltered == defensivosListFiltered &&
        other.isLoading == isLoading &&
        other.isSearching == isSearching &&
        other.isDark == isDark &&
        other.finalPage == finalPage &&
        other.isAscending == isAscending &&
        other.sortField == sortField &&
        other.selectedViewMode == selectedViewMode &&
        other.searchText == searchText &&
        other.currentPage == currentPage &&
        other.navigationLevel == navigationLevel &&
        other.selectedGroupId == selectedGroupId &&
        other.categoriesList == categoriesList;
  }

  @override
  int get hashCode {
    return categoria.hashCode ^
        title.hashCode ^
        defensivosList.hashCode ^
        defensivosListFiltered.hashCode ^
        isLoading.hashCode ^
        isSearching.hashCode ^
        isDark.hashCode ^
        finalPage.hashCode ^
        isAscending.hashCode ^
        sortField.hashCode ^
        selectedViewMode.hashCode ^
        searchText.hashCode ^
        currentPage.hashCode ^
        navigationLevel.hashCode ^
        selectedGroupId.hashCode ^
        categoriesList.hashCode;
  }
}
