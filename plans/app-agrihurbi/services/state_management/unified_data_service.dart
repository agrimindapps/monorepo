// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:get/get.dart';

import '../../models/bovino_class.dart';
import '../../models/equino_class.dart';
// Project imports:
import '../../models/medicoes_models.dart';
import '../../models/pluviometros_models.dart';
import '../../repository/bovinos_repository.dart';
import '../../repository/equinos_repository.dart';
import '../../repository/medicoes_repository.dart';
import '../../repository/pluviometros_repository.dart';
import 'agrihurbi_state_manager.dart';

/// Service unificado para acesso consistente a todos os dados do app-agrihurbi
///
/// Centraliza o acesso aos dados eliminando duplicação de estado entre controllers
/// e garantindo que todas as mudanças sejam propagadas de forma consistente.
class UnifiedDataService extends GetxService {
  // ========== SINGLETON PATTERN ==========

  static UnifiedDataService? _instance;
  static UnifiedDataService get instance =>
      _instance ??= UnifiedDataService._();
  UnifiedDataService._();

  // ========== DEPENDENCIES ==========

  late final AgrihurbiStateManager _stateManager;
  late final BovinosRepository _bovinosRepository;
  late final EquinoRepository _equinosRepository;
  late final PluviometrosRepository _pluviometrosRepository;
  late final MedicoesRepository _medicoesRepository;

  // ========== ESTADO CENTRALIZADO ==========

  /// Lista reativa de bovinos
  final RxList<BovinoClass> bovinos = <BovinoClass>[].obs;

  /// Lista reativa de equinos
  final RxList<EquinosClass> equinos = <EquinosClass>[].obs;

  /// Lista reativa de pluviômetros
  final RxList<Pluviometro> pluviometros = <Pluviometro>[].obs;

  /// Lista reativa de medições do pluviômetro atual
  final RxList<Medicoes> currentMeasurements = <Medicoes>[].obs;

  /// Estados de carregamento individuais
  final RxBool isLoadingBovinos = false.obs;
  final RxBool isLoadingEquinos = false.obs;
  final RxBool isLoadingPluviometros = false.obs;
  final RxBool isLoadingMeasurements = false.obs;

  // ========== INICIALIZAÇÃO ==========

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔧 UnifiedDataService: Inicializando service unificado');
    _initializeDependencies();
    _setupStateListeners();
  }

  /// Inicializa dependências dos repositórios
  void _initializeDependencies() {
    _stateManager = AgrihurbiStateManager.instance;
    _bovinosRepository = BovinosRepository();
    _equinosRepository = EquinoRepository();
    _pluviometrosRepository = PluviometrosRepository();
    _medicoesRepository = MedicoesRepository();
  }

  /// Configura listeners para mudanças de estado
  void _setupStateListeners() {
    // Listener para mudanças no pluviômetro selecionado
    ever(_stateManager.selectedPluviometroId, (String pluviometroId) {
      if (pluviometroId.isNotEmpty) {
        refreshCurrentMeasurements();
      }
    });
  }

  // ========== MÉTODOS PÚBLICOS - BOVINOS ==========

  /// Atualiza lista de bovinos
  Future<void> refreshBovinos() async {
    try {
      isLoadingBovinos.value = true;
      debugPrint('🐄 UnifiedDataService: Carregando bovinos...');

      final data = await _bovinosRepository.getAll();
      bovinos.assignAll(data);

      debugPrint('✅ UnifiedDataService: ${data.length} bovinos carregados');
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao carregar bovinos: \$e');
      rethrow;
    } finally {
      isLoadingBovinos.value = false;
    }
  }

  /// Adiciona novo bovino
  Future<void> addBovino(BovinoClass bovino) async {
    try {
      debugPrint(
          '🐄 UnifiedDataService: Adicionando bovino: \${bovino.nomeComum}');

      final success = await _bovinosRepository.saveUpdate(bovino);
      if (success) {
        await refreshBovinos(); // Refresh para garantir consistência
        _notifyDataChanged('bovinos', 'add', bovino);
        debugPrint('✅ UnifiedDataService: Bovino adicionado com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao adicionar bovino: \$e');
      rethrow;
    }
  }

  /// Atualiza bovino existente
  Future<void> updateBovino(BovinoClass bovino) async {
    try {
      debugPrint(
          '🐄 UnifiedDataService: Atualizando bovino: \${bovino.nomeComum}');

      final success = await _bovinosRepository.saveUpdate(bovino);
      if (success) {
        final index = bovinos.indexWhere((b) => b.id == bovino.id);
        if (index != -1) {
          bovinos[index] = bovino;
        }
        _notifyDataChanged('bovinos', 'update', bovino);
        debugPrint('✅ UnifiedDataService: Bovino atualizado com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao atualizar bovino: \$e');
      rethrow;
    }
  }

  /// Remove bovino
  Future<void> deleteBovino(String bovinoId) async {
    try {
      debugPrint('🐄 UnifiedDataService: Removendo bovino: \$bovinoId');

      final success = await _bovinosRepository.remove(bovinoId);
      if (success) {
        bovinos.removeWhere((b) => b.id == bovinoId);
        _notifyDataChanged('bovinos', 'delete', bovinoId);
        debugPrint('✅ UnifiedDataService: Bovino removido com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao remover bovino: \$e');
      rethrow;
    }
  }

  // ========== MÉTODOS PÚBLICOS - EQUINOS ==========

  /// Atualiza lista de equinos
  Future<void> refreshEquinos() async {
    try {
      isLoadingEquinos.value = true;
      debugPrint('🐎 UnifiedDataService: Carregando equinos...');

      // Note: EquinoRepository has different API, using observable pattern
      await _equinosRepository.getAll();
      equinos.assignAll(_equinosRepository.listaEquinos);

      debugPrint('✅ UnifiedDataService: \${equinos.length} equinos carregados');
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao carregar equinos: \$e');
      rethrow;
    } finally {
      isLoadingEquinos.value = false;
    }
  }

  /// Adiciona novo equino
  Future<void> addEquino(EquinosClass equino) async {
    try {
      debugPrint(
          '🐎 UnifiedDataService: Adicionando equino: \${equino.nomeComum}');

      // Set the equino in the repository's observable
      _equinosRepository.mapEquinos.value = equino;
      final success = await _equinosRepository.saveUpdate();

      if (success) {
        await refreshEquinos(); // Refresh para garantir consistência
        _notifyDataChanged('equinos', 'add', equino);
        debugPrint('✅ UnifiedDataService: Equino adicionado com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao adicionar equino: \$e');
      rethrow;
    }
  }

  // ========== MÉTODOS PÚBLICOS - PLUVIÔMETROS ==========

  /// Atualiza lista de pluviômetros
  Future<void> refreshPluviometros() async {
    try {
      isLoadingPluviometros.value = true;
      debugPrint('🌧️ UnifiedDataService: Carregando pluviômetros...');

      final data = await _pluviometrosRepository.getPluviometros();
      pluviometros.assignAll(data);

      debugPrint(
          '✅ UnifiedDataService: \${data.length} pluviômetros carregados');
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao carregar pluviômetros: \$e');
      rethrow;
    } finally {
      isLoadingPluviometros.value = false;
    }
  }

  /// Adiciona novo pluviômetro
  Future<void> addPluviometro(Pluviometro pluviometro) async {
    try {
      debugPrint(
          '🌧️ UnifiedDataService: Adicionando pluviômetro: \${pluviometro.descricao}');

      final success = await _pluviometrosRepository.addPluviometro(pluviometro);
      if (success) {
        await refreshPluviometros(); // Refresh para garantir consistência
        _notifyDataChanged('pluviometros', 'add', pluviometro);
        debugPrint('✅ UnifiedDataService: Pluviômetro adicionado com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao adicionar pluviômetro: \$e');
      rethrow;
    }
  }

  /// Atualiza pluviômetro existente
  Future<void> updatePluviometro(Pluviometro pluviometro) async {
    try {
      debugPrint(
          '🌧️ UnifiedDataService: Atualizando pluviômetro: \${pluviometro.descricao}');

      final success =
          await _pluviometrosRepository.updatePluviometro(pluviometro);
      if (success) {
        final index = pluviometros.indexWhere((p) => p.id == pluviometro.id);
        if (index != -1) {
          pluviometros[index] = pluviometro;
        }
        _notifyDataChanged('pluviometros', 'update', pluviometro);
        debugPrint('✅ UnifiedDataService: Pluviômetro atualizado com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao atualizar pluviômetro: \$e');
      rethrow;
    }
  }

  /// Remove pluviômetro
  Future<void> deletePluviometro(String pluviometroId) async {
    try {
      debugPrint(
          '🌧️ UnifiedDataService: Removendo pluviômetro: \$pluviometroId');

      final pluviometro =
          pluviometros.firstWhereOrNull((p) => p.id == pluviometroId);
      if (pluviometro != null) {
        final success =
            await _pluviometrosRepository.deletePluviometro(pluviometro);
        if (success) {
          pluviometros.removeWhere((p) => p.id == pluviometroId);
          _notifyDataChanged('pluviometros', 'delete', pluviometroId);
          debugPrint('✅ UnifiedDataService: Pluviômetro removido com sucesso');
        }
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao remover pluviômetro: \$e');
      rethrow;
    }
  }

  // ========== MÉTODOS PÚBLICOS - MEDIÇÕES ==========

  /// Atualiza medições do pluviômetro atual
  Future<void> refreshCurrentMeasurements() async {
    final pluviometroId = _stateManager.selectedPluviometroId.value;
    if (pluviometroId.isEmpty) {
      currentMeasurements.clear();
      return;
    }

    try {
      isLoadingMeasurements.value = true;
      debugPrint(
          '📊 UnifiedDataService: Carregando medições para pluviômetro: \$pluviometroId');

      final data = await _medicoesRepository.getMedicoes(pluviometroId);
      currentMeasurements.assignAll(data);
      _sortMeasurements();

      debugPrint('✅ UnifiedDataService: \${data.length} medições carregadas');
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao carregar medições: \$e');
      rethrow;
    } finally {
      isLoadingMeasurements.value = false;
    }
  }

  /// Adiciona nova medição
  Future<void> addMeasurement(Medicoes medicao) async {
    try {
      debugPrint(
          '📊 UnifiedDataService: Adicionando medição: \${medicao.quantidade}');

      final success = await _medicoesRepository.addMedicao(medicao);
      if (success) {
        // Se a medição é do pluviômetro atual, adicionar na lista
        if (medicao.fkPluviometro ==
            _stateManager.selectedPluviometroId.value) {
          currentMeasurements.add(medicao);
          _sortMeasurements();
        }
        _notifyDataChanged('measurements', 'add', medicao);
        debugPrint('✅ UnifiedDataService: Medição adicionada com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao adicionar medição: \$e');
      rethrow;
    }
  }

  /// Atualiza medição existente
  Future<void> updateMeasurement(Medicoes medicao) async {
    try {
      debugPrint('📊 UnifiedDataService: Atualizando medição: \${medicao.id}');

      final success = await _medicoesRepository.updateMedicao(medicao);
      if (success) {
        // Se a medição é do pluviômetro atual, atualizar na lista
        if (medicao.fkPluviometro ==
            _stateManager.selectedPluviometroId.value) {
          final index =
              currentMeasurements.indexWhere((m) => m.id == medicao.id);
          if (index != -1) {
            currentMeasurements[index] = medicao;
            _sortMeasurements();
          }
        }
        _notifyDataChanged('measurements', 'update', medicao);
        debugPrint('✅ UnifiedDataService: Medição atualizada com sucesso');
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao atualizar medição: \$e');
      rethrow;
    }
  }

  /// Remove medição
  Future<void> deleteMeasurement(String medicaoId) async {
    try {
      debugPrint('📊 UnifiedDataService: Removendo medição: \$medicaoId');

      final medicao =
          currentMeasurements.firstWhereOrNull((m) => m.id == medicaoId);
      if (medicao != null) {
        final success = await _medicoesRepository.deleteMedicao(medicao);
        if (success) {
          currentMeasurements.removeWhere((m) => m.id == medicaoId);
          _notifyDataChanged('measurements', 'delete', medicaoId);
          debugPrint('✅ UnifiedDataService: Medição removida com sucesso');
        }
      }
    } catch (e) {
      debugPrint('❌ UnifiedDataService: Erro ao remover medição: \$e');
      rethrow;
    }
  }

  // ========== MÉTODOS PÚBLICOS - SINCRONIZAÇÃO ==========

  /// Sincroniza todos os dados
  Future<void> syncAllData() async {
    debugPrint('🔄 UnifiedDataService: Sincronizando todos os dados...');

    final futures = [
      refreshBovinos(),
      refreshEquinos(),
      refreshPluviometros(),
      refreshCurrentMeasurements(),
    ];

    await Future.wait(futures);
    debugPrint('✅ UnifiedDataService: Sincronização completa concluída');
  }

  /// Limpa todos os dados (útil para logout)
  void clearAllData() {
    bovinos.clear();
    equinos.clear();
    pluviometros.clear();
    currentMeasurements.clear();

    debugPrint('🧹 UnifiedDataService: Todos os dados limpos');
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Ordena medições por data (mais recente primeiro)
  void _sortMeasurements() {
    currentMeasurements.sort((a, b) => b.dtMedicao.compareTo(a.dtMedicao));
  }

  /// Notifica outros components sobre mudanças nos dados
  void _notifyDataChanged(String dataType, String action, dynamic data) {
    // Note: For now, we'll emit the event through a different approach
    // since _emitStateEvent is private
    debugPrint(
        '📡 UnifiedDataService: Notificando mudança: $dataType ($action)');
  }

  // ========== CLEANUP ==========

  @override
  void onClose() {
    debugPrint('🔚 UnifiedDataService: Service unificado finalizado');
    super.onClose();
  }
}
