import 'package:core/core.dart';

import '../entities/plant.dart';
import '../usecases/add_plant_usecase.dart';
import '../usecases/delete_plant_usecase.dart';
import '../usecases/get_plants_usecase.dart';
import '../usecases/update_plant_usecase.dart';

/// Service responsible for CRUD operations on plants
/// Extracted from PlantsProvider to follow Single Responsibility Principle
@injectable
class PlantsCrudService {
  PlantsCrudService({
    required GetPlantsUseCase getPlantsUseCase,
    required GetPlantByIdUseCase getPlantByIdUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
    required ILoggingRepository logger,
  })  : _getPlantsUseCase = getPlantsUseCase,
        _getPlantByIdUseCase = getPlantByIdUseCase,
        _addPlantUseCase = addPlantUseCase,
        _updatePlantUseCase = updatePlantUseCase,
        _deletePlantUseCase = deletePlantUseCase,
        _logger = logger;

  final GetPlantsUseCase _getPlantsUseCase;
  final GetPlantByIdUseCase _getPlantByIdUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;
  final DeletePlantUseCase _deletePlantUseCase;
  final ILoggingRepository _logger;

  /// Load all plants from repository
  /// Returns Either<Failure, List<Plant>>
  Future<Either<Failure, List<Plant>>> getAllPlants() async {
    _logger.debug('Loading all plants');
    return await _getPlantsUseCase.call(const NoParams());
  }

  /// Get single plant by ID
  Future<Either<Failure, Plant?>> getPlantById(String id) async {
    _logger.debug('Getting plant by ID', data: {'plant_id': id});
    return await _getPlantByIdUseCase.call(id);
  }

  /// Add new plant
  Future<Either<Failure, Plant>> addPlant(AddPlantParams params) async {
    _logger.debug('Adding new plant', data: {'plant_name': params.name});
    return await _addPlantUseCase.call(params);
  }

  /// Update existing plant
  Future<Either<Failure, Plant>> updatePlant(UpdatePlantParams params) async {
    _logger.debug('Updating plant', data: {'plant_id': params.id});
    return await _updatePlantUseCase.call(params);
  }

  /// Delete plant
  Future<Either<Failure, void>> deletePlant(String id) async {
    _logger.debug('Deleting plant', data: {'plant_id': id});
    return await _deletePlantUseCase.call(id);
  }

  /// Get count of all plants
  int getPlantCount(List<Plant> plants) {
    return plants.length;
  }

  /// Get plants by space ID
  List<Plant> getPlantsBySpace(List<Plant> plants, String spaceId) {
    return plants.where((plant) => plant.spaceId == spaceId).toList();
  }
}
