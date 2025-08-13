// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/services/sync_firebase_service.dart';
import '../constants/care_type_const.dart';
import '../database/planta_model.dart';
import '../repository/planta_repository.dart';
import '../services/domain/tasks/simple_task_service.dart';

/// Controller de plantas usando SyncFirebaseService
///
/// Funcionalidades específicas de plantas com sincronização automática
class RealtimePlantasController extends GetxController {
  // Repository
  PlantaRepository get _repository => PlantaRepository.instance;

  // Stream subscriptions para gerenciamento de lifecycle
  final List<StreamSubscription> _subscriptions = [];

  // Estados observáveis
  final RxList<PlantaModel> items = <PlantaModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxBool isOnline = false.obs;

  // Estado reativo específico para plantas
  final RxString filtroTexto = ''.obs;
  final RxString espacoSelecionado = ''.obs;

  // Throttle e debounce controllers
  Timer? _filterDebounceTimer;
  bool _isFilteringInProgress = false;

  // Cache para otimização de performance
  List<PlantaModel>? _cachedFilteredPlantas;
  String _lastFilterTexto = '';
  String _lastEspacoSelecionado = '';
  int _lastItemsHashCode = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    _setupReactiveFilters();
  }

  /// Invalidar cache de filtros
  void _invalidateFilterCache() {
    _cachedFilteredPlantas = null;
    _lastFilterTexto = '';
    _lastEspacoSelecionado = '';
    _lastItemsHashCode = 0;
  }

  /// Configurar filtros reativos com debounce adequado
  void _setupReactiveFilters() {
    // Debounce para filtro de texto com cancelamento adequado
    ever(filtroTexto, (String texto) {
      _filterDebounceTimer?.cancel();
      _filterDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (!_isFilteringInProgress) {
          _aplicarFiltros();
        }
      });
    });

    // Filtro de espaço com throttle para evitar múltiplas chamadas
    ever(espacoSelecionado, (_) {
      _filterDebounceTimer?.cancel();
      _aplicarFiltros();
    });
  }

  /// Inicializar repositório e configurar streams
  Future<void> _initializeRepository() async {
    try {
      isLoading.value = true;
      await _repository.initialize();
      _setupStreams();
    } catch (e) {
      debugPrint('❌ Erro ao inicializar RealtimePlantasController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Configurar streams com gerenciamento adequado de subscriptions
  void _setupStreams() {
    try {
      // Stream principal de plantas com subscription tracking
      final plantasSubscription = _repository.plantasStream.listen(
        (plantas) {
          // Evitar race conditions usando single source of truth
          if (items.length != plantas.length ||
              !listEquals(items.toList(), plantas)) {
            items.value = plantas;
            onItemsUpdated(plantas);
          }
        },
        onError: (error) {
          debugPrint('❌ Erro no stream de plantas: $error');
          onError('Erro ao carregar plantas', error);
        },
        cancelOnError: false, // Continuar escutando após erros
      );
      _subscriptions.add(plantasSubscription);

      // Stream de status de sincronização
      final syncSubscription = _repository.syncStatusStream.listen(
        (status) {
          if (syncStatus.value != status) {
            syncStatus.value = status;
          }
        },
        onError: (error) {
          debugPrint('❌ Erro no stream de sync status: $error');
        },
        cancelOnError: false,
      );
      _subscriptions.add(syncSubscription);

      // Stream de conectividade
      final connectivitySubscription = _repository.connectivityStream.listen(
        (online) {
          if (isOnline.value != online) {
            isOnline.value = online;
          }
        },
        onError: (error) {
          debugPrint('❌ Erro no stream de conectividade: $error');
        },
        cancelOnError: false,
      );
      _subscriptions.add(connectivitySubscription);

      debugPrint(
          '✅ ${_subscriptions.length} streams configurados com tracking');
    } catch (e) {
      debugPrint('❌ Erro ao configurar streams: $e');
      onError('Erro na configuração de streams', e);
    }
  }

  void onItemsUpdated(List<PlantaModel> newItems) {
    // Aplicar filtros quando items são atualizados
    _aplicarFiltros();
  }

  void onItemsLoaded(List<PlantaModel> loadedItems) {
    // Aplicar filtros quando items são carregados
    _aplicarFiltros();
  }

  void onItemAdded(PlantaModel item, String id) {
    debugPrint('✅ Nova planta adicionada: ${item.nome}');
  }

  void onItemUpdated(String id, PlantaModel item) {
    debugPrint('🔄 Planta atualizada: ${item.nome}');
  }

  void onItemRemoved(String id) {
    debugPrint('🗑️ Planta removida');
  }

  void onError(String message, dynamic error) {
    // Mostrar erro para o usuário
    if (Get.isRegistered<GetInterface>()) {
      Get.snackbar(
        'Erro',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  // Método removido - não utilizado

  /// Aplicar filtros de busca e espaço com controle de concorrência
  void _aplicarFiltros() {
    if (_isFilteringInProgress) return;

    _isFilteringInProgress = true;

    try {
      // Invalidar cache para forçar recalculo nos próximos acessos
      _invalidateFilterCache();

      // Trigger para atualizar UI de forma reativa
      update(['plantas_filtradas']);

      debugPrint(
          '🔍 Filtros aplicados: texto="${filtroTexto.value}", espaço="${espacoSelecionado.value}"');
    } finally {
      _isFilteringInProgress = false;
    }
  }

  /// Métodos específicos para plantas

  /// Adicionar nova planta
  Future<bool> adicionarPlanta(PlantaModel planta) async {
    try {
      final id = await _repository.create(planta);
      onItemAdded(planta, id);
      return true;
    } catch (e) {
      onError('Erro ao adicionar planta', e);
      return false;
    }
  }

  /// Remover planta
  Future<bool> removerPlanta(String plantaId) async {
    try {
      await _repository.delete(plantaId);
      onItemRemoved(plantaId);
      return true;
    } catch (e) {
      onError('Erro ao remover planta', e);
      return false;
    }
  }

  /// Atualizar planta
  Future<bool> atualizarPlanta(String id, PlantaModel planta) async {
    try {
      await _repository.update(id, planta);
      onItemUpdated(id, planta);
      return true;
    } catch (e) {
      onError('Erro ao atualizar planta', e);
      return false;
    }
  }

  /// Marcar rega como concluída
  Future<bool> marcarRegaConcluida(String plantaId) async {
    try {
      // Buscar tarefa de água pendente para hoje para esta planta
      final tarefas = await SimpleTaskService.instance.getTodayTasks();
      final tarefaAgua = tarefas
          .where((tarefa) =>
              tarefa.plantaId == plantaId &&
              tarefa.tipoCuidado == CareType.agua.value &&
              !tarefa.concluida)
          .firstOrNull;

      if (tarefaAgua != null) {
        // Obter intervalo dinâmico da configuração da planta
        final intervalos =
            await SimpleTaskService.instance.getPlantIntervals(plantaId);
        await SimpleTaskService.instance
            .completeTask(tarefaAgua.id, intervalos[CareType.agua.value] ?? 7);
        return true;
      } else {
        onError('Nenhuma tarefa de rega pendente encontrada para hoje', null);
        return false;
      }
    } catch (e) {
      onError('Erro ao marcar rega como concluída', e);
      return false;
    }
  }

  /// Marcar adubação como concluída
  Future<bool> marcarAdubacaoConcluida(String plantaId) async {
    try {
      // Buscar tarefa de adubo pendente para hoje para esta planta
      final tarefas = await SimpleTaskService.instance.getTodayTasks();
      final tarefaAdubo = tarefas
          .where((tarefa) =>
              tarefa.plantaId == plantaId &&
              tarefa.tipoCuidado == CareType.adubo.value &&
              !tarefa.concluida)
          .firstOrNull;

      if (tarefaAdubo != null) {
        // Obter intervalo dinâmico da configuração da planta
        final intervalos =
            await SimpleTaskService.instance.getPlantIntervals(plantaId);
        await SimpleTaskService.instance
            .completeTask(tarefaAdubo.id, intervalos[CareType.adubo.value] ?? 14);
        return true;
      } else {
        onError(
            'Nenhuma tarefa de adubação pendente encontrada para hoje', null);
        return false;
      }
    } catch (e) {
      onError('Erro ao marcar adubação como concluída', e);
      return false;
    }
  }

  /// Marcar banho de sol como concluído
  Future<bool> marcarBanhoSolConcluido(String plantaId) async {
    try {
      // Buscar tarefa de banho de sol pendente para hoje para esta planta
      final tarefas = await SimpleTaskService.instance.getTodayTasks();
      final tarefaBanhoSol = tarefas
          .where((tarefa) =>
              tarefa.plantaId == plantaId &&
              tarefa.tipoCuidado == CareType.banhoSol.value &&
              !tarefa.concluida)
          .firstOrNull;

      if (tarefaBanhoSol != null) {
        // Obter intervalo dinâmico da configuração da planta
        final intervalos =
            await SimpleTaskService.instance.getPlantIntervals(plantaId);
        await SimpleTaskService.instance.completeTask(
            tarefaBanhoSol.id, intervalos[CareType.banhoSol.value] ?? 3);
        return true;
      } else {
        onError('Nenhuma tarefa de banho de sol pendente encontrada para hoje',
            null);
        return false;
      }
    } catch (e) {
      onError('Erro ao marcar banho de sol como concluído', e);
      return false;
    }
  }

  /// Buscar plantas por espaço
  Future<void> filtrarPorEspaco(String espacoId) async {
    espacoSelecionado.value = espacoId;
  }

  /// Buscar plantas por texto
  void filtrarPorTexto(String texto) {
    filtroTexto.value = texto;
  }

  /// Limpar filtros
  void limparFiltros() {
    filtroTexto.value = '';
    espacoSelecionado.value = '';
  }

  /// Forçar recarregamento manual
  Future<void> forcarRecarregamento() async {
    await _repository.forceSync();
  }

  /// Buscar planta por ID
  Future<PlantaModel?> buscarPorId(String id) {
    return _repository.findById(id);
  }

  /// Método de debug para monitorar performance
  Map<String, dynamic> getPerformanceInfo() {
    return {
      'cache_status': _cachedFilteredPlantas != null ? 'active' : 'empty',
      'cache_size': _cachedFilteredPlantas?.length ?? 0,
      'total_items': items.length,
      'filtered_items': plantasFiltradas.length,
      'active_filters': {
        'texto': filtroTexto.value,
        'espaco': espacoSelecionado.value,
      },
      'filter_cache_hit': _cachedFilteredPlantas != null,
      'memory_usage': {
        'subscriptions_count': _subscriptions.length,
        'timer_active': _filterDebounceTimer != null,
      },
    };
  }

  /// Buscar todas as plantas
  Future<List<PlantaModel>> buscarTodas() {
    return _repository.findAll();
  }

  /// Limpar todas as plantas
  Future<void> limparTodas() {
    return _repository.clear();
  }

  /// Stream de plantas que precisam de água (otimizado)
  Stream<List<PlantaModel>> get plantasPrecisandoAgua {
    return SimpleTaskService.instance.todayTasksStream
        .asyncMap((tarefas) async {
      // Filtrar tarefas de água pendentes e extrair IDs únicos
      final plantaIds = tarefas
          .where((tarefa) =>
              tarefa.tipoCuidado == CareType.agua.value && !tarefa.concluida)
          .map((tarefa) => tarefa.plantaId)
          .toSet() // Remove duplicatas
          .toList();

      // Buscar todas as plantas em uma única operação (evita N+1)
      if (plantaIds.isEmpty) return <PlantaModel>[];

      return await _repository.findByIds(plantaIds);
    });
  }

  /// Stream de plantas que precisam de adubo (otimizado)
  Stream<List<PlantaModel>> get plantasPrecisandoAdubo {
    return SimpleTaskService.instance.todayTasksStream
        .asyncMap((tarefas) async {
      // Filtrar tarefas de adubo pendentes e extrair IDs únicos
      final plantaIds = tarefas
          .where((tarefa) =>
              tarefa.tipoCuidado == CareType.adubo.value && !tarefa.concluida)
          .map((tarefa) => tarefa.plantaId)
          .toSet() // Remove duplicatas
          .toList();

      // Buscar todas as plantas em uma única operação (evita N+1)
      if (plantaIds.isEmpty) return <PlantaModel>[];

      return await _repository.findByIds(plantaIds);
    });
  }

  /// Stream de plantas por espaço
  Stream<List<PlantaModel>> plantasPorEspaco(String espacoId) {
    return _repository.watchByEspaco(espacoId);
  }

  /// Obter informações de debug completas
  Map<String, dynamic> getDebugInfo() {
    return {
      'data': {
        'totalPlantas': totalPlantas,
        'plantasFiltradas': totalPlantasFiltradas,
      },
      'filtros': {
        'texto': filtroTexto.value,
        'espaco': espacoSelecionado.value,
        'temFiltrosAtivos': temFiltrosAtivos,
      },
      'status': {
        'isLoading': isLoading.value,
        'isOnline': isOnline.value,
        'syncStatus': syncStatus.value.toString(),
      },
      'lifecycle': lifecycleDebugInfo,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Getters convenientes com cache otimizado
  List<PlantaModel> get plantasFiltradas {
    final currentFilterTexto = filtroTexto.value;
    final currentEspacoSelecionado = espacoSelecionado.value;
    final currentItemsHash = items.hashCode;

    // Verificar se cache é válido
    if (_cachedFilteredPlantas != null &&
        _lastFilterTexto == currentFilterTexto &&
        _lastEspacoSelecionado == currentEspacoSelecionado &&
        _lastItemsHashCode == currentItemsHash) {
      return _cachedFilteredPlantas!;
    }

    // Recalcular e cachear
    List<PlantaModel> result;

    if (currentFilterTexto.isEmpty && currentEspacoSelecionado.isEmpty) {
      result = List.from(items); // Evitar referência direta
    } else {
      // Otimizar string operations - calcular toLowerCase uma vez
      final filterTextoLower = currentFilterTexto.toLowerCase();

      result = items.where((planta) {
        final nomeMatch = currentFilterTexto.isEmpty ||
            (planta.nome?.toLowerCase().contains(filterTextoLower) ?? false);

        final espacoMatch = currentEspacoSelecionado.isEmpty ||
            planta.espacoId == currentEspacoSelecionado;

        return nomeMatch && espacoMatch;
      }).toList();
    }

    // Atualizar cache
    _cachedFilteredPlantas = result;
    _lastFilterTexto = currentFilterTexto;
    _lastEspacoSelecionado = currentEspacoSelecionado;
    _lastItemsHashCode = currentItemsHash;

    return result;
  }

  bool get temFiltrosAtivos =>
      filtroTexto.isNotEmpty || espacoSelecionado.isNotEmpty;
  int get totalPlantas => items.length;
  int get totalPlantasFiltradas => plantasFiltradas.length;

  @override
  void onClose() {
    debugPrint('🧹 Limpando RealtimePlantasController...');

    // Cancelar timer de debounce
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = null;

    // Limpar cache de performance
    _invalidateFilterCache();

    // Cancelar todas as subscriptions de streams
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        debugPrint('⚠️ Erro ao cancelar subscription: $e');
      }
    }
    _subscriptions.clear();

    // Limpar flags de controle
    _isFilteringInProgress = false;

    debugPrint(
        '✅ RealtimePlantasController limpo (${_subscriptions.length} subscriptions ativas)');

    super.onClose();
  }

  /// Método para verificar saúde do controller (debug)
  bool get isHealthy {
    return _subscriptions.isNotEmpty &&
        (_filterDebounceTimer == null || !_filterDebounceTimer!.isActive) &&
        !_isFilteringInProgress;
  }

  /// Obter informações de debug sobre lifecycle
  Map<String, dynamic> get lifecycleDebugInfo {
    return {
      'activeSubscriptions': _subscriptions.length,
      'hasActiveDebounceTimer': _filterDebounceTimer?.isActive ?? false,
      'isFilteringInProgress': _isFilteringInProgress,
      'isHealthy': isHealthy,
    };
  }
}
