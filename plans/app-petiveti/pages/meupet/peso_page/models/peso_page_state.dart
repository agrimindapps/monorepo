// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';

/// State model for peso page with immutable properties
class PesoPageState {
  final List<PesoAnimal> pesos;
  final List<PesoAnimal> filteredPesos;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final String? selectedAnimalId;
  final Animal? selectedAnimal;
  final int? dataInicial;
  final int? dataFinal;
  final String searchQuery;
  final PesoSortType sortType;
  final bool sortAscending;
  final PesoViewMode viewMode;

  const PesoPageState({
    this.pesos = const [],
    this.filteredPesos = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.selectedAnimalId,
    this.selectedAnimal,
    this.dataInicial,
    this.dataFinal,
    this.searchQuery = '',
    this.sortType = PesoSortType.date,
    this.sortAscending = false,
    this.viewMode = PesoViewMode.list,
  });

  /// Factory constructor for empty state
  factory PesoPageState.empty(String? animalId) {
    return PesoPageState(selectedAnimalId: animalId);
  }

  /// Factory constructor for loading state
  factory PesoPageState.loading(String? animalId) {
    return PesoPageState(
      selectedAnimalId: animalId,
      isLoading: true,
    );
  }

  /// Factory constructor for error state
  factory PesoPageState.error(String? animalId, String error) {
    return PesoPageState(
      selectedAnimalId: animalId,
      errorMessage: error,
      isLoading: false,
    );
  }

  /// Copy with method for immutable updates
  PesoPageState copyWith({
    List<PesoAnimal>? pesos,
    List<PesoAnimal>? filteredPesos,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    String? selectedAnimalId,
    Animal? selectedAnimal,
    int? dataInicial,
    int? dataFinal,
    String? searchQuery,
    PesoSortType? sortType,
    bool? sortAscending,
    PesoViewMode? viewMode,
  }) {
    return PesoPageState(
      pesos: pesos ?? this.pesos,
      filteredPesos: filteredPesos ?? this.filteredPesos,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
      sortAscending: sortAscending ?? this.sortAscending,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  /// Clear error message
  PesoPageState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Set loading state
  PesoPageState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set refreshing state
  PesoPageState setRefreshing(bool refreshing) {
    return copyWith(isRefreshing: refreshing);
  }

  /// Check if there are any pesos
  bool get hasPesos => pesos.isNotEmpty;

  /// Check if there are filtered pesos
  bool get hasFilteredPesos => filteredPesos.isNotEmpty;

  /// Check if filters are active
  bool get hasActiveFilters => 
      searchQuery.isNotEmpty || 
      dataInicial != null || 
      dataFinal != null;

  /// Get the current peso count
  int get pesoCount => pesos.length;

  /// Get the filtered peso count
  int get filteredPesoCount => filteredPesos.length;

  /// Check if animal is selected
  bool get hasSelectedAnimal => selectedAnimalId != null && selectedAnimalId!.isNotEmpty;

  /// Get latest peso record
  PesoAnimal? get latestPeso {
    if (pesos.isEmpty) return null;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    
    return sortedPesos.first;
  }

  /// Get peso trend (gaining, losing, stable)
  PesoTrend get pesoTrend {
    if (pesos.length < 2) return PesoTrend.stable;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final recent = sortedPesos.length >= 2 
        ? sortedPesos.sublist(sortedPesos.length - 2)
        : sortedPesos;
    
    if (recent.length < 2) return PesoTrend.stable;
    
    final difference = recent[1].peso - recent[0].peso;
    
    if (difference > 0.1) return PesoTrend.gaining;
    if (difference < -0.1) return PesoTrend.losing;
    return PesoTrend.stable;
  }

  /// Get weight change from previous record
  double? get weightChange {
    if (pesos.length < 2) return null;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final recent = sortedPesos.length >= 2 
        ? sortedPesos.sublist(sortedPesos.length - 2)
        : sortedPesos;
    
    if (recent.length < 2) return null;
    
    return recent[1].peso - recent[0].peso;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PesoPageState &&
        other.pesos == pesos &&
        other.filteredPesos == filteredPesos &&
        other.isLoading == isLoading &&
        other.isRefreshing == isRefreshing &&
        other.errorMessage == errorMessage &&
        other.selectedAnimalId == selectedAnimalId &&
        other.selectedAnimal == selectedAnimal &&
        other.dataInicial == dataInicial &&
        other.dataFinal == dataFinal &&
        other.searchQuery == searchQuery &&
        other.sortType == sortType &&
        other.sortAscending == sortAscending &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      pesos,
      filteredPesos,
      isLoading,
      isRefreshing,
      errorMessage,
      selectedAnimalId,
      selectedAnimal,
      dataInicial,
      dataFinal,
      searchQuery,
      sortType,
      sortAscending,
      viewMode,
    );
  }

  @override
  String toString() {
    return 'PesoPageState('
        'pesos: ${pesos.length} items, '
        'isLoading: $isLoading, '
        'hasError: ${errorMessage != null}, '
        'selectedAnimal: $selectedAnimalId, '
        'viewMode: $viewMode'
        ')';
  }
}

/// Sort types for peso list
enum PesoSortType {
  date,
  weight,
  animalName,
}

/// View modes for peso display
enum PesoViewMode {
  list,
  chart,
  grid,
}

/// Peso trend indicators
enum PesoTrend {
  gaining,
  losing,
  stable,
}
