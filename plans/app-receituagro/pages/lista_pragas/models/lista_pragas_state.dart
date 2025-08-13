// Project imports:
import 'praga_item_model.dart';
import 'view_mode.dart';

class ListaPragasState {
  final String pragaType;
  final bool isLoading;
  final bool isSearching;
  final bool isAscending;
  final bool isDark;
  final ViewMode viewMode;
  final List<PragaItemModel> pragas;
  final List<PragaItemModel> pragasFiltered;
  final String searchText;

  const ListaPragasState({
    this.pragaType = '1',
    this.isLoading = false,
    this.isSearching = false,
    this.isAscending = true,
    this.isDark = false,
    this.viewMode = ViewMode.grid,
    this.pragas = const [],
    this.pragasFiltered = const [],
    this.searchText = '',
  });

  ListaPragasState copyWith({
    String? pragaType,
    bool? isLoading,
    bool? isSearching,
    bool? isAscending,
    bool? isDark,
    ViewMode? viewMode,
    List<PragaItemModel>? pragas,
    List<PragaItemModel>? pragasFiltered,
    String? searchText,
  }) {
    return ListaPragasState(
      pragaType: pragaType ?? this.pragaType,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isAscending: isAscending ?? this.isAscending,
      isDark: isDark ?? this.isDark,
      viewMode: viewMode ?? this.viewMode,
      pragas: pragas ?? this.pragas,
      pragasFiltered: pragasFiltered ?? this.pragasFiltered,
      searchText: searchText ?? this.searchText,
    );
  }

  int get totalRegistros => pragasFiltered.length;
  bool get hasData => pragas.isNotEmpty;
  bool get hasFilteredData => pragasFiltered.isNotEmpty;
  bool get isEmpty => pragasFiltered.isEmpty && !isLoading && !isSearching;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListaPragasState &&
        other.pragaType == pragaType &&
        other.isLoading == isLoading &&
        other.isSearching == isSearching &&
        other.isAscending == isAscending &&
        other.isDark == isDark &&
        other.viewMode == viewMode &&
        other.searchText == searchText;
  }

  @override
  int get hashCode {
    return pragaType.hashCode ^
        isLoading.hashCode ^
        isSearching.hashCode ^
        isAscending.hashCode ^
        isDark.hashCode ^
        viewMode.hashCode ^
        searchText.hashCode;
  }

  @override
  String toString() {
    return 'ListaPragasState(pragaType: $pragaType, isLoading: $isLoading, isSearching: $isSearching, pragas: ${pragas.length}, filtered: ${pragasFiltered.length})';
  }
}
