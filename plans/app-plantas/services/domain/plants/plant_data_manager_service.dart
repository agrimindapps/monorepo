// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_model.dart';
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_repository.dart';
import '../tasks/task_operations_service.dart';

/// Service unificado para gerenciamento de dados de plantas
/// Consolida PlantCareService e PlantasDataService
class PlantDataManagerService {
  static PlantDataManagerService? _instance;
  static PlantDataManagerService get instance =>
      _instance ??= PlantDataManagerService._();
  PlantDataManagerService._();

  // Repositories
  final PlantaRepository _plantaRepository = PlantaRepository.instance;
  final EspacoRepository _espacoRepository = EspacoRepository.instance;

  bool _isInitialized = false;

  /// Inicializar service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _plantaRepository.initialize();
    await _espacoRepository.initialize();
    _isInitialized = true;
  }

  /// Carregar todos os dados (plantas e espaços)
  Future<PlantDataLoadResult> loadAllData() async {
    await initialize();

    try {
      // Carregar dados em paralelo
      final results = await Future.wait([
        _plantaRepository.findAll(),
        _espacoRepository.findAll(),
      ]);

      final plantas = results[0] as List<PlantaModel>;
      final espacos = results[1] as List<EspacoModel>;

      debugPrint(
          '✅ PlantDataManagerService: ${plantas.length} plantas e ${espacos.length} espaços carregados');

      return PlantDataLoadResult(
        success: true,
        plantas: plantas,
        espacos: espacos,
      );
    } catch (e) {
      debugPrint('❌ PlantDataManagerService: Erro ao carregar dados: $e');
      return PlantDataLoadResult(
        success: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  /// Buscar plantas por espaço
  Future<List<PlantaModel>> getPlantasByEspaco(String espacoId) async {
    await initialize();

    try {
      return await _plantaRepository.findByEspaco(espacoId);
    } catch (e) {
      debugPrint(
          '❌ PlantDataManagerService: Erro ao buscar plantas por espaço: $e');
      return [];
    }
  }

  /// Buscar plantas por nome (search)
  Future<List<PlantaModel>> searchPlantas(String query) async {
    await initialize();

    try {
      if (query.isEmpty) return await _plantaRepository.findAll();

      return await _plantaRepository.findByNome(query);
    } catch (e) {
      debugPrint('❌ PlantDataManagerService: Erro na busca: $e');
      return [];
    }
  }

  /// Criar nova planta
  Future<PlantOperationResult> createPlanta(PlantaModel planta) async {
    await initialize();

    try {
      final id = await _plantaRepository.create(planta);

      return PlantOperationResult(
        success: true,
        plantaId: id,
        message: 'Planta criada com sucesso',
      );
    } catch (e) {
      return PlantOperationResult(
        success: false,
        error: 'Erro ao criar planta: $e',
      );
    }
  }

  /// Atualizar planta
  Future<PlantOperationResult> updatePlanta(
      String id, PlantaModel planta) async {
    await initialize();

    try {
      await _plantaRepository.update(id, planta);

      return PlantOperationResult(
        success: true,
        plantaId: id,
        message: 'Planta atualizada com sucesso',
      );
    } catch (e) {
      return PlantOperationResult(
        success: false,
        error: 'Erro ao atualizar planta: $e',
      );
    }
  }

  /// Deletar planta
  Future<PlantOperationResult> deletePlanta(String id) async {
    await initialize();

    try {
      await _plantaRepository.delete(id);

      return PlantOperationResult(
        success: true,
        plantaId: id,
        message: 'Planta removida com sucesso',
      );
    } catch (e) {
      return PlantOperationResult(
        success: false,
        error: 'Erro ao remover planta: $e',
      );
    }
  }

  /// Obter estatísticas completas
  Future<Map<String, dynamic>> getComprehensiveStatistics() async {
    await initialize();

    try {
      // Combinar estatísticas de plantas e tarefas
      final plantStats = await _plantaRepository.getEstatisticas();
      final taskStats =
          await TaskOperationsService.instance.getTaskStatistics();

      return {
        'plantas': plantStats,
        'tarefas': taskStats,
        'resumo': {
          'total_plantas': plantStats['total'] ?? 0,
          'plantas_com_cuidados': plantStats['precisaCuidados'] ?? 0,
          'tarefas_pendentes': taskStats['pendentes'] ?? 0,
          'tarefas_atrasadas': taskStats['atrasadas'] ?? 0,
        }
      };
    } catch (e) {
      debugPrint(
          '❌ PlantDataManagerService: Erro ao calcular estatísticas: $e');
      return {};
    }
  }

  /// Forçar sincronização de dados
  Future<void> forceSyncAll() async {
    await initialize();

    try {
      await Future.wait([
        _plantaRepository.forceSync(),
        _espacoRepository.forceSync(),
      ]);

      debugPrint('✅ PlantDataManagerService: Sincronização forçada concluída');
    } catch (e) {
      debugPrint('❌ PlantDataManagerService: Erro na sincronização: $e');
    }
  }

  /// Buscar planta por ID
  Future<PlantaModel?> getPlantaById(String id) async {
    await initialize();

    try {
      return await _plantaRepository.findById(id);
    } catch (e) {
      debugPrint('❌ PlantDataManagerService: Erro ao buscar planta: $e');
      return null;
    }
  }

  /// Buscar múltiplas plantas por IDs
  Future<List<PlantaModel>> getPlantasByIds(List<String> ids) async {
    await initialize();

    try {
      return await _plantaRepository.findByIds(ids);
    } catch (e) {
      debugPrint('❌ PlantDataManagerService: Erro ao buscar plantas: $e');
      return [];
    }
  }
}

/// Resultado de carregamento de dados
class PlantDataLoadResult {
  final bool success;
  final List<PlantaModel> plantas;
  final List<EspacoModel> espacos;
  final String? error;

  PlantDataLoadResult({
    required this.success,
    this.plantas = const [],
    this.espacos = const [],
    this.error,
  });
}

/// Resultado de operação de planta
class PlantOperationResult {
  final bool success;
  final String? plantaId;
  final String? error;
  final String? message;

  PlantOperationResult({
    required this.success,
    this.plantaId,
    this.error,
    this.message,
  });
}
