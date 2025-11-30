import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/praga_entity.dart';
import '../../domain/services/i_pragas_type_service.dart';
import 'pragas_notifier.dart';
import 'pragas_providers.dart';

part 'home_pragas_notifier.g.dart';

/// Home pragas state
class HomePragasState {
  final bool isInitializing;
  final bool initializationFailed;
  final String? initializationError;
  final int totalCulturas;
  final int currentCarouselIndex;
  final bool isLoading;
  final String? errorMessage;
  final dynamic stats;
  final List<PragaEntity> suggestedPragas;
  final List<PragaEntity> recentPragas;
  final void Function(PragaEntity)? _onRecordPragaAccess;
  final void Function(int)? _onUpdateCarouselIndex;

  const HomePragasState({
    required this.isInitializing,
    required this.initializationFailed,
    this.initializationError,
    required this.totalCulturas,
    required this.currentCarouselIndex,
    required this.isLoading,
    this.errorMessage,
    this.stats,
    required this.suggestedPragas,
    required this.recentPragas,
    void Function(PragaEntity)? onRecordPragaAccess,
    void Function(int)? onUpdateCarouselIndex,
  })  : _onRecordPragaAccess = onRecordPragaAccess,
        _onUpdateCarouselIndex = onUpdateCarouselIndex;

  factory HomePragasState.initial() {
    return const HomePragasState(
      isInitializing: true,
      initializationFailed: false,
      initializationError: null,
      totalCulturas: 0,
      currentCarouselIndex: 0,
      isLoading: false,
      errorMessage: null,
      stats: null,
      suggestedPragas: [],
      recentPragas: [],
    );
  }

  HomePragasState copyWith({
    bool? isInitializing,
    bool? initializationFailed,
    String? initializationError,
    int? totalCulturas,
    int? currentCarouselIndex,
    bool? isLoading,
    String? errorMessage,
    dynamic stats,
    List<PragaEntity>? suggestedPragas,
    List<PragaEntity>? recentPragas,
    void Function(PragaEntity)? onRecordPragaAccess,
    void Function(int)? onUpdateCarouselIndex,
  }) {
    return HomePragasState(
      isInitializing: isInitializing ?? this.isInitializing,
      initializationFailed: initializationFailed ?? this.initializationFailed,
      initializationError: initializationError ?? this.initializationError,
      totalCulturas: totalCulturas ?? this.totalCulturas,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      stats: stats ?? this.stats,
      suggestedPragas: suggestedPragas ?? this.suggestedPragas,
      recentPragas: recentPragas ?? this.recentPragas,
      onRecordPragaAccess: onRecordPragaAccess ?? _onRecordPragaAccess,
      onUpdateCarouselIndex: onUpdateCarouselIndex ?? _onUpdateCarouselIndex,
    );
  }

  /// Helper method to record praga access (delegates to callback)
  void recordPragaAccess(PragaEntity praga) {
    _onRecordPragaAccess?.call(praga);
  }

  /// Helper method to update carousel index (delegates to callback)
  void updateCarouselIndex(int index) {
    _onUpdateCarouselIndex?.call(index);
  }

  /// Helper method to get suggestions list formatted for carousel
  /// Refactored to use IPragasTypeService (SOLID compliance)
  List<Map<String, dynamic>> getSuggestionsList(
      IPragasTypeService typeService) {
    if (isLoading || suggestedPragas.isEmpty) {
      return [];
    }

    return suggestedPragas.map((praga) {
      final emoji = typeService.getTypeEmoji(praga.tipoPraga);
      final type = typeService.getTypeLabel(praga.tipoPraga);

      return {
        'id': praga.idReg,
        'name': praga.nomeComum,
        'scientific': praga.nomeCientifico,
        'type': type,
        'emoji': emoji,
      };
    }).toList();
  }
}

/// Notifier para gerenciamento de estado da página Home de Pragas
@Riverpod(keepAlive: true)
class HomePragasNotifier extends _$HomePragasNotifier {
  @override
  Future<HomePragasState> build() async {
    debugPrint('🏠 [HOME_PRAGAS] build() iniciado');
    return await _initialize();
  }

  /// Inicializa o notifier e carrega dados necessários
  Future<HomePragasState> _initialize() async {
    debugPrint('🏠 [HOME_PRAGAS] _initialize() iniciado');
    try {
      debugPrint('🏠 [HOME_PRAGAS] Carregando dados de culturas...');
      final totalCulturas = await _loadCulturaData();
      debugPrint('🏠 [HOME_PRAGAS] Culturas carregadas: $totalCulturas');
      
      debugPrint('🏠 [HOME_PRAGAS] Aguardando pragasProvider...');
      final pragasState = await ref.watch(pragasProvider.future);
      debugPrint('🏠 [HOME_PRAGAS] pragasState obtido - pragas: ${pragasState.pragas.length}, error: ${pragasState.errorMessage}');

      // Criar objeto de estatísticas com contagens por tipo
      final stats = {
        'insetos': pragasState.insetos.length,
        'doencas': pragasState.doencas.length,
        'plantas': pragasState.plantas.length,
      };
      debugPrint('🏠 [HOME_PRAGAS] Stats: insetos=${stats['insetos']}, doencas=${stats['doencas']}, plantas=${stats['plantas']}');

      return HomePragasState(
        isInitializing: false,
        initializationFailed: false,
        initializationError: null,
        totalCulturas: totalCulturas,
        currentCarouselIndex: 0,
        isLoading: false,
        stats: stats,
        errorMessage: pragasState.errorMessage,
        suggestedPragas: pragasState.suggestedPragas,
        recentPragas: pragasState.recentPragas,
        onRecordPragaAccess: (praga) => recordPragaAccess(praga),
        onUpdateCarouselIndex: (index) => updateCarouselIndex(index),
      );
    } catch (e, stackTrace) {
      debugPrint('🏠 [HOME_PRAGAS] ❌ ERRO na inicialização: $e');
      debugPrint('🏠 [HOME_PRAGAS] Stack: $stackTrace');
      return HomePragasState.initial().copyWith(
        isInitializing: false,
        initializationFailed: true,
        initializationError: e.toString(),
      );
    }
  }

  /// Carrega dados de culturas do repositório
  Future<int> _loadCulturaData() async {
    try {
      final culturaRepository = ref.read(culturasRepositoryProvider);
      final culturas = await culturaRepository.findAll();
      debugPrint('🏠 [HOME_PRAGAS] _loadCulturaData: ${culturas.length} culturas');
      return culturas.length;
    } catch (e) {
      debugPrint('🏠 [HOME_PRAGAS] ❌ Erro ao carregar culturas: $e');
      return 0;
    }
  }

  /// Atualiza o índice do carrossel
  void updateCarouselIndex(int index) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.currentCarouselIndex != index) {
      state = AsyncValue.data(
        currentState.copyWith(
          currentCarouselIndex: index,
          onRecordPragaAccess: (praga) => recordPragaAccess(praga),
          onUpdateCarouselIndex: (idx) => updateCarouselIndex(idx),
        ),
      );
    }
  }

  /// Força atualização dos dados de pragas
  Future<void> refreshPragasData() async {
    await ref.read(pragasProvider.notifier).initialize();

    final currentState = state.value;
    if (currentState == null) return;
    final pragasState = ref.read(pragasProvider).value;

    // Atualizar estatísticas com contagens por tipo
    final stats = pragasState != null
        ? {
            'insetos': pragasState.insetos.length,
            'doencas': pragasState.doencas.length,
            'plantas': pragasState.plantas.length,
          }
        : currentState.stats;

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: pragasState?.isLoading ?? false,
        stats: stats,
        errorMessage: pragasState?.errorMessage,
        suggestedPragas: pragasState?.suggestedPragas ?? [],
        recentPragas: pragasState?.recentPragas ?? [],
        onRecordPragaAccess: (praga) => recordPragaAccess(praga),
        onUpdateCarouselIndex: (index) => updateCarouselIndex(index),
      ),
    );
  }

  /// Registra acesso a uma praga
  void recordPragaAccess(PragaEntity praga) {
    ref.read(pragasProvider.notifier).recordPragaAccess(praga);
  }

  /// Força recarregamento completo de todos os dados
  Future<void> forceRefresh() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        isInitializing: true,
        initializationFailed: false,
        initializationError: null,
        onRecordPragaAccess: (praga) => recordPragaAccess(praga),
        onUpdateCarouselIndex: (index) => updateCarouselIndex(index),
      ),
    );

    final newState = await _initialize();
    state = AsyncValue.data(newState);
  }
}
