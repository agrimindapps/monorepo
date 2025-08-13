// Project imports:
import 'cultura_model.dart';

/// Loading types for different skeleton states
enum LoadingType {
  initial, // First time loading
  search, // Search operation
  refresh, // Pull to refresh
  filter, // Filter operation
}

class ListaCulturasState {
  final List<CulturaModel> culturasList;
  final List<CulturaModel> culturasFiltered;
  final List<Map<String, dynamic>> pragasLista;
  final bool isLoading;
  final bool isSearching; // Novo campo para indicar busca em andamento
  final LoadingType loadingType; // Novo campo para tipo de loading
  final bool isAscending;
  final bool isDark;
  final String sortField;
  final String culturaSelecionada;
  final String culturaSelecionadaId;
  final String searchText;

  const ListaCulturasState({
    this.culturasList = const [],
    this.culturasFiltered = const [],
    this.pragasLista = const [],
    this.isLoading = true,
    this.isSearching = false, // Valor padrão para novo campo
    this.loadingType = LoadingType.initial, // Valor padrão para tipo de loading
    this.isAscending = true,
    this.isDark = false,
    this.sortField = 'cultura',
    this.culturaSelecionada = '',
    this.culturaSelecionadaId = '',
    this.searchText = '',
  });

  ListaCulturasState copyWith({
    List<CulturaModel>? culturasList,
    List<CulturaModel>? culturasFiltered,
    List<Map<String, dynamic>>? pragasLista,
    bool? isLoading,
    bool? isSearching, // Adicionar parâmetro para novo campo
    LoadingType? loadingType, // Adicionar parâmetro para tipo de loading
    bool? isAscending,
    bool? isDark,
    String? sortField,
    String? culturaSelecionada,
    String? culturaSelecionadaId,
    String? searchText,
  }) {
    return ListaCulturasState(
      culturasList: culturasList ?? this.culturasList,
      culturasFiltered: culturasFiltered ?? this.culturasFiltered,
      pragasLista: pragasLista ?? this.pragasLista,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching, // Incluir na cópia
      loadingType: loadingType ?? this.loadingType, // Incluir na cópia
      isAscending: isAscending ?? this.isAscending,
      isDark: isDark ?? this.isDark,
      sortField: sortField ?? this.sortField,
      culturaSelecionada: culturaSelecionada ?? this.culturaSelecionada,
      culturaSelecionadaId: culturaSelecionadaId ?? this.culturaSelecionadaId,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListaCulturasState &&
        other.culturasList == culturasList &&
        other.culturasFiltered == culturasFiltered &&
        other.pragasLista == pragasLista &&
        other.isLoading == isLoading &&
        other.isSearching == isSearching && // Incluir novo campo
        other.loadingType == loadingType && // Incluir tipo de loading
        other.isAscending == isAscending &&
        other.isDark == isDark &&
        other.sortField == sortField &&
        other.culturaSelecionada == culturaSelecionada &&
        other.culturaSelecionadaId == culturaSelecionadaId &&
        other.searchText == searchText;
  }

  @override
  int get hashCode {
    return culturasList.hashCode ^
        culturasFiltered.hashCode ^
        pragasLista.hashCode ^
        isLoading.hashCode ^
        isSearching.hashCode ^ // Incluir novo campo
        loadingType.hashCode ^ // Incluir tipo de loading
        isAscending.hashCode ^
        isDark.hashCode ^
        sortField.hashCode ^
        culturaSelecionada.hashCode ^
        culturaSelecionadaId.hashCode ^
        searchText.hashCode;
  }
}
