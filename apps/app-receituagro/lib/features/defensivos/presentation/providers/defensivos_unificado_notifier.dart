import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../../domain/usecases/get_defensivos_completos_usecase.dart';

part 'defensivos_unificado_notifier.g.dart';

/// Defensivos unificado state
class DefensivosUnificadoState {
  final List<DefensivoEntity> defensivos;
  final List<DefensivoEntity> defensivosFiltrados;
  final List<DefensivoEntity> defensivosSelecionados;
  final bool isLoading;
  final String? errorMessage;
  final String tipoAgrupamento;
  final String filtroTexto;
  final String ordenacao;
  final String filtroToxicidade;
  final String filtroTipo;
  final bool apenasComercializados;
  final bool apenasElegiveis;
  final bool modoComparacao;

  const DefensivosUnificadoState({
    required this.defensivos,
    required this.defensivosFiltrados,
    required this.defensivosSelecionados,
    required this.isLoading,
    this.errorMessage,
    required this.tipoAgrupamento,
    required this.filtroTexto,
    required this.ordenacao,
    required this.filtroToxicidade,
    required this.filtroTipo,
    required this.apenasComercializados,
    required this.apenasElegiveis,
    required this.modoComparacao,
  });

  factory DefensivosUnificadoState.initial() {
    return const DefensivosUnificadoState(
      defensivos: [],
      defensivosFiltrados: [],
      defensivosSelecionados: [],
      isLoading: false,
      errorMessage: null,
      tipoAgrupamento: 'classe',
      filtroTexto: '',
      ordenacao: 'prioridade',
      filtroToxicidade: 'todos',
      filtroTipo: 'todos',
      apenasComercializados: true,
      apenasElegiveis: false,
      modoComparacao: false,
    );
  }

  DefensivosUnificadoState copyWith({
    List<DefensivoEntity>? defensivos,
    List<DefensivoEntity>? defensivosFiltrados,
    List<DefensivoEntity>? defensivosSelecionados,
    bool? isLoading,
    String? errorMessage,
    String? tipoAgrupamento,
    String? filtroTexto,
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool? apenasComercializados,
    bool? apenasElegiveis,
    bool? modoComparacao,
  }) {
    return DefensivosUnificadoState(
      defensivos: defensivos ?? this.defensivos,
      defensivosFiltrados: defensivosFiltrados ?? this.defensivosFiltrados,
      defensivosSelecionados: defensivosSelecionados ?? this.defensivosSelecionados,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      tipoAgrupamento: tipoAgrupamento ?? this.tipoAgrupamento,
      filtroTexto: filtroTexto ?? this.filtroTexto,
      ordenacao: ordenacao ?? this.ordenacao,
      filtroToxicidade: filtroToxicidade ?? this.filtroToxicidade,
      filtroTipo: filtroTipo ?? this.filtroTipo,
      apenasComercializados: apenasComercializados ?? this.apenasComercializados,
      apenasElegiveis: apenasElegiveis ?? this.apenasElegiveis,
      modoComparacao: modoComparacao ?? this.modoComparacao,
    );
  }

  DefensivosUnificadoState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get hasError => errorMessage != null;
}

/// Notifier unificado para gerenciar defensivos
/// Consolida funcionalidades de defensivos individuais e agrupados
/// Segue arquitetura SOLID e Clean Architecture
@riverpod
class DefensivosUnificadoNotifier extends _$DefensivosUnificadoNotifier {
  late final GetDefensivosAgrupadosUseCase _getDefensivosAgrupadosUseCase;
  late final GetDefensivosCompletosUseCase _getDefensivosCompletosUseCase;
  late final GetDefensivosComFiltrosUseCase _getDefensivosComFiltrosUseCase;

  @override
  Future<DefensivosUnificadoState> build() async {
    _getDefensivosAgrupadosUseCase = di.sl<GetDefensivosAgrupadosUseCase>();
    _getDefensivosCompletosUseCase = di.sl<GetDefensivosCompletosUseCase>();
    _getDefensivosComFiltrosUseCase = di.sl<GetDefensivosComFiltrosUseCase>();

    return DefensivosUnificadoState.initial();
  }

  /// Carrega defensivos agrupados por tipo
  Future<void> carregarDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        tipoAgrupamento: tipoAgrupamento,
        filtroTexto: filtroTexto ?? '',
      ).clearError(),
    );

    final result = await _getDefensivosAgrupadosUseCase(
      tipoAgrupamento: tipoAgrupamento,
      filtroTexto: filtroTexto,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao carregar defensivos: ${failure.message}',
          ),
        );
      },
      (defensivos) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            defensivos: defensivos,
            defensivosFiltrados: defensivos,
            tipoAgrupamento: tipoAgrupamento,
            filtroTexto: filtroTexto ?? '',
          ).clearError(),
        );
      },
    );
  }

  /// Carrega defensivos completos para comparação
  Future<void> carregarDefensivosCompletos() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    final result = await _getDefensivosCompletosUseCase();

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao carregar defensivos: ${failure.message}',
          ),
        );
      },
      (defensivos) {
        final filtrados = _aplicarFiltrosLocais(defensivos, currentState.filtroTexto);
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            defensivos: defensivos,
            defensivosFiltrados: filtrados,
          ).clearError(),
        );
      },
    );
  }

  /// Aplica filtros avançados aos defensivos
  Future<void> aplicarFiltrosAvancados() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    final result = await _getDefensivosComFiltrosUseCase(
      ordenacao: currentState.ordenacao,
      filtroToxicidade: currentState.filtroToxicidade,
      filtroTipo: currentState.filtroTipo,
      apenasComercializados: currentState.apenasComercializados,
      apenasElegiveis: currentState.apenasElegiveis,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao filtrar defensivos: ${failure.message}',
          ),
        );
      },
      (defensivos) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            defensivosFiltrados: defensivos,
          ).clearError(),
        );
      },
    );
  }

  /// Atualiza filtros e aplica
  Future<void> atualizarFiltros({
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool? apenasComercializados,
    bool? apenasElegiveis,
    String? filtroTexto,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    bool changed = false;
    var newState = currentState;

    if (ordenacao != null && ordenacao != currentState.ordenacao) {
      newState = newState.copyWith(ordenacao: ordenacao);
      changed = true;
    }

    if (filtroToxicidade != null && filtroToxicidade != currentState.filtroToxicidade) {
      newState = newState.copyWith(filtroToxicidade: filtroToxicidade);
      changed = true;
    }

    if (filtroTipo != null && filtroTipo != currentState.filtroTipo) {
      newState = newState.copyWith(filtroTipo: filtroTipo);
      changed = true;
    }

    if (apenasComercializados != null && apenasComercializados != currentState.apenasComercializados) {
      newState = newState.copyWith(apenasComercializados: apenasComercializados);
      changed = true;
    }

    if (apenasElegiveis != null && apenasElegiveis != currentState.apenasElegiveis) {
      newState = newState.copyWith(apenasElegiveis: apenasElegiveis);
      changed = true;
    }

    if (filtroTexto != null && filtroTexto != currentState.filtroTexto) {
      newState = newState.copyWith(filtroTexto: filtroTexto);
      changed = true;
    }

    if (changed) {
      state = AsyncValue.data(newState);
      await aplicarFiltrosAvancados();
    }
  }

  /// Limpa todos os filtros
  Future<void> limparFiltros() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        ordenacao: 'prioridade',
        filtroToxicidade: 'todos',
        filtroTipo: 'todos',
        apenasComercializados: false,
        apenasElegiveis: false,
        filtroTexto: '',
      ),
    );

    await aplicarFiltrosAvancados();
  }

  /// Toggle modo comparação
  void toggleModoComparacao() {
    final currentState = state.value;
    if (currentState == null) return;

    final modoComparacao = !currentState.modoComparacao;
    final defensivosSelecionados = modoComparacao ? currentState.defensivosSelecionados : <DefensivoEntity>[];

    state = AsyncValue.data(
      currentState.copyWith(
        modoComparacao: modoComparacao,
        defensivosSelecionados: defensivosSelecionados,
      ),
    );
  }

  /// Seleciona/deseleciona defensivo para comparação
  void toggleSelecaoDefensivo(DefensivoEntity defensivo) {
    final currentState = state.value;
    if (currentState == null) return;

    final selecionados = List<DefensivoEntity>.from(currentState.defensivosSelecionados);

    if (selecionados.contains(defensivo)) {
      selecionados.remove(defensivo);
    } else if (selecionados.length < 3) {
      selecionados.add(defensivo);
    }

    state = AsyncValue.data(currentState.copyWith(defensivosSelecionados: selecionados));
  }

  /// Limpa seleção de defensivos
  void limparSelecao() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(defensivosSelecionados: []));
  }

  /// Recarrega dados
  Future<void> reload() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.modoComparacao) {
      return carregarDefensivosCompletos();
    } else {
      return carregarDefensivosAgrupados(
        tipoAgrupamento: currentState.tipoAgrupamento,
        filtroTexto: currentState.filtroTexto.isNotEmpty ? currentState.filtroTexto : null,
      );
    }
  }

  /// Aplica filtros localmente (mais rápido para mudanças simples)
  List<DefensivoEntity> _aplicarFiltrosLocais(List<DefensivoEntity> defensivos, String filtroTexto) {
    var filtrados = List<DefensivoEntity>.from(defensivos);
    filtrados = filtrados.where((d) {
      return d.displayName.length >= 3;
    }).toList();
    if (filtroTexto.isNotEmpty) {
      filtrados = filtrados.where((d) {
        final texto = filtroTexto.toLowerCase();
        return d.displayName.toLowerCase().contains(texto) ||
            d.displayIngredient.toLowerCase().contains(texto) ||
            d.displayFabricante.toLowerCase().contains(texto) ||
            d.displayClass.toLowerCase().contains(texto);
      }).toList();
    }

    return filtrados;
  }
}
