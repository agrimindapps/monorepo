// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_model.dart';
import '../../../services/domain/plants/plant_care_service.dart';
import '../../../services/domain/tasks/simple_task_service.dart';

/// Service para gerenciar estado reativo consistente de plantas
/// Implementa single source of truth e sincronização automática
class PlantasStateService extends GetxService {
  static PlantasStateService get instance => Get.find<PlantasStateService>();

  // Estado centralizado - single source of truth
  final Rx<List<PlantaModel>> _plantas = Rx<List<PlantaModel>>([]);
  final Rx<List<EspacoModel>> _espacos = Rx<List<EspacoModel>>([]);
  final RxString _searchFilter = ''.obs;
  final RxBool _isLoading = false.obs;

  // Estados computados automaticamente sincronizados
  late final Rx<List<PlantaModel>> plantasFiltered;
  late final RxMap<String, EspacoModel> espacosMap;
  late final RxInt totalPlantas;
  late final RxInt totalEspacos;

  // Controle de sincronização
  Timer? _syncTimer;
  final List<StreamSubscription> _subscriptions = [];
  DateTime _lastSync = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    _initializeComputedProperties();
    _startAutoSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  /// Inicializa propriedades computadas reativas
  void _initializeComputedProperties() {
    // Lista filtrada reativa
    plantasFiltered = Rx<List<PlantaModel>>([]);

    // Mapa de espaços para lookup rápido
    espacosMap = RxMap<String, EspacoModel>({});

    // Contadores reativos
    totalPlantas = RxInt(0);
    totalEspacos = RxInt(0);

    // Configurar sincronização automática entre estados
    _subscriptions.addAll([
      // Quando plantas mudam, atualizar estados derivados
      _plantas.listen((plantas) {
        totalPlantas.value = plantas.length;
        _updateFilteredPlantas();
        debugPrint(
            '🔄 PlantasStateService: ${plantas.length} plantas sincronizadas');
      }),

      // Quando espaços mudam, atualizar mapa
      _espacos.listen((espacos) {
        totalEspacos.value = espacos.length;
        espacosMap.value = {for (var espaco in espacos) espaco.id: espaco};
        debugPrint(
            '🔄 PlantasStateService: ${espacos.length} espaços sincronizados');
      }),

      // Quando filtro muda, reprocessar lista filtrada
      _searchFilter.listen((_) => _updateFilteredPlantas()),
    ]);
  }

  /// Atualiza lista filtrada baseada no filtro atual
  void _updateFilteredPlantas() {
    final filter = _searchFilter.value.toLowerCase();

    if (filter.isEmpty) {
      plantasFiltered.value = List.from(_plantas.value);
    } else {
      plantasFiltered.value = _plantas.value.where((planta) {
        final nomeMatch = planta.nome?.toLowerCase().contains(filter) ?? false;
        final especieMatch =
            planta.especie?.toLowerCase().contains(filter) ?? false;
        final espacoMatch =
            _getEspacoNome(planta.espacoId)?.toLowerCase().contains(filter) ??
                false;
        return nomeMatch || especieMatch || espacoMatch;
      }).toList();
    }

    debugPrint(
        '🔍 PlantasStateService: Filtro aplicado - ${plantasFiltered.value.length} plantas exibidas');
  }

  /// Inicia sincronização automática periódica
  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_shouldSync()) {
        _performBackgroundSync();
      }
    });
  }

  /// Verifica se deve fazer sincronização automática
  bool _shouldSync() {
    final now = DateTime.now();
    final diffMinutes = now.difference(_lastSync).inMinutes;
    return diffMinutes > 5; // Sync a cada 5 minutos se necessário
  }

  /// Sincronização em background
  Future<void> _performBackgroundSync() async {
    try {
      await loadData(silent: true);
    } catch (e) {
      debugPrint(
          '⚠️ PlantasStateService: Erro na sincronização automática: $e');
    }
  }

  // ========== GETTERS REATIVOS ==========

  /// Lista de plantas (fonte única de verdade)
  Rx<List<PlantaModel>> get plantas => _plantas;

  /// Lista filtrada de plantas (computada automaticamente)
  Rx<List<PlantaModel>> get plantasWithFilter => plantasFiltered;

  /// Lista de espaços
  Rx<List<EspacoModel>> get espacos => _espacos;

  /// Estado de carregamento
  RxBool get isLoading => _isLoading;

  /// Filtro de busca atual
  RxString get searchFilter => _searchFilter;

  /// Total de plantas (computado)
  RxInt get plantasCount => totalPlantas;

  /// Total de espaços (computado)
  RxInt get espacosCount => totalEspacos;

  // ========== OPERAÇÕES DE DADOS ==========

  /// Carrega todos os dados com sincronização transacional
  Future<void> loadData({bool silent = false}) async {
    if (!silent) _isLoading.value = true;

    try {
      // Transação atômica - ou tudo carrega ou nada muda
      final List<PlantaModel> newPlantas;
      final List<EspacoModel> newEspacos;

      await PlantCareService.instance.initialize();

      // Carregar dados em paralelo
      final results = await Future.wait([
        PlantCareService.instance.getAllPlants(),
        PlantCareService.instance.getAllSpaces(),
      ]);

      newPlantas = results[0] as List<PlantaModel>;
      newEspacos = results[1] as List<EspacoModel>;

      // Atualizar estado atomicamente
      await _updateState(newPlantas, newEspacos);

      _lastSync = DateTime.now();
      debugPrint(
          '✅ PlantasStateService: Dados carregados - ${newPlantas.length} plantas, ${newEspacos.length} espaços');
    } catch (e) {
      debugPrint('❌ PlantasStateService: Erro ao carregar dados: $e');
      rethrow;
    } finally {
      if (!silent) _isLoading.value = false;
    }
  }

  /// Atualiza estado de forma atômica
  Future<void> _updateState(
      List<PlantaModel> newPlantas, List<EspacoModel> newEspacos) async {
    // Atualização atômica para evitar estados inconsistentes
    _plantas.value = newPlantas;
    _espacos.value = newEspacos;

    // Estados derivados são atualizados automaticamente pelos listeners
  }

  /// Adiciona nova planta e sincroniza estado
  Future<void> addPlanta(PlantaModel planta) async {
    try {
      final currentPlantas = List<PlantaModel>.from(_plantas.value);
      currentPlantas.add(planta);

      // Atualizar estado reativo
      _plantas.value = currentPlantas;

      debugPrint('➕ PlantasStateService: Planta adicionada: ${planta.nome}');
    } catch (e) {
      debugPrint('❌ PlantasStateService: Erro ao adicionar planta: $e');
      rethrow;
    }
  }

  /// Remove planta e sincroniza estado
  Future<void> removePlanta(String plantaId) async {
    try {
      final currentPlantas = List<PlantaModel>.from(_plantas.value);
      currentPlantas.removeWhere((p) => p.id == plantaId);

      // Atualizar estado reativo
      _plantas.value = currentPlantas;

      debugPrint('➖ PlantasStateService: Planta removida: $plantaId');
    } catch (e) {
      debugPrint('❌ PlantasStateService: Erro ao remover planta: $e');
      rethrow;
    }
  }

  /// Atualiza planta existente e sincroniza estado
  Future<void> updatePlanta(PlantaModel plantaAtualizada) async {
    try {
      final currentPlantas = List<PlantaModel>.from(_plantas.value);
      final index =
          currentPlantas.indexWhere((p) => p.id == plantaAtualizada.id);

      if (index != -1) {
        currentPlantas[index] = plantaAtualizada;

        // Atualizar estado reativo
        _plantas.value = currentPlantas;

        debugPrint(
            '🔄 PlantasStateService: Planta atualizada: ${plantaAtualizada.nome}');
      } else {
        debugPrint(
            '⚠️ PlantasStateService: Planta não encontrada para atualização: ${plantaAtualizada.id}');
      }
    } catch (e) {
      debugPrint('❌ PlantasStateService: Erro ao atualizar planta: $e');
      rethrow;
    }
  }

  /// Define filtro de busca
  void setSearchFilter(String filter) {
    _searchFilter.value = filter;
  }

  /// Limpa filtro de busca
  void clearSearchFilter() {
    _searchFilter.value = '';
  }

  // ========== MÉTODOS UTILITÁRIOS ==========

  /// Obtém nome do espaço por ID
  String? _getEspacoNome(String? espacoId) {
    if (espacoId == null || espacoId.isEmpty) return null;
    return espacosMap[espacoId]?.nome;
  }

  /// Obtém espaço por ID
  EspacoModel? getEspaco(String espacoId) {
    return espacosMap[espacoId];
  }

  /// Obtém planta por ID
  PlantaModel? getPlanta(String plantaId) {
    return _plantas.value.firstWhereOrNull((p) => p.id == plantaId);
  }

  /// Obtém tarefas pendentes para uma planta específica
  Future<List<Map<String, dynamic>>> getTarefasPendentes(
      String plantaId) async {
    try {
      // Delegamos para o SimpleTaskService que já tem essa lógica
      await SimpleTaskService.instance.initialize();
      final tarefas =
          await SimpleTaskService.instance.getPendingPlantTasks(plantaId);

      // Converter TarefaModel para Map para compatibilidade com widgets existentes
      return tarefas
          .map((tarefa) => {
                'id': tarefa.id,
                'plantaId': tarefa.plantaId,
                'tipo': tarefa
                    .tipoCuidado, // Para compatibilidade com TaskItemWidget
                'tipoCuidado': tarefa.tipoCuidado,
                'dataLimite': tarefa
                    .dataExecucao, // Para compatibilidade com TaskItemWidget
                'dataExecucao': tarefa.dataExecucao,
                'executado': tarefa.concluida,
                'concluida': tarefa.concluida,
                'descricao': tarefa.tipoCuidadoNome,
                'observacoes': tarefa.observacoes,
                'isAtrasada': tarefa.isAtrasada,
                'isPendente': !tarefa.concluida,
                'statusTexto': tarefa.statusTexto,
              })
          .toList();
    } catch (e) {
      debugPrint('❌ PlantasStateService: Erro ao obter tarefas pendentes: $e');
      return [];
    }
  }

  /// Força recarregamento completo
  Future<void> forceReload() async {
    debugPrint('🔄 PlantasStateService: Forçando recarregamento completo');
    await loadData();
  }

  /// Obtém snapshot do estado atual para debug
  Map<String, dynamic> getStateSnapshot() {
    return {
      'totalPlantas': _plantas.value.length,
      'totalEspacos': _espacos.value.length,
      'plantasFiltradas': plantasFiltered.value.length,
      'filtroAtivo': _searchFilter.value,
      'isLoading': _isLoading.value,
      'lastSync': _lastSync.toIso8601String(),
    };
  }

  /// Valida consistência do estado
  bool validateStateConsistency() {
    try {
      // Verificar se estados derivados estão sincronizados
      final plantasCount = _plantas.value.length;
      final computedCount = totalPlantas.value;

      if (plantasCount != computedCount) {
        debugPrint(
            '⚠️ PlantasStateService: Inconsistência detectada - Plantas: $plantasCount vs Computado: $computedCount');
        return false;
      }

      // Verificar se filtro está aplicado corretamente
      final expectedFilteredCount = _searchFilter.value.isEmpty
          ? plantasCount
          : _plantas.value
              .where((p) =>
                  (p.nome
                          ?.toLowerCase()
                          .contains(_searchFilter.value.toLowerCase()) ??
                      false) ||
                  (p.especie
                          ?.toLowerCase()
                          .contains(_searchFilter.value.toLowerCase()) ??
                      false))
              .length;

      if (plantasFiltered.value.length != expectedFilteredCount) {
        debugPrint(
            '⚠️ PlantasStateService: Inconsistência no filtro detectada');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint(
          '❌ PlantasStateService: Erro na validação de consistência: $e');
      return false;
    }
  }
}
