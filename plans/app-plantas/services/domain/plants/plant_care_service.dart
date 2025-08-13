// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_repository.dart';
import '../../shared/data_integrity_service.dart';
import '../tasks/simple_task_service.dart';

/// Service for plant care operations
class PlantCareService {
  static PlantCareService? _instance;
  static PlantCareService get instance => _instance ??= PlantCareService._();
  PlantCareService._();

  PlantaRepository get _plantaRepository => PlantaRepository.instance;
  EspacoRepository get _espacoRepository => EspacoRepository.instance;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _plantaRepository.initialize();
    await _espacoRepository.initialize();
    await DataIntegrityService.instance.initialize();
    _isInitialized = true;
  }

  Future<List<PlantaModel>> getAllPlants() async {
    return await _plantaRepository.findAll();
  }

  Future<List<EspacoModel>> getAllSpaces() async {
    return await _espacoRepository.findAll();
  }

  Future<PlantaModel?> getPlantById(String id) async {
    return await _plantaRepository.findById(id);
  }

  Future<String> createPlant(PlantaModel planta) async {
    // Validate plant data
    final validation = DataIntegrityService.instance.validatePlantData(planta);
    if (!validation.isValid) {
      throw Exception('Validation failed: ${validation.errors.join(', ')}');
    }

    return await _plantaRepository.create(planta);
  }

  Future<String> createSpace(EspacoModel espaco) async {
    return await _espacoRepository.createLegacy(espaco);
  }

  Future<void> updatePlant(String id, PlantaModel planta) async {
    // Validate plant data
    final validation = DataIntegrityService.instance.validatePlantData(planta);
    if (!validation.isValid) {
      throw Exception('Validation failed: ${validation.errors.join(', ')}');
    }

    await _plantaRepository.update(id, planta);
  }

  Future<void> deletePlant(String id) async {
    await _plantaRepository.delete(id);
  }

  Future<List<PlantaModel>> getPlantsBySpace(String spaceId) async {
    return await _plantaRepository.findByEspaco(spaceId);
  }

  Future<List<PlantaModel>> searchPlantsByName(String name) async {
    return await _plantaRepository.findByNome(name);
  }

  /// TODO: Reimplementar com novo sistema de tarefas
  // Métodos removidos temporariamente que usavam campos obsoletos:
  // - getPlantsByWateringSchedule
  // - getPlantsByFertilizingSchedule
  // - markWateringComplete
  // - markFertilizingComplete
  // - updatePlantCareSettings
  // - getPlantCareStatistics
  // - getPlantsNeedingWater
  // - getPlantsNeedingFertilizer

  /// Get plants that need care using SimpleTaskService
  Future<List<PlantaModel>> getPlantsNeedingCare() async {
    final taskService = SimpleTaskService.instance;
    await taskService.initialize();

    final todayTasks = await taskService.getTodayTasks();
    final overdueTasks = await taskService.getOverdueTasks();

    final plantIds = {
      ...todayTasks
          .whereType<TarefaModel>()
          .where((t) => !t.concluida)
          .map((t) => t.plantaId),
      ...overdueTasks
          .whereType<TarefaModel>()
          .where((t) => !t.concluida)
          .map((t) => t.plantaId)
    }.toSet();

    // Usar findByIds otimizado para evitar N+1 queries
    if (plantIds.isEmpty) return <PlantaModel>[];

    final repository = PlantaRepository.instance;
    return await repository.findByIds(plantIds.toList());
  }

  /// Get plant care statistics using SimpleTaskService
  Future<Map<String, int>> getCareStatistics() async {
    final plantas = await getAllPlants();
    final taskService = SimpleTaskService.instance;
    await taskService.initialize();

    final todayTasks = await taskService.getTodayTasks();
    final overdueTasks = await taskService.getOverdueTasks();
    final completedTasks =
        todayTasks.whereType<TarefaModel>().where((t) => t.concluida).toList();

    return {
      'total': plantas.length,
      'needingCare': {
        ...todayTasks
            .whereType<TarefaModel>()
            .where((t) => !t.concluida)
            .map((t) => t.plantaId)
      }.length,
      'overdue': {
        ...overdueTasks
            .whereType<TarefaModel>()
            .where((t) => !t.concluida)
            .map((t) => t.plantaId)
      }.length,
      'completed': {...completedTasks.map((t) => t.plantaId)}.length,
    };
  }
}
