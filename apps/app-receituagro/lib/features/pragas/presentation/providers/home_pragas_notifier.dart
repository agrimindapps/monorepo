import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/app_data_manager.dart';
import '../../domain/entities/praga_entity.dart';
import 'pragas_notifier.dart';

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

  // Callback references for widget interactions
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
  }) : _onRecordPragaAccess = onRecordPragaAccess,
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
  List<Map<String, dynamic>> getSuggestionsList() {
    if (isLoading || suggestedPragas.isEmpty) {
      return [];
    }

    return suggestedPragas.map((praga) {
      String emoji = '🐛';
      String type = 'Inseto';

      switch (praga.tipoPraga) {
        case '1':
          emoji = '🐛';
          type = 'Inseto';
          break;
        case '2':
          emoji = '🦠';
          type = 'Doença';
          break;
        case '3':
          emoji = '🌿';
          type = 'Planta';
          break;
      }

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
@riverpod
class HomePragasNotifier extends _$HomePragasNotifier {
  late final CulturaHiveRepository _culturaRepository;
  late final IAppDataManager _appDataManager;

  @override
  Future<HomePragasState> build() async {
    // Get dependencies from DI
    _culturaRepository = di.sl<CulturaHiveRepository>();
    _appDataManager = di.sl<IAppDataManager>();

    // Initialize and return initial state
    return await _initialize();
  }

  /// Inicializa o notifier e carrega dados necessários
  Future<HomePragasState> _initialize() async {
    try {
      // Carrega dados de culturas
      final totalCulturas = await _loadCulturaData();

      // Inicializa pragas com retry logic
      await _initializePragasWithRetry();

      // Get data from pragas notifier
      final pragasState = ref.read(pragasNotifierProvider).value;

      return HomePragasState(
        isInitializing: false,
        initializationFailed: false,
        initializationError: null,
        totalCulturas: totalCulturas,
        currentCarouselIndex: 0,
        isLoading: pragasState?.isLoading ?? false,
        errorMessage: pragasState?.errorMessage,
        stats: pragasState?.stats,
        suggestedPragas: pragasState?.suggestedPragas ?? [],
        recentPragas: pragasState?.recentPragas ?? [],
        onRecordPragaAccess: (praga) => recordPragaAccess(praga),
        onUpdateCarouselIndex: (index) => updateCarouselIndex(index),
      );
    } catch (e) {
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
      final culturasResult = await _culturaRepository.getAll();
      return culturasResult.fold(
        (failure) => 0,
        (culturas) => culturas.length,
      );
    } catch (e) {
      return 0;
    }
  }

  /// Inicializa pragas com retry logic para aguardar dados estarem prontos
  Future<void> _initializePragasWithRetry([int attempts = 0]) async {
    const int maxAttempts = 10;
    const Duration delayBetweenAttempts = Duration(milliseconds: 500);

    try {
      // Aguarda dados estarem prontos
      final isDataReady = await _appDataManager.isDataReady();

      if (isDataReady) {
        await ref.read(pragasNotifierProvider.notifier).initialize();
        return;
      }

      // Verifica se atingiu o limite de tentativas
      if (attempts >= maxAttempts - 1) {
        // Fallback: inicializa mesmo sem dados prontos
        await ref.read(pragasNotifierProvider.notifier).initialize();
        return;
      }

      // Se dados não estão prontos, aguarda e tenta novamente
      await Future<void>.delayed(delayBetweenAttempts);
      await _initializePragasWithRetry(attempts + 1);
    } catch (e) {
      // Se ainda há tentativas, tenta novamente
      if (attempts < maxAttempts - 1) {
        await Future<void>.delayed(delayBetweenAttempts);
        await _initializePragasWithRetry(attempts + 1);
      } else {
        // Último recurso: inicializa diretamente
        try {
          await ref.read(pragasNotifierProvider.notifier).initialize();
        } catch (finalError) {
          rethrow;
        }
      }
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
    await ref.read(pragasNotifierProvider.notifier).initialize();

    final currentState = state.value;
    if (currentState == null) return;

    // Update state with new pragas data
    final pragasState = ref.read(pragasNotifierProvider).value;

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: pragasState?.isLoading ?? false,
        errorMessage: pragasState?.errorMessage,
        stats: pragasState?.stats,
        suggestedPragas: pragasState?.suggestedPragas ?? [],
        recentPragas: pragasState?.recentPragas ?? [],
        onRecordPragaAccess: (praga) => recordPragaAccess(praga),
        onUpdateCarouselIndex: (index) => updateCarouselIndex(index),
      ),
    );
  }

  /// Registra acesso a uma praga
  void recordPragaAccess(PragaEntity praga) {
    ref.read(pragasNotifierProvider.notifier).recordPragaAccess(praga);
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
