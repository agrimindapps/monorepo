import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/praga_entity.dart';
import '../../domain/usecases/get_pragas_usecase.dart';

part 'pragas_state.freezed.dart';

/// Estados específicos para UI
enum PragasViewState { initial, loading, loaded, error, empty }

/// State imutável para gerenciamento de pragas
///
/// Migrado para @freezed para type-safety, imutabilidade e código gerado
@freezed
class PragasState with _$PragasState {
  const PragasState._();

  const factory PragasState({
    /// Lista completa de pragas
    @Default([]) List<PragaEntity> pragas,

    /// Pragas acessadas recentemente
    @Default([]) List<PragaEntity> recentPragas,

    /// Pragas sugeridas para o usuário
    @Default([]) List<PragaEntity> suggestedPragas,

    /// Praga atualmente selecionada
    PragaEntity? selectedPraga,

    /// Loading state
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? errorMessage,
  }) = _PragasState;

  /// Factory para estado inicial
  factory PragasState.initial() => const PragasState();

  // ========== Computed Properties ==========

  /// Filtra apenas insetos
  List<PragaEntity> get insetos => pragas.where((p) => p.isInseto).toList();

  /// Filtra apenas doenças
  List<PragaEntity> get doencas => pragas.where((p) => p.isDoenca).toList();

  /// Filtra apenas plantas invasoras
  List<PragaEntity> get plantas => pragas.where((p) => p.isPlanta).toList();

  /// Verifica se há dados
  bool get hasData => pragas.isNotEmpty;

  /// Verifica se há pragas recentes
  bool get hasRecentPragas => recentPragas.isNotEmpty;

  /// Verifica se há pragas sugeridas
  bool get hasSuggestedPragas => suggestedPragas.isNotEmpty;

  /// Verifica se há praga selecionada
  bool get hasSelectedPraga => selectedPraga != null;

  /// Estado da view baseado nos dados
  PragasViewState get viewState {
    if (isLoading) return PragasViewState.loading;
    if (errorMessage != null) return PragasViewState.error;
    if (pragas.isEmpty) return PragasViewState.empty;
    return PragasViewState.loaded;
  }
}

/// Extension para métodos de transformação do state
extension PragasStateX on PragasState {
  /// Limpa mensagem de erro
  PragasState clearError() => copyWith(errorMessage: null);

  /// Limpa seleção atual
  PragasState clearSelection() => copyWith(selectedPraga: null);
}
