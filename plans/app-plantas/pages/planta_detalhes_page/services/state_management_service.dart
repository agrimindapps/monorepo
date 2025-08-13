// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/comentario_model.dart';
import '../../../database/espaco_model.dart';
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_repository.dart';

/// Service para gerenciar estado reativo de forma consistente
/// Implementa single source of truth e sincronização automática
class StateManagementService {
  static const StateManagementService _instance =
      StateManagementService._internal();
  factory StateManagementService() => _instance;
  const StateManagementService._internal();

  // Estado centralizado da planta
  static final Map<String, PlantaState> _plantaStates = {};

  /// Obtém ou cria o estado para uma planta específica
  static PlantaState getPlantaState(
      String plantaId, PlantaModel initialPlanta) {
    if (!_plantaStates.containsKey(plantaId)) {
      _plantaStates[plantaId] = PlantaState(initialPlanta);
    } else {
      // Atualizar dados base se necessário (versioning)
      final currentState = _plantaStates[plantaId]!;
      if (initialPlanta.updatedAt > currentState._baseData.updatedAt) {
        currentState._updateBaseData(initialPlanta);
      }
    }
    return _plantaStates[plantaId]!;
  }

  /// Remove estado da planta (cleanup)
  static void removePlantaState(String plantaId) {
    final state = _plantaStates[plantaId];
    if (state != null) {
      state.dispose();
      _plantaStates.remove(plantaId);
    }
  }

  /// Limpa todos os estados (cleanup global)
  static void disposeAll() {
    for (final state in _plantaStates.values) {
      state.dispose();
    }
    _plantaStates.clear();
  }
}

/// Estado interno de uma planta específica
class PlantaState {
  late PlantaModel _baseData;
  final Rx<PlantaModel> _currentData;
  final Rx<PlantaConfigModel?> _configuracoes = Rx<PlantaConfigModel?>(null);
  final Rx<EspacoModel?> _espaco = Rx<EspacoModel?>(null);
  final RxList<TarefaModel> _tarefasRecentes = <TarefaModel>[].obs;
  final RxList<TarefaModel> _proximasTarefas = <TarefaModel>[].obs;

  // Estado de loading e erro
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingTarefas = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Timestamp da última sincronização
  DateTime _lastSyncTime = DateTime.now();

  // Timer para sincronização automática
  Timer? _syncTimer;

  PlantaState(PlantaModel initialData) : _currentData = initialData.obs {
    _baseData = initialData;
    _startAutoSync();
  }

  // Getters para acesso externo
  Rx<PlantaModel> get plantaAtual => _currentData;
  Rx<PlantaConfigModel?> get configuracoes => _configuracoes;
  Rx<EspacoModel?> get espaco => _espaco;
  RxList<TarefaModel> get tarefasRecentes => _tarefasRecentes;
  RxList<TarefaModel> get proximasTarefas => _proximasTarefas;
  RxBool get isLoading => _isLoading;
  RxBool get isLoadingTarefas => _isLoadingTarefas;
  RxBool get hasError => _hasError;
  RxString get errorMessage => _errorMessage;

  /// Atualiza dados base e propaga mudanças
  void _updateBaseData(PlantaModel newData) {
    if (newData.updatedAt > _baseData.updatedAt) {
      _baseData = newData;
      _currentData.value = newData;
      _lastSyncTime = DateTime.now();
      debugPrint('✅ Dados base atualizados para planta ${newData.id}');
    }
  }

  /// Atualiza planta atual e marca como modificada
  Future<void> updatePlanta(PlantaModel updatedPlanta) async {
    try {
      // Validar versionamento para evitar conflitos
      if (updatedPlanta.updatedAt < _baseData.updatedAt) {
        throw const StateConflictException(
            'Dados desatualizados detectados. Recarregue os dados da planta.');
      }

      // Atualizar timestamp
      final now = DateTime.now().millisecondsSinceEpoch;
      final plantaComTimestamp = updatedPlanta.copyWith(updatedAt: now);

      // Atualizar estado local
      _currentData.value = plantaComTimestamp;
      _baseData = plantaComTimestamp;
      _lastSyncTime = DateTime.now();

      // Persistir mudanças
      await _persistirMudancas(plantaComTimestamp);

      debugPrint('✅ Planta atualizada com sucesso: ${updatedPlanta.id}');
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erro ao atualizar planta: $e';
      debugPrint('❌ Erro ao atualizar planta: $e');
      rethrow;
    }
  }

  /// Adiciona comentário de forma segura
  Future<void> adicionarComentario(ComentarioModel comentario) async {
    try {
      final comentariosAtuais =
          List<ComentarioModel>.from(_currentData.value.comentarios ?? []);
      comentariosAtuais.insert(0, comentario);

      final plantaAtualizada = _currentData.value.copyWith(
        comentarios: comentariosAtuais,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await updatePlanta(plantaAtualizada);
    } catch (e) {
      debugPrint('❌ Erro ao adicionar comentário: $e');
      rethrow;
    }
  }

  /// Remove comentário de forma segura
  Future<void> removerComentario(ComentarioModel comentario) async {
    try {
      final comentariosAtuais =
          List<ComentarioModel>.from(_currentData.value.comentarios ?? []);
      comentariosAtuais.removeWhere((c) => c.id == comentario.id);

      final plantaAtualizada = _currentData.value.copyWith(
        comentarios: comentariosAtuais,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await updatePlanta(plantaAtualizada);
    } catch (e) {
      debugPrint('❌ Erro ao remover comentário: $e');
      rethrow;
    }
  }

  /// Atualiza configurações
  void updateConfiguracoes(PlantaConfigModel? config) {
    _configuracoes.value = config;
  }

  /// Atualiza espaço
  void updateEspaco(EspacoModel? espacoData) {
    _espaco.value = espacoData;
  }

  /// Atualiza tarefas
  void updateTarefas(List<TarefaModel> recentes, List<TarefaModel> proximas) {
    _tarefasRecentes.assignAll(recentes);
    _proximasTarefas.assignAll(proximas);
  }

  /// Atualiza estado de loading
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Atualiza estado de loading de tarefas
  void setLoadingTarefas(bool loading) {
    _isLoadingTarefas.value = loading;
  }

  /// Atualiza estado de erro
  void setError(bool hasError, [String message = '']) {
    _hasError.value = hasError;
    _errorMessage.value = message;
  }

  /// Verifica se dados estão desatualizados
  bool isDataStale() {
    final now = DateTime.now();
    final diffMinutes = now.difference(_lastSyncTime).inMinutes;
    return diffMinutes > 5; // Considera stale após 5 minutos
  }

  /// Força sincronização com servidor
  Future<void> forceSync() async {
    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();

      final latestData = await plantaRepo.findById(_baseData.id);
      if (latestData != null && latestData.updatedAt > _baseData.updatedAt) {
        _updateBaseData(latestData);
      }
    } catch (e) {
      debugPrint('❌ Erro na sincronização forçada: $e');
      setError(true, 'Erro ao sincronizar dados');
    }
  }

  /// Inicia sincronização automática periódica
  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (isDataStale()) {
        forceSync();
      }
    });
  }

  /// Persiste mudanças no repositório
  Future<void> _persistirMudancas(PlantaModel planta) async {
    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();
      await plantaRepo.update(planta.id, planta);
    } catch (e) {
      debugPrint('❌ Erro ao persistir mudanças: $e');
      rethrow;
    }
  }

  /// Limpa recursos
  void dispose() {
    _syncTimer?.cancel();
    debugPrint('🧹 Estado da planta ${_baseData.id} descartado');
  }

  /// Rollback para dados base em caso de erro
  void rollbackToBase() {
    _currentData.value = _baseData;
    setError(false);
    debugPrint('↩️  Rollback realizado para planta ${_baseData.id}');
  }

  /// Obtém snapshot do estado atual
  Map<String, dynamic> getStateSnapshot() {
    return {
      'plantaId': _baseData.id,
      'lastSync': _lastSyncTime.toIso8601String(),
      'isLoading': _isLoading.value,
      'hasError': _hasError.value,
      'isStale': isDataStale(),
      'comentariosCount': _currentData.value.comentarios?.length ?? 0,
      'tarefasRecentesCount': _tarefasRecentes.length,
      'proximasTarefasCount': _proximasTarefas.length,
    };
  }
}

/// Exceção para conflitos de estado
class StateConflictException implements Exception {
  final String message;
  const StateConflictException(this.message);

  @override
  String toString() => 'StateConflictException: $message';
}

/// Exceção para dados stale
class StaleDataException implements Exception {
  final String message;
  const StaleDataException(this.message);

  @override
  String toString() => 'StaleDataException: $message';
}
