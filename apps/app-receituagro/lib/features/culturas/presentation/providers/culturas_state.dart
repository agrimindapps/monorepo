import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cultura_entity.dart';

part 'culturas_state.freezed.dart';

/// Estados da view de culturas
enum CulturasViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State imutável para gerenciamento de culturas
///
/// Migrado para @freezed para type-safety, imutabilidade e código gerado
@freezed
class CulturasState with _$CulturasState {
  const CulturasState._();

  const factory CulturasState({
    /// Lista completa de culturas
    @Default([]) List<CulturaEntity> culturas,

    /// Culturas filtradas
    @Default([]) List<CulturaEntity> filteredCulturas,

    /// Grupos disponíveis de culturas
    @Default([]) List<String> grupos,

    /// Query de busca atual
    @Default('') String searchQuery,

    /// Grupo selecionado para filtro
    @Default('') String selectedGrupo,

    /// Loading state
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? errorMessage,
  }) = _CulturasState;

  /// Factory para estado inicial
  factory CulturasState.initial() => const CulturasState();

  // ========== Computed Properties ==========

  /// Verifica se há dados
  bool get hasData => culturas.isNotEmpty;

  /// Verifica se há dados filtrados
  bool get hasFilteredData => filteredCulturas.isNotEmpty;

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se algum filtro está ativo
  bool get isFiltered => searchQuery.isNotEmpty || selectedGrupo.isNotEmpty;

  /// Estado da view baseado nos dados
  CulturasViewState get viewState {
    if (isLoading) return CulturasViewState.loading;
    if (hasError) return CulturasViewState.error;
    if (filteredCulturas.isEmpty) return CulturasViewState.empty;
    return CulturasViewState.loaded;
  }
}

/// Extension para métodos de transformação do state
extension CulturasStateX on CulturasState {
  /// Limpa mensagem de erro
  CulturasState clearError() => copyWith(errorMessage: null);
}
