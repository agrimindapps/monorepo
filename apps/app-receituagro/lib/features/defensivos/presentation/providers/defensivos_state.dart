import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/defensivo_entity.dart';

part 'defensivos_state.freezed.dart';

/// Estados da view de defensivos
enum DefensivosViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State imutável para gerenciamento de defensivos
///
/// Migrado para @freezed para type-safety, imutabilidade e código gerado
@freezed
sealed class DefensivosState with _$DefensivosState {
  const DefensivosState._();

  const factory DefensivosState({
    /// Lista completa de defensivos
    @Default([]) List<DefensivoEntity> defensivos,

    /// Defensivos filtrados
    @Default([]) List<DefensivoEntity> filteredDefensivos,

    /// Classes agronômicas disponíveis
    @Default([]) List<String> classes,

    /// Fabricantes disponíveis
    @Default([]) List<String> fabricantes,

    /// Query de busca atual
    @Default('') String searchQuery,

    /// Classe selecionada para filtro
    @Default('') String selectedClasse,

    /// Fabricante selecionado para filtro
    @Default('') String selectedFabricante,

    /// Loading state
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,
  }) = _DefensivosState;

  /// Factory para estado inicial
  factory DefensivosState.initial() => const DefensivosState();

  // ========== Computed Properties ==========

  /// Verifica se há dados
  bool get hasData => defensivos.isNotEmpty;

  /// Verifica se há dados filtrados
  bool get hasFilteredData => filteredDefensivos.isNotEmpty;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se algum filtro está ativo
  bool get isFiltered =>
      searchQuery.isNotEmpty ||
      selectedClasse.isNotEmpty ||
      selectedFabricante.isNotEmpty;

  /// Estado da view baseado nos dados
  DefensivosViewState get viewState {
    if (isLoading) return DefensivosViewState.loading;
    if (hasError) return DefensivosViewState.error;
    if (filteredDefensivos.isEmpty) return DefensivosViewState.empty;
    return DefensivosViewState.loaded;
  }
}

/// Extension para métodos de transformação do state
extension DefensivosStateX on DefensivosState {
  /// Limpa mensagem de erro
  DefensivosState clearError() => copyWith(error: null);
}
