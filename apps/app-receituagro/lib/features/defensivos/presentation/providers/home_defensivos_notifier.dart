import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/fitossanitarios_data_loader.dart';
import '../../../../core/services/random_selection_service.dart';

part 'home_defensivos_notifier.g.dart';

/// Home Defensivos state
class HomeDefensivosState {
  final List<FitossanitarioHive> recentDefensivos;
  final List<FitossanitarioHive> newDefensivos;
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModoAcao;
  final int totalIngredienteAtivo;
  final int totalClasseAgronomica;
  final bool isLoading;
  final String? errorMessage;

  const HomeDefensivosState({
    required this.recentDefensivos,
    required this.newDefensivos,
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModoAcao,
    required this.totalIngredienteAtivo,
    required this.totalClasseAgronomica,
    required this.isLoading,
    this.errorMessage,
  });

  factory HomeDefensivosState.initial() {
    return const HomeDefensivosState(
      recentDefensivos: [],
      newDefensivos: [],
      totalDefensivos: 0,
      totalFabricantes: 0,
      totalModoAcao: 0,
      totalIngredienteAtivo: 0,
      totalClasseAgronomica: 0,
      isLoading: false,
      errorMessage: null,
    );
  }

  HomeDefensivosState copyWith({
    List<FitossanitarioHive>? recentDefensivos,
    List<FitossanitarioHive>? newDefensivos,
    int? totalDefensivos,
    int? totalFabricantes,
    int? totalModoAcao,
    int? totalIngredienteAtivo,
    int? totalClasseAgronomica,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeDefensivosState(
      recentDefensivos: recentDefensivos ?? this.recentDefensivos,
      newDefensivos: newDefensivos ?? this.newDefensivos,
      totalDefensivos: totalDefensivos ?? this.totalDefensivos,
      totalFabricantes: totalFabricantes ?? this.totalFabricantes,
      totalModoAcao: totalModoAcao ?? this.totalModoAcao,
      totalIngredienteAtivo: totalIngredienteAtivo ?? this.totalIngredienteAtivo,
      totalClasseAgronomica: totalClasseAgronomica ?? this.totalClasseAgronomica,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  HomeDefensivosState clearError() {
    return copyWith(errorMessage: null);
  }
  bool get hasData => totalDefensivos > 0;
  bool get hasRecentDefensivos => recentDefensivos.isNotEmpty;
  bool get hasNewDefensivos => newDefensivos.isNotEmpty;
  String get subtitleText => isLoading ? 'Carregando...' : '$totalDefensivos Registros Disponíveis';
  String get headerSubtitle => subtitleText;
  bool get shouldShowContent => !isLoading || hasData;

  /// Get formatted count for UI display
  String getFormattedCount(int count) {
    return isLoading ? '...' : '$count';
  }
}

/// Statistics data
class DefensivosStatistics {
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModoAcao;
  final int totalIngredienteAtivo;
  final int totalClasseAgronomica;

  const DefensivosStatistics({
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModoAcao,
    required this.totalIngredienteAtivo,
    required this.totalClasseAgronomica,
  });

  DefensivosStatistics.empty()
      : totalDefensivos = 0,
        totalFabricantes = 0,
        totalModoAcao = 0,
        totalIngredienteAtivo = 0,
        totalClasseAgronomica = 0;
}

/// View states for UI
enum HomeDefensivosViewState {
  initial,
  loading,
  loaded,
  error,
}

/// History data container
class _HistoryData {
  final List<FitossanitarioHive> recentDefensivos;
  final List<FitossanitarioHive> newDefensivos;

  _HistoryData({
    required this.recentDefensivos,
    required this.newDefensivos,
  });
}

/// Notifier para gerenciar estado da Home Defensivos (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class HomeDefensivosNotifier extends _$HomeDefensivosNotifier {
  late final FitossanitarioHiveRepository _repository;
  late final AccessHistoryService _historyService;

  @override
  Future<HomeDefensivosState> build() async {
    _repository = di.sl<FitossanitarioHiveRepository>();
    _historyService = AccessHistoryService();
    return _loadInitialData();
  }

  /// Load initial data
  Future<HomeDefensivosState> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _loadStatisticsData(),
        _loadHistoryData(),
      ]);

      final stats = results[0] as DefensivosStatistics;
      final historyData = results[1] as _HistoryData;

      return HomeDefensivosState(
        totalDefensivos: stats.totalDefensivos,
        totalFabricantes: stats.totalFabricantes,
        totalModoAcao: stats.totalModoAcao,
        totalIngredienteAtivo: stats.totalIngredienteAtivo,
        totalClasseAgronomica: stats.totalClasseAgronomica,
        recentDefensivos: historyData.recentDefensivos,
        newDefensivos: historyData.newDefensivos,
        isLoading: false,
      );
    } catch (e) {
      return HomeDefensivosState(
        recentDefensivos: const [],
        newDefensivos: const [],
        totalDefensivos: 0,
        totalFabricantes: 0,
        totalModoAcao: 0,
        totalIngredienteAtivo: 0,
        totalClasseAgronomica: 0,
        isLoading: false,
        errorMessage: 'Erro ao carregar dados: $e',
      );
    }
  }

  /// Load statistics data
  Future<DefensivosStatistics> _loadStatisticsData() async {
    try {
      var defensivos = await _repository.getActiveDefensivos();

      if (defensivos.isEmpty) {
        final isDataLoaded = await FitossanitariosDataLoader.isDataLoaded();

        if (!isDataLoaded) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          defensivos = await _repository.getActiveDefensivos();

          if (defensivos.isEmpty) {
            return DefensivosStatistics.empty();
          }
        }
      }

      return _calculateStatistics(defensivos);
    } catch (e) {
      return DefensivosStatistics.empty();
    }
  }

  /// Load history data
  Future<_HistoryData> _loadHistoryData() async {
    try {
      final allDefensivos = await _repository.getActiveDefensivos();

      if (allDefensivos.isEmpty) {
        return _HistoryData(
          recentDefensivos: [],
          newDefensivos: [],
        );
      }

      final historyItems = await _historyService.getDefensivosHistory();
      final historicDefensivos = <FitossanitarioHive>[];

      // Buscar até 7 itens do histórico
      for (final historyItem in historyItems.take(7)) {
        final defensivo = allDefensivos.firstWhere(
          (d) => d.idReg == historyItem.id,
          orElse: () => allDefensivos.firstWhere(
            (d) => d.displayName == historyItem.name,
            orElse: () => FitossanitarioHive(
              idReg: '',
              status: false,
              nomeComum: '',
              nomeTecnico: '',
              comercializado: 0,
              elegivel: false,
            ),
          ),
        );

        if (defensivo.idReg.isNotEmpty) {
          historicDefensivos.add(defensivo);
        }
      }

      // SEMPRE retorna exatamente 7 registros
      // Se histórico < 7, completa com aleatórios excluindo os do histórico
      final recentDefensivos = RandomSelectionService.fillHistoryToCount<FitossanitarioHive>(
        historyItems: historicDefensivos,
        allItems: allDefensivos,
        targetCount: 7,
        areEqual: (a, b) => a.idReg == b.idReg,
      );

      final newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 7);

      return _HistoryData(
        recentDefensivos: recentDefensivos,
        newDefensivos: newDefensivos,
      );
    } catch (e) {
      // Em caso de erro, usa fallback aleatório para boa experiência inicial
      final allDefensivos = await _repository.getActiveDefensivos();
      final recentDefensivos = allDefensivos.isNotEmpty
          ? RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 7)
          : <FitossanitarioHive>[];
      final newDefensivos = allDefensivos.isNotEmpty
          ? RandomSelectionService.selectNewDefensivos(allDefensivos, count: 7)
          : <FitossanitarioHive>[];

      return _HistoryData(
        recentDefensivos: recentDefensivos,
        newDefensivos: newDefensivos,
      );
    }
  }

  /// Load all data
  Future<void> loadData() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      await Future.wait([
        _loadStatistics(),
        _loadHistory(),
      ]);
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar dados: $e',
        ),
      );
    }
  }

  /// Load statistics
  Future<void> _loadStatistics() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      var defensivos = await _repository.getActiveDefensivos();
      if (defensivos.isEmpty) {
        final isDataLoaded = await FitossanitariosDataLoader.isDataLoaded();

        if (!isDataLoaded) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          defensivos = await _repository.getActiveDefensivos();

          if (defensivos.isEmpty) {
            state = AsyncValue.data(
              currentState.copyWith(
                isLoading: false,
                errorMessage: 'Dados não disponíveis no momento.\n\nPor favor, reinicie o aplicativo se o problema persistir.',
              ),
            );
            return;
          }
        }
      }
      final stats = _calculateStatistics(defensivos);

      state = AsyncValue.data(
        currentState.copyWith(
          totalDefensivos: stats.totalDefensivos,
          totalFabricantes: stats.totalFabricantes,
          totalModoAcao: stats.totalModoAcao,
          totalIngredienteAtivo: stats.totalIngredienteAtivo,
          totalClasseAgronomica: stats.totalClasseAgronomica,
          isLoading: false,
        ).clearError(),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao calcular estatísticas: $e',
        ),
      );
    }
  }

  /// Load history and recommendations
  Future<void> _loadHistory() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final allDefensivos = await _repository.getActiveDefensivos();

      if (allDefensivos.isEmpty) {
        state = AsyncValue.data(
          currentState.copyWith(
            recentDefensivos: [],
            newDefensivos: [],
          ),
        );
        return;
      }

      await _loadHistoryIntoState(allDefensivos);
    } catch (e) {
      final allDefensivos = await _repository.getActiveDefensivos();
      final recentDefensivos = allDefensivos.isNotEmpty
          ? RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 7)
          : <FitossanitarioHive>[];
      final newDefensivos = allDefensivos.isNotEmpty
          ? RandomSelectionService.selectNewDefensivos(allDefensivos, count: 7)
          : <FitossanitarioHive>[];

      state = AsyncValue.data(
        currentState.copyWith(
          recentDefensivos: recentDefensivos,
          newDefensivos: newDefensivos,
        ),
      );
    }
  }

  /// Load history data and combine with random selection
  Future<void> _loadHistoryIntoState(List<FitossanitarioHive> allDefensivos) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final historyItems = await _historyService.getDefensivosHistory();

      if (allDefensivos.isEmpty) {
        state = AsyncValue.data(
          currentState.copyWith(
            recentDefensivos: [],
            newDefensivos: [],
          ),
        );
        return;
      }

      final historicDefensivos = <FitossanitarioHive>[];

      // Buscar até 7 itens do histórico
      for (final historyItem in historyItems.take(7)) {
        final defensivo = allDefensivos.firstWhere(
          (d) => d.idReg == historyItem.id,
          orElse: () => allDefensivos.firstWhere(
            (d) => d.displayName == historyItem.name,
            orElse: () => FitossanitarioHive(
              idReg: '',
              status: false,
              nomeComum: '',
              nomeTecnico: '',
              comercializado: 0,
              elegivel: false,
            ),
          ),
        );

        if (defensivo.idReg.isNotEmpty) {
          historicDefensivos.add(defensivo);
        }
      }

      // SEMPRE retorna exatamente 7 registros
      // Se histórico < 7, completa com aleatórios excluindo os do histórico
      final recentDefensivos = RandomSelectionService.fillHistoryToCount<FitossanitarioHive>(
        historyItems: historicDefensivos,
        allItems: allDefensivos,
        targetCount: 7,
        areEqual: (a, b) => a.idReg == b.idReg,
      );
      final newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 7);

      state = AsyncValue.data(
        currentState.copyWith(
          recentDefensivos: recentDefensivos,
          newDefensivos: newDefensivos,
        ),
      );
    } catch (e) {
      // Em caso de erro, usa fallback aleatório para boa experiência
      final allDefensivos = await _repository.getActiveDefensivos();
      final recentDefensivos = allDefensivos.isNotEmpty
          ? RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 7)
          : <FitossanitarioHive>[];
      final newDefensivos = allDefensivos.isNotEmpty
          ? RandomSelectionService.selectNewDefensivos(allDefensivos, count: 7)
          : <FitossanitarioHive>[];

      state = AsyncValue.data(
        currentState.copyWith(
          recentDefensivos: recentDefensivos,
          newDefensivos: newDefensivos,
        ),
      );
    }
  }

  /// Calculate statistics from defensivos list
  DefensivosStatistics _calculateStatistics(List<FitossanitarioHive> defensivos) {
    final totalDefensivos = defensivos.length;

    // Fabricantes: valor único (normalizado para lowercase)
    final totalFabricantes = defensivos
        .map((d) => d.displayFabricante.toLowerCase())
        .where((f) => f.isNotEmpty)
        .toSet()
        .length;

    // Modo de Ação: separar por vírgula (normalizado para lowercase)
    // Exclui "não especificado" da contagem
    final modosAcaoSet = <String>{};
    for (final defensivo in defensivos) {
      final modosAcao = _extrairModosAcao(defensivo.displayModoAcao);
      modosAcaoSet.addAll(
        modosAcao
            .where((m) => m.toLowerCase() != 'não especificado')
            .map((m) => m.toLowerCase()),
      );
    }
    final totalModoAcao = modosAcaoSet.length;

    // Ingrediente Ativo: separar por + (normalizado para lowercase)
    // Exclui "não informado" da contagem
    final ingredientesSet = <String>{};
    for (final defensivo in defensivos) {
      final ingredientes = _extrairIngredientesAtivos(defensivo.displayIngredient);
      ingredientesSet.addAll(
        ingredientes
            .where((i) => i.toLowerCase() != 'não informado')
            .map((i) => i.toLowerCase()),
      );
    }
    final totalIngredienteAtivo = ingredientesSet.length;

    // Classe Agronômica: separar por vírgula (normalizado para lowercase)
    // Exclui "não especificado" da contagem
    final classesSet = <String>{};
    for (final defensivo in defensivos) {
      final classes = _extrairClassesAgronomicas(defensivo.displayClass);
      classesSet.addAll(
        classes
            .where((c) => c.toLowerCase() != 'não especificado')
            .map((c) => c.toLowerCase()),
      );
    }
    final totalClasseAgronomica = classesSet.length;

    return DefensivosStatistics(
      totalDefensivos: totalDefensivos,
      totalFabricantes: totalFabricantes,
      totalModoAcao: totalModoAcao,
      totalIngredienteAtivo: totalIngredienteAtivo,
      totalClasseAgronomica: totalClasseAgronomica,
    );
  }

  /// Extrai ingredientes ativos individuais separados por "+"
  List<String> _extrairIngredientesAtivos(String ingredientesText) {
    if (ingredientesText.isEmpty || ingredientesText == 'Sem ingrediente ativo') {
      return ['Não informado'];
    }

    final ingredientes = ingredientesText
        .split('+')
        .map((ingrediente) => ingrediente.trim())
        .where((ingrediente) => ingrediente.isNotEmpty)
        .toList();

    return ingredientes.isEmpty ? ['Não informado'] : ingredientes;
  }

  /// Extrai modos de ação individuais separados por vírgula
  List<String> _extrairModosAcao(String modoAcaoText) {
    if (modoAcaoText.isEmpty || modoAcaoText == 'Não especificado') {
      return ['Não especificado'];
    }

    final modosAcao = modoAcaoText
        .split(',')
        .map((modo) => modo.trim())
        .where((modo) => modo.isNotEmpty)
        .toList();

    return modosAcao.isEmpty ? ['Não especificado'] : modosAcao;
  }

  /// Extrai classes agronômicas individuais separadas por vírgula
  List<String> _extrairClassesAgronomicas(String classeText) {
    if (classeText.isEmpty || classeText == 'Não especificado') {
      return ['Não especificado'];
    }

    final classes = classeText
        .split(',')
        .map((classe) => classe.trim())
        .where((classe) => classe.isNotEmpty)
        .toList();

    return classes.isEmpty ? ['Não especificado'] : classes;
  }

  /// Refresh data without showing loading indicators
  Future<void> refreshData() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      await Future.wait([
        _loadStatistics(),
        _loadHistory(),
      ]);
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao atualizar dados: $e'),
      );
    }
  }

  /// Record access to a defensivo
  Future<void> recordDefensivoAccess(FitossanitarioHive defensivo) async {
    await _historyService.recordDefensivoAccess(
      id: defensivo.idReg,
      name: defensivo.displayName,
      fabricante: defensivo.displayFabricante,
      ingrediente: defensivo.displayIngredient,
      classe: defensivo.displayClass,
    );
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Get view state
  HomeDefensivosViewState get viewState {
    final currentState = state.value;
    if (currentState == null) return HomeDefensivosViewState.initial;

    if (currentState.isLoading) return HomeDefensivosViewState.loading;
    if (currentState.errorMessage != null) return HomeDefensivosViewState.error;
    if (currentState.hasData) return HomeDefensivosViewState.loaded;
    return HomeDefensivosViewState.initial;
  }

  /// Get formatted count
  String getFormattedCount(int count) {
    final currentState = state.value;
    if (currentState == null) return '...';
    return currentState.isLoading ? '...' : '$count';
  }
}
