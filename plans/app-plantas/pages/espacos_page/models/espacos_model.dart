// Project imports:
import '../../../database/espaco_model.dart';

/// Search and filter state for espacos page
class EspacosSearchState {
  final String searchText;
  final List<EspacoModel> filteredEspacos;
  final bool isSearchActive;

  const EspacosSearchState({
    this.searchText = '',
    this.filteredEspacos = const [],
    this.isSearchActive = false,
  });

  EspacosSearchState copyWith({
    String? searchText,
    List<EspacoModel>? filteredEspacos,
    bool? isSearchActive,
  }) {
    return EspacosSearchState(
      searchText: searchText ?? this.searchText,
      filteredEspacos: filteredEspacos ?? this.filteredEspacos,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }

  bool get hasResults => filteredEspacos.isNotEmpty;
  bool get isEmpty => filteredEspacos.isEmpty && isSearchActive;
}

class EspacosPageModel {
  final List<EspacoModel> espacos;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? editingEspacoId;
  final EspacosSearchState searchState;

  const EspacosPageModel({
    this.espacos = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.editingEspacoId,
    this.searchState = const EspacosSearchState(),
  });

  EspacosPageModel copyWith({
    List<EspacoModel>? espacos,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? editingEspacoId,
    EspacosSearchState? searchState,
  }) {
    return EspacosPageModel(
      espacos: espacos ?? this.espacos,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      editingEspacoId: editingEspacoId ?? this.editingEspacoId,
      searchState: searchState ?? this.searchState,
    );
  }

  // Getters de conveniência
  bool get isEmpty => espacos.isEmpty;
  bool get isNotEmpty => espacos.isNotEmpty;
  int get totalEspacos => espacos.length;
  bool get hasOperationInProgress => isCreating || isUpdating || isDeleting;
  bool get isEditing => editingEspacoId != null;

  // Derived getters for search state
  List<EspacoModel> get displayedEspacos =>
      searchState.isSearchActive ? searchState.filteredEspacos : espacos;
  bool get isSearching => searchState.isSearchActive;
  bool get hasSearchResults => searchState.hasResults;
  String get searchText => searchState.searchText;

  // Encontrar espaço por ID
  EspacoModel? findEspacoById(String id) {
    try {
      return espacos.firstWhere((espaco) => espaco.id == id);
    } catch (e) {
      return null;
    }
  }

  // Verificar se nome já existe (para validação de duplicatas)
  bool hasEspacoWithName(String nome, {String? excludeId}) {
    final nomeLower = nome.toLowerCase().trim();
    return espacos.any((espaco) {
      if (excludeId != null && espaco.id == excludeId) {
        return false;
      }
      return espaco.nome.toLowerCase().trim() == nomeLower;
    });
  }

  // Estatísticas (será implementado quando houver relação com plantas)
  int get totalPlantas => 0; // TODO: Implementar contagem de plantas por espaço

  // Espaços ordenados por nome
  List<EspacoModel> get espacosOrdenados {
    final lista = List<EspacoModel>.from(espacos);
    lista.sort((a, b) {
      final nomeA = a.nome.toLowerCase();
      final nomeB = b.nome.toLowerCase();
      return nomeA.compareTo(nomeB);
    });
    return lista;
  }

  // Espaços com plantas (será implementado)
  List<EspacoModel> get espacosComPlantas {
    // TODO: Implementar filtro de espaços com plantas
    return espacos;
  }

  // Espaços sem plantas (será implementado)
  List<EspacoModel> get espacosSemPlantas {
    // TODO: Implementar filtro de espaços sem plantas
    return [];
  }

  @override
  String toString() {
    return 'EspacosPageModel(espacos: ${espacos.length}, isLoading: $isLoading, hasError: $hasError)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EspacosPageModel &&
        other.espacos.length == espacos.length &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.isCreating == isCreating &&
        other.isUpdating == isUpdating &&
        other.isDeleting == isDeleting &&
        other.editingEspacoId == editingEspacoId &&
        other.searchState == searchState;
  }

  @override
  int get hashCode {
    return Object.hash(
      espacos.length,
      isLoading,
      hasError,
      errorMessage,
      isCreating,
      isUpdating,
      isDeleting,
      editingEspacoId,
      searchState,
    );
  }
}

// Modelo para formulário de espaço
class EspacoFormModel {
  final String nome;
  final String? id;
  final bool isValid;
  final Map<String, String> errors;

  const EspacoFormModel({
    this.nome = '',
    this.id,
    this.isValid = false,
    this.errors = const {},
  });

  EspacoFormModel copyWith({
    String? nome,
    String? id,
    bool? isValid,
    Map<String, String>? errors,
  }) {
    return EspacoFormModel(
      nome: nome ?? this.nome,
      id: id ?? this.id,
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
    );
  }

  // Getters
  bool get isNew => id == null;
  bool get isEdit => id != null;
  String get nomeFormatado => nome.trim();

  // Validação
  bool get hasErrors => errors.isNotEmpty;
  String? getError(String field) => errors[field];
  bool hasError(String field) => errors.containsKey(field);

  @override
  String toString() {
    return 'EspacoFormModel(nome: $nome, id: $id, isValid: $isValid)';
  }
}
