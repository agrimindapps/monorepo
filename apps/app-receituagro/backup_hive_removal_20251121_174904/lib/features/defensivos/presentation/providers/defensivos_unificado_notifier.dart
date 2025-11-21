import 'package:flutter/foundation.dart';
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
      defensivosSelecionados:
          defensivosSelecionados ?? this.defensivosSelecionados,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      tipoAgrupamento: tipoAgrupamento ?? this.tipoAgrupamento,
      filtroTexto: filtroTexto ?? this.filtroTexto,
      ordenacao: ordenacao ?? this.ordenacao,
      filtroToxicidade: filtroToxicidade ?? this.filtroToxicidade,
      filtroTipo: filtroTipo ?? this.filtroTipo,
      apenasComercializados:
          apenasComercializados ?? this.apenasComercializados,
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
///
/// keepAlive: true - Mantém o estado vivo durante toda a sessão do app
/// para evitar recarregamento desnecessário dos 3148+ defensivos
@Riverpod(keepAlive: true)
class DefensivosUnificadoNotifier extends _$DefensivosUnificadoNotifier {
  late final GetDefensivosAgrupadosUseCase _getDefensivosAgrupadosUseCase;
  late final GetDefensivosCompletosUseCase _getDefensivosCompletosUseCase;
  late final GetDefensivosComFiltrosUseCase _getDefensivosComFiltrosUseCase;

  @override
  Future<DefensivosUnificadoState> build() async {
    debugPrint('🏗️ [NOTIFIER] Inicializando DefensivosUnificadoNotifier');
    _getDefensivosAgrupadosUseCase = di.sl<GetDefensivosAgrupadosUseCase>();
    _getDefensivosCompletosUseCase = di.sl<GetDefensivosCompletosUseCase>();
    _getDefensivosComFiltrosUseCase = di.sl<GetDefensivosComFiltrosUseCase>();
    debugPrint('✅ [NOTIFIER] Use cases inicializados');

    // Carregar defensivos completos automaticamente na inicialização
    debugPrint('🔄 [NOTIFIER BUILD] Carregando defensivos completos...');
    final result = await _getDefensivosCompletosUseCase();

    return result.fold(
      (failure) {
        debugPrint('❌ [NOTIFIER BUILD] Erro ao carregar: ${failure.message}');
        return DefensivosUnificadoState.initial().copyWith(
          errorMessage: 'Erro ao carregar defensivos: ${failure.message}',
        );
      },
      (defensivos) {
        debugPrint(
          '✅ [NOTIFIER BUILD] ${defensivos.length} defensivos carregados',
        );
        return DefensivosUnificadoState.initial().copyWith(
          defensivos: defensivos,
          defensivosFiltrados: defensivos,
        );
      },
    );
  }

  /// Carrega defensivos agrupados por tipo
  Future<void> carregarDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    // Com keepAlive, o estado sempre existe após o build
    // Aguardamos o estado estar disponível se ainda estiver carregando
    final currentState = await future;

    debugPrint(
      '🔄 [NOTIFIER AGRUPADOS] Estado atual tem ${currentState.defensivos.length} defensivos',
    );

    state = AsyncValue.data(
      currentState
          .copyWith(
            isLoading: true,
            tipoAgrupamento: tipoAgrupamento,
            filtroTexto: filtroTexto ?? '',
          )
          .clearError(),
    );

    debugPrint(
      '🔄 [NOTIFIER AGRUPADOS] Iniciando carregamento de defensivos agrupados - tipo: $tipoAgrupamento, filtro: $filtroTexto',
    );
    debugPrint(
      '🔄 [NOTIFIER AGRUPADOS] Use case disponível: $_getDefensivosAgrupadosUseCase',
    );

    try {
      final result = await _getDefensivosAgrupadosUseCase(
        tipoAgrupamento: tipoAgrupamento,
        filtroTexto: filtroTexto,
      );
      debugPrint(
        '🔄 [NOTIFIER AGRUPADOS] Resultado do use case recebido: $result',
      );

      result.fold(
        (failure) {
          debugPrint(
            '❌ [NOTIFIER AGRUPADOS] Erro ao carregar defensivos: ${failure.message}',
          );
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro ao carregar defensivos: ${failure.message}',
            ),
          );
        },
        (defensivos) {
          debugPrint(
            '✅ [NOTIFIER AGRUPADOS] Defensivos retornados do use case: ${defensivos.length} itens',
          );
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  defensivos: defensivos,
                  defensivosFiltrados: defensivos,
                  tipoAgrupamento: tipoAgrupamento,
                  filtroTexto: filtroTexto ?? '',
                )
                .clearError(),
          );
          debugPrint(
            '📊 [NOTIFIER AGRUPADOS] Estado atualizado - defensivos: ${state.value?.defensivos.length}, filtrados: ${state.value?.defensivosFiltrados.length}',
          );
        },
      );
    } catch (e) {
      debugPrint('❌ [NOTIFIER AGRUPADOS] Exceção durante carregamento: $e');
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar defensivos: ${e.toString()}',
        ),
      );
    }
  }

  /// Carrega defensivos completos para comparação
  /// Se os dados já foram carregados no build(), apenas retorna
  Future<void> carregarDefensivosCompletos() async {
    final currentState = await future;

    // Se já tem dados carregados, não recarrega
    if (currentState.defensivos.isNotEmpty) {
      debugPrint(
        '✅ [NOTIFIER] Defensivos já carregados (${currentState.defensivos.length} itens), pulando recarregamento',
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    debugPrint(
      '🔄 [NOTIFIER] Carregando defensivos completos pela primeira vez...',
    );
    final result = await _getDefensivosCompletosUseCase();

    result.fold(
      (failure) {
        debugPrint(
          '❌ [NOTIFIER] Erro ao carregar defensivos: ${failure.message}',
        );
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao carregar defensivos: ${failure.message}',
          ),
        );
      },
      (defensivos) {
        debugPrint(
          '✅ [NOTIFIER] Defensivos carregados com sucesso: ${defensivos.length} itens',
        );
        final filtrados = _aplicarFiltrosLocais(
          defensivos,
          currentState.filtroTexto,
        );
        debugPrint(
          '📊 [NOTIFIER] Após filtros locais: ${filtrados.length} itens',
        );
        state = AsyncValue.data(
          currentState
              .copyWith(
                isLoading: false,
                defensivos: defensivos,
                defensivosFiltrados: filtrados,
              )
              .clearError(),
        );
      },
    );
  }

  /// Aplica filtros avançados aos defensivos
  Future<void> aplicarFiltrosAvancados() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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
          currentState
              .copyWith(isLoading: false, defensivosFiltrados: defensivos)
              .clearError(),
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

    if (filtroToxicidade != null &&
        filtroToxicidade != currentState.filtroToxicidade) {
      newState = newState.copyWith(filtroToxicidade: filtroToxicidade);
      changed = true;
    }

    if (filtroTipo != null && filtroTipo != currentState.filtroTipo) {
      newState = newState.copyWith(filtroTipo: filtroTipo);
      changed = true;
    }

    if (apenasComercializados != null &&
        apenasComercializados != currentState.apenasComercializados) {
      newState = newState.copyWith(
        apenasComercializados: apenasComercializados,
      );
      changed = true;
    }

    if (apenasElegiveis != null &&
        apenasElegiveis != currentState.apenasElegiveis) {
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
    final defensivosSelecionados =
        modoComparacao
            ? currentState.defensivosSelecionados
            : <DefensivoEntity>[];

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

    final selecionados = List<DefensivoEntity>.from(
      currentState.defensivosSelecionados,
    );

    if (selecionados.contains(defensivo)) {
      selecionados.remove(defensivo);
    } else if (selecionados.length < 3) {
      selecionados.add(defensivo);
    }

    state = AsyncValue.data(
      currentState.copyWith(defensivosSelecionados: selecionados),
    );
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
        filtroTexto:
            currentState.filtroTexto.isNotEmpty
                ? currentState.filtroTexto
                : null,
      );
    }
  }

  /// Aplica busca/filtro de texto aos defensivos
  /// Método público para ser chamado quando o usuário digita na busca
  void aplicarFiltroTexto(String filtroTexto) {
    final currentState = state.value;
    if (currentState == null) return;

    debugPrint('🔍 [NOTIFIER] Aplicando filtro de texto: "$filtroTexto"');

    final filtrados = _aplicarFiltrosLocais(
      currentState.defensivos,
      filtroTexto,
    );

    debugPrint(
      '✅ [NOTIFIER] Filtro aplicado - ${filtrados.length} de ${currentState.defensivos.length} defensivos',
    );

    state = AsyncValue.data(
      currentState.copyWith(
        filtroTexto: filtroTexto,
        defensivosFiltrados: filtrados,
      ),
    );
  }

  /// Aplica filtros localmente (mais rápido para mudanças simples)
  List<DefensivoEntity> _aplicarFiltrosLocais(
    List<DefensivoEntity> defensivos,
    String filtroTexto,
  ) {
    var filtrados = List<DefensivoEntity>.from(defensivos);
    filtrados =
        filtrados.where((d) {
          return d.displayName.length >= 3;
        }).toList();
    if (filtroTexto.isNotEmpty) {
      filtrados =
          filtrados.where((d) {
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
