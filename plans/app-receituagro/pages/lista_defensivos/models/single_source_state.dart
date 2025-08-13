import 'dart:collection';

import 'defensivo_model.dart';
import 'view_mode.dart';

/// Single Source of Truth State usando computed properties
/// para evitar sincronização manual de múltiplas listas
class SingleSourceState {
  final String title;
  
  // SINGLE SOURCE OF TRUTH - Lista original imutável
  final UnmodifiableListView<DefensivoModel> _sourceData;
  
  // Parâmetros que afetam as computed properties
  final String searchText;
  final String sortField;
  final bool isAscending;
  final int itemsPerPage;
  final int currentPageIndex;
  
  // Estados de controle
  final bool isLoading;
  final bool isSearching;
  final bool isDark;
  final ViewMode selectedViewMode;

  SingleSourceState({
    this.title = '',
    List<DefensivoModel> sourceData = const [],
    this.searchText = '',
    this.sortField = 'line1',
    this.isAscending = true,
    this.itemsPerPage = 20,
    this.currentPageIndex = 0,
    this.isLoading = true,
    this.isSearching = false,
    this.isDark = false,
    this.selectedViewMode = ViewMode.list,
  }) : _sourceData = UnmodifiableListView(sourceData);

  // COMPUTED PROPERTIES - calculadas on-demand a partir da source data

  /// Lista completa ordenada (computed property)
  UnmodifiableListView<DefensivoModel> get sortedData {
    if (_sourceData.isEmpty) return UnmodifiableListView([]);
    
    final sorted = List<DefensivoModel>.from(_sourceData);
    
    sorted.sort((a, b) {
      int comparison;
      switch (sortField) {
        case 'line1':
          comparison = a.line1.toLowerCase().compareTo(b.line1.toLowerCase());
          break;
        case 'line2':
          comparison = a.line2.toLowerCase().compareTo(b.line2.toLowerCase());
          break;
        default:
          comparison = a.line1.toLowerCase().compareTo(b.line1.toLowerCase());
      }
      
      return isAscending ? comparison : -comparison;
    });
    
    return UnmodifiableListView(sorted);
  }

  /// Lista filtrada (computed property)
  UnmodifiableListView<DefensivoModel> get filteredData {
    if (searchText.isEmpty) return sortedData;
    
    final filtered = sortedData.where((defensivo) {
      final searchLower = searchText.toLowerCase();
      return defensivo.line1.toLowerCase().contains(searchLower) ||
             defensivo.line2.toLowerCase().contains(searchLower) ||
             defensivo.idReg.toLowerCase().contains(searchLower);
    }).toList();
    
    return UnmodifiableListView(filtered);
  }

  /// Lista paginada para exibição (computed property)
  UnmodifiableListView<DefensivoModel> get paginatedData {
    if (filteredData.isEmpty) return UnmodifiableListView([]);
    
    final totalItems = (currentPageIndex + 1) * itemsPerPage;
    final endIndex = totalItems > filteredData.length 
        ? filteredData.length 
        : totalItems;
    
    return UnmodifiableListView(filteredData.take(endIndex).toList());
  }

  // Propriedades derivadas para controle de paginação

  /// Se chegou na última página
  bool get isLastPage {
    if (filteredData.isEmpty) return true;
    return paginatedData.length >= filteredData.length;
  }

  /// Total de páginas disponíveis
  int get totalPages {
    if (filteredData.isEmpty) return 0;
    return (filteredData.length / itemsPerPage).ceil();
  }

  /// Total de itens filtrados
  int get totalFilteredItems => filteredData.length;

  /// Total de itens na fonte original
  int get totalSourceItems => _sourceData.length;

  /// Se existe próxima página
  bool get hasNextPage => !isLastPage;

  // Métodos para criar novos estados (imutáveis)

  SingleSourceState copyWith({
    String? title,
    List<DefensivoModel>? sourceData,
    String? searchText,
    String? sortField,
    bool? isAscending,
    int? itemsPerPage,
    int? currentPageIndex,
    bool? isLoading,
    bool? isSearching,
    bool? isDark,
    ViewMode? selectedViewMode,
  }) {
    return SingleSourceState(
      title: title ?? this.title,
      sourceData: sourceData ?? _sourceData.toList(),
      searchText: searchText ?? this.searchText,
      sortField: sortField ?? this.sortField,
      isAscending: isAscending ?? this.isAscending,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isDark: isDark ?? this.isDark,
      selectedViewMode: selectedViewMode ?? this.selectedViewMode,
    );
  }

  /// Reset de paginação (volta para página 0)
  SingleSourceState resetPagination() {
    return copyWith(currentPageIndex: 0);
  }

  /// Avança para próxima página
  SingleSourceState nextPage() {
    if (!hasNextPage) return this;
    return copyWith(currentPageIndex: currentPageIndex + 1);
  }

  /// Aplica novo filtro de busca
  SingleSourceState applySearch(String newSearchText) {
    return copyWith(
      searchText: newSearchText,
      currentPageIndex: 0, // Reset pagination when searching
    );
  }

  /// Aplica nova ordenação
  SingleSourceState applySorting({
    String? newSortField,
    bool? newIsAscending,
  }) {
    return copyWith(
      sortField: newSortField ?? sortField,
      isAscending: newIsAscending ?? isAscending,
      currentPageIndex: 0, // Reset pagination when sorting
    );
  }

  /// Invariant checks para validar consistência do estado
  void validateInvariants() {
    assert(currentPageIndex >= 0, 'Page index cannot be negative');
    assert(itemsPerPage > 0, 'Items per page must be positive');
    assert(totalFilteredItems >= 0, 'Filtered items count cannot be negative');
    assert(totalSourceItems >= 0, 'Source items count cannot be negative');
    assert(paginatedData.length <= filteredData.length, 
           'Paginated data cannot exceed filtered data');
    assert(filteredData.length <= _sourceData.length, 
           'Filtered data cannot exceed source data');
    
    // Invariant: se não há busca, dados filtrados devem ser iguais aos ordenados
    if (searchText.isEmpty) {
      assert(filteredData.length == sortedData.length,
             'When no search, filtered data should equal sorted data');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SingleSourceState &&
        other.title == title &&
        other._sourceData == _sourceData &&
        other.searchText == searchText &&
        other.sortField == sortField &&
        other.isAscending == isAscending &&
        other.itemsPerPage == itemsPerPage &&
        other.currentPageIndex == currentPageIndex &&
        other.isLoading == isLoading &&
        other.isSearching == isSearching &&
        other.isDark == isDark &&
        other.selectedViewMode == selectedViewMode;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        _sourceData.hashCode ^
        searchText.hashCode ^
        sortField.hashCode ^
        isAscending.hashCode ^
        itemsPerPage.hashCode ^
        currentPageIndex.hashCode ^
        isLoading.hashCode ^
        isSearching.hashCode ^
        isDark.hashCode ^
        selectedViewMode.hashCode;
  }

  @override
  String toString() {
    return 'SingleSourceState('
        'title: $title, '
        'sourceItems: $totalSourceItems, '
        'filteredItems: $totalFilteredItems, '
        'paginatedItems: ${paginatedData.length}, '
        'currentPage: $currentPageIndex, '
        'searchText: "$searchText", '
        'sortField: $sortField, '
        'isAscending: $isAscending, '
        'isLoading: $isLoading'
        ')';
  }
}