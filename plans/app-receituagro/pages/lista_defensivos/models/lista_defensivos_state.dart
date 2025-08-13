// Project imports:
import 'defensivo_model.dart';
import 'view_mode.dart';

class ListaDefensivosState {
  final String title;
  final List<DefensivoModel> defensivosCompletos;
  final List<DefensivoModel> defensivosList;
  final List<DefensivoModel> defensivosListFiltered;
  final bool isLoading;
  final bool isSearching;
  final bool isDark;
  final bool isAscending;
  final String sortField;
  final ViewMode selectedViewMode;
  final bool finalPage;
  final int currentPage;
  final String searchText;

  const ListaDefensivosState({
    this.title = '',
    this.defensivosCompletos = const [],
    this.defensivosList = const [],
    this.defensivosListFiltered = const [],
    this.isLoading = true,
    this.isSearching = false,
    this.isDark = false,
    this.isAscending = true,
    this.sortField = 'line1',
    this.selectedViewMode = ViewMode.list,
    this.finalPage = false,
    this.currentPage = 0,
    this.searchText = '',
  });

  ListaDefensivosState copyWith({
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
    return ListaDefensivosState(
      title: title ?? this.title,
      defensivosCompletos: defensivosCompletos ?? this.defensivosCompletos,
      defensivosList: defensivosList ?? this.defensivosList,
      defensivosListFiltered:
          defensivosListFiltered ?? this.defensivosListFiltered,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isDark: isDark ?? this.isDark,
      isAscending: isAscending ?? this.isAscending,
      sortField: sortField ?? this.sortField,
      selectedViewMode: selectedViewMode ?? this.selectedViewMode,
      finalPage: finalPage ?? this.finalPage,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListaDefensivosState &&
        other.title == title &&
        other.defensivosCompletos == defensivosCompletos &&
        other.defensivosList == defensivosList &&
        other.defensivosListFiltered == defensivosListFiltered &&
        other.isLoading == isLoading &&
        other.isSearching == isSearching &&
        other.isDark == isDark &&
        other.isAscending == isAscending &&
        other.sortField == sortField &&
        other.selectedViewMode == selectedViewMode &&
        other.finalPage == finalPage &&
        other.currentPage == currentPage &&
        other.searchText == searchText;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        defensivosCompletos.hashCode ^
        defensivosList.hashCode ^
        defensivosListFiltered.hashCode ^
        isLoading.hashCode ^
        isSearching.hashCode ^
        isDark.hashCode ^
        isAscending.hashCode ^
        sortField.hashCode ^
        selectedViewMode.hashCode ^
        finalPage.hashCode ^
        currentPage.hashCode ^
        searchText.hashCode;
  }
}
