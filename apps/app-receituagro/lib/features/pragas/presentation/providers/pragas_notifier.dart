import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/services/receituagro_random_extensions.dart';
import '../../data/mappers/praga_mapper.dart';
import '../../domain/entities/praga_entity.dart';
import 'pragas_providers.dart';
import 'pragas_state.dart';

part 'pragas_notifier.g.dart';

/// Notifier para gerenciar estado das pragas (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@Riverpod(keepAlive: true)
class PragasNotifier extends _$PragasNotifier {
  @override
  Future<PragasState> build() async {
    debugPrint('🐛 [PRAGAS_NOTIFIER] build() iniciado');
    return await _loadInitialData();
  }

  /// Load initial data
  Future<PragasState> _loadInitialData() async {
    debugPrint('🐛 [PRAGAS_NOTIFIER] _loadInitialData() iniciado');
    try {
      // Carregar todas as pragas
      final pragasRepository = ref.read(pragasRepositoryProvider);
      debugPrint('🐛 [PRAGAS_NOTIFIER] Repository obtido, chamando findAll()...');
      var pragasDrift = await pragasRepository.findAll();
      debugPrint('🐛 [PRAGAS_NOTIFIER] findAll() retornou ${pragasDrift.length} pragas');

      // Se não há dados, aguardar um pouco e tentar novamente
      // (os dados podem estar sendo carregados pelo AppDataManager)
      if (pragasDrift.isEmpty) {
        debugPrint('🐛 [PRAGAS_NOTIFIER] Aguardando dados serem carregados...');
        
        // Tentar até 3 vezes com delay progressivo
        for (var attempt = 1; attempt <= 3 && pragasDrift.isEmpty; attempt++) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
          pragasDrift = await pragasRepository.findAll();
          debugPrint('🐛 [PRAGAS_NOTIFIER] Tentativa $attempt: ${pragasDrift.length} pragas');
        }
      }

      final pragas = PragaMapper.fromDriftToEntityList(pragasDrift);
      debugPrint('🐛 [PRAGAS_NOTIFIER] Mapeadas ${pragas.length} entidades');

      // Carregar histórico e sugestões iniciais
      final historyData = await _loadHistoryData(pragas);
      debugPrint('🐛 [PRAGAS_NOTIFIER] Histórico carregado: ${historyData.recentPragas.length} recentes, ${historyData.suggestedPragas.length} sugestões');

      return PragasState(
        pragas: pragas,
        recentPragas: historyData.recentPragas,
        suggestedPragas: historyData.suggestedPragas,
        isLoading: false,
        // Não definir errorMessage se apenas não há dados ainda
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      debugPrint('🐛 [PRAGAS_NOTIFIER] ❌ ERRO: $e');
      debugPrint('🐛 [PRAGAS_NOTIFIER] Stack: $stackTrace');
      final errorService = ref.read(pragasErrorMessageServiceProvider);
      return PragasState(
        pragas: const [],
        recentPragas: const [],
        suggestedPragas: const [],
        isLoading: false,
        errorMessage: errorService.getLoadInitialError(e.toString()),
      );
    }
  }

  /// Carrega dados de histórico e sugestões
  Future<_HistoryData> _loadHistoryData(List<PragaEntity> allPragas) async {
    if (allPragas.isEmpty) {
      return _HistoryData(recentPragas: [], suggestedPragas: []);
    }

    try {
      final historyService = ref.read(accessHistoryServiceProvider);
      final historyItems = await historyService.getPragasHistory(limit: 7);
      
      final historicPragas = <PragaEntity>[];
      
      // Buscar pragas do histórico
      for (final historyItem in historyItems) {
        final itemMap = historyItem as Map<String, dynamic>;
        final id = itemMap['id'] as String?;
        if (id == null) continue;
        
        final praga = allPragas.where((p) => p.idReg == id).firstOrNull;
        if (praga != null) {
          historicPragas.add(praga);
        }
      }
      
      // SEMPRE retorna exatamente 7 registros
      // Se histórico < 7, completa com aleatórios excluindo os do histórico
      final recentPragas = RandomSelectionService.fillHistoryToCount<PragaEntity>(
        historyItems: historicPragas,
        allItems: allPragas,
        targetCount: 7,
        areEqual: (a, b) => a.idReg == b.idReg,
      );
      
      // Seleciona pragas sugeridas aleatoriamente
      final suggestedPragas = ReceitaAgroRandomExtensions.selectSuggestedPragas<PragaEntity>(
        allPragas,
        count: 7,
      );
      
      return _HistoryData(
        recentPragas: recentPragas,
        suggestedPragas: suggestedPragas,
      );
    } catch (e) {
      debugPrint('🐛 [PRAGAS_NOTIFIER] Erro ao carregar histórico: $e');
      // Em caso de erro, usa fallback aleatório
      final recentPragas = allPragas.isNotEmpty
          ? ReceitaAgroRandomExtensions.selectRandomPragas<PragaEntity>(allPragas, count: 7)
          : <PragaEntity>[];
      final suggestedPragas = allPragas.isNotEmpty
          ? ReceitaAgroRandomExtensions.selectSuggestedPragas<PragaEntity>(allPragas, count: 7)
          : <PragaEntity>[];
      
      return _HistoryData(
        recentPragas: recentPragas,
        suggestedPragas: suggestedPragas,
      );
    }
  }

  /// Inicialização
  Future<void> initialize() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      await Future.wait([
        loadRecentPragas(),
        loadSuggestedPragas(),
        loadStats(),
      ]);
    } catch (e) {
      final errorService = ref.read(pragasErrorMessageServiceProvider);
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: errorService.getInitializeError(e.toString()),
        ),
      );
    }
  }

  /// Carrega todas as pragas
  Future<void> loadAllPragas() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false).clearError(),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Carrega pragas por tipo
  /// tipo: '1' = Insetos, '2' = Doenças, '3' = Plantas Daninhas
  Future<void> loadPragasByTipo(String tipo) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      // Carregar todas as pragas do repositório
      final pragasRepository = ref.read(pragasRepositoryProvider);
      final pragasDrift = await pragasRepository.findAll();
      final allPragas = PragaMapper.fromDriftToEntityList(pragasDrift);
      
      // Filtrar por tipo
      List<PragaEntity> filteredPragas;
      switch (tipo) {
        case '1':
          // Insetos
          filteredPragas = allPragas.where((p) => p.isInseto).toList();
          debugPrint('🐛 [PRAGAS_NOTIFIER] Filtrado insetos: ${filteredPragas.length} de ${allPragas.length}');
          break;
        case '2':
          // Doenças
          filteredPragas = allPragas.where((p) => p.isDoenca).toList();
          debugPrint('🐛 [PRAGAS_NOTIFIER] Filtrado doenças: ${filteredPragas.length} de ${allPragas.length}');
          break;
        case '3':
          // Plantas Daninhas
          filteredPragas = allPragas.where((p) => p.isPlanta).toList();
          debugPrint('🐛 [PRAGAS_NOTIFIER] Filtrado plantas: ${filteredPragas.length} de ${allPragas.length}');
          break;
        default:
          // Todas as pragas
          filteredPragas = allPragas;
          debugPrint('🐛 [PRAGAS_NOTIFIER] Sem filtro: ${filteredPragas.length} pragas');
      }
      
      state = AsyncValue.data(
        currentState.copyWith(
          pragas: filteredPragas,
          isLoading: false,
        ).clearError(),
      );
      
      // Ordenar alfabeticamente por padrão
      sortPragas(true);
    } catch (e) {
      debugPrint('🐛 [PRAGAS_NOTIFIER] ❌ Erro ao filtrar pragas: $e');
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Pesquisa pragas por nome (busca local no array carregado)
  Future<void> searchPragas(String searchTerm) async {
    final currentState = state.value;
    if (currentState == null) return;

    final trimmedTerm = searchTerm.trim().toLowerCase();
    if (trimmedTerm.isEmpty) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      // Buscar no repositório e filtrar localmente
      final pragasRepository = ref.read(pragasRepositoryProvider);
      final pragasDrift = await pragasRepository.findAll();
      final allPragas = PragaMapper.fromDriftToEntityList(pragasDrift);
      
      // Filtrar pragas que contêm o termo de busca no nome comum ou científico
      final filteredPragas = allPragas.where((praga) {
        final nomeComum = praga.nomeComum.toLowerCase();
        final nomeCientifico = praga.nomeCientifico.toLowerCase();
        return nomeComum.contains(trimmedTerm) || 
               nomeCientifico.contains(trimmedTerm);
      }).toList();
      
      // Ordenar alfabeticamente
      filteredPragas.sort((a, b) => 
        a.nomeComum.toLowerCase().compareTo(b.nomeComum.toLowerCase()));
      
      debugPrint('🔍 [PRAGAS_NOTIFIER] Pesquisa "$trimmedTerm": ${filteredPragas.length} resultados');
      
      state = AsyncValue.data(
        currentState.copyWith(
          pragas: filteredPragas,
          isLoading: false,
        ).clearError(),
      );
    } catch (e) {
      debugPrint('🔍 [PRAGAS_NOTIFIER] ❌ Erro na pesquisa: $e');
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Carrega pragas recentes usando o histórico de acesso
  Future<void> loadRecentPragas() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final allPragas = currentState.pragas;
      
      if (allPragas.isEmpty) {
        state = AsyncValue.data(currentState.copyWith(recentPragas: []));
        return;
      }

      final historyService = ref.read(accessHistoryServiceProvider);
      final historyItems = await historyService.getPragasHistory(limit: 7);
      
      final historicPragas = <PragaEntity>[];
      
      // Buscar pragas do histórico
      for (final historyItem in historyItems) {
        final itemMap = historyItem as Map<String, dynamic>;
        final id = itemMap['id'] as String?;
        if (id == null) continue;
        
        final praga = allPragas
            .where((p) => p.idReg == id)
            .firstOrNull;
        
        if (praga != null) {
          historicPragas.add(praga);
        }
      }
      
      // SEMPRE retorna exatamente 7 registros
      // Se histórico < 7, completa com aleatórios excluindo os do histórico
      final recentPragas = RandomSelectionService.fillHistoryToCount<PragaEntity>(
        historyItems: historicPragas,
        allItems: allPragas,
        targetCount: 7,
        areEqual: (a, b) => a.idReg == b.idReg,
      );
      
      state = AsyncValue.data(currentState.copyWith(recentPragas: recentPragas));
    } catch (e) {
      debugPrint('🐛 [PRAGAS_NOTIFIER] Erro ao carregar histórico: $e');
      // Em caso de erro, usa fallback aleatório
      final allPragas = currentState.pragas;
      final recentPragas = allPragas.isNotEmpty
          ? ReceitaAgroRandomExtensions.selectRandomPragas<PragaEntity>(
              allPragas,
              count: 7,
            )
          : <PragaEntity>[];
      
      state = AsyncValue.data(currentState.copyWith(recentPragas: recentPragas));
    }
  }

  /// Carrega pragas sugeridas (seleção aleatória)
  Future<void> loadSuggestedPragas({int limit = 7}) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final allPragas = currentState.pragas;
      
      if (allPragas.isEmpty) {
        state = AsyncValue.data(currentState.copyWith(suggestedPragas: []));
        return;
      }
      
      // Seleciona pragas sugeridas aleatoriamente
      final suggestedPragas = ReceitaAgroRandomExtensions.selectSuggestedPragas<PragaEntity>(
        allPragas,
        count: limit,
      );
      
      state = AsyncValue.data(currentState.copyWith(suggestedPragas: suggestedPragas));
    } catch (e) {
      debugPrint('🐛 [PRAGAS_NOTIFIER] Erro ao carregar sugestões: $e');
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Carrega estatísticas (pragas por tipo)
  Future<void> loadStats() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Se pragas já foram carregadas, apenas atualiza o estado
      // As propriedades computed (insetos, doencas, plantas) são calculadas automaticamente
      if (currentState.pragas.isEmpty) {
        final pragasRepository = ref.read(pragasRepositoryProvider);
        final pragasDrift = await pragasRepository.findAll();
        final pragas = PragaMapper.fromDriftToEntityList(pragasDrift);

        state = AsyncValue.data(currentState.copyWith(pragas: pragas));
      } else {
        state = AsyncValue.data(currentState);
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Limpa seleção atual
  void clearSelection() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearSelection());
  }

  /// Ordena a lista atual de pragas alfabeticamente
  void sortPragas(bool isAscending) {
    final currentState = state.value;
    if (currentState == null || currentState.pragas.isEmpty) return;

    final sortedPragas = List<PragaEntity>.from(currentState.pragas);
    sortedPragas.sort((a, b) {
      final comparison = a.nomeComum.compareTo(b.nomeComum);
      return isAscending ? comparison : -comparison;
    });

    state = AsyncValue.data(currentState.copyWith(pragas: sortedPragas));
  }

  /// Limpa resultados de pesquisa e recarrega dados iniciais
  Future<void> clearSearch() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(pragas: []).clearError());
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Inicia estado de loading (para evitar flash de empty state)
  void startInitialLoading() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));
  }

  /// Registra acesso a uma praga
  Future<void> recordPragaAccess(PragaEntity praga) async {
    final historyService = ref.read(accessHistoryServiceProvider);
    await historyService.recordPragaAccess(
      id: praga.idReg,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      tipoPraga: praga.tipoPraga,
    );
  }
}

/// Helper class para dados de histórico
class _HistoryData {
  final List<PragaEntity> recentPragas;
  final List<PragaEntity> suggestedPragas;

  _HistoryData({
    required this.recentPragas,
    required this.suggestedPragas,
  });
}
