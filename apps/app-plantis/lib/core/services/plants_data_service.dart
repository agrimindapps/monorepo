import 'package:core/core.dart' hide Column;

import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../interfaces/i_auth_state_provider.dart';

/// Serviço responsável APENAS pelas operações de dados das plantas
/// Resolve violação SRP - separando operações CRUD do estado UI
class PlantsDataService {
  final IAuthStateProvider _authProvider;
  final GetPlantsUseCase _getPlantsUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;
  final DeletePlantUseCase _deletePlantUseCase;

  PlantsDataService({
    required IAuthStateProvider authProvider,
    required GetPlantsUseCase getPlantsUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
  })  : _authProvider = authProvider,
        _getPlantsUseCase = getPlantsUseCase,
        _addPlantUseCase = addPlantUseCase,
        _updatePlantUseCase = updatePlantUseCase,
        _deletePlantUseCase = deletePlantUseCase;

  /// Carrega todas as plantas do usuário
  Future<Either<Failure, List<Plant>>> loadPlants() async {
    try {
      await _authProvider.ensureInitialized();
      if (!_authProvider.isAuthenticated) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }
      final result = await _getPlantsUseCase.call(const NoParams());
      
      return result.fold(
        (failure) => Left(failure),
        (plants) {
          final activePlants = plants.where((plant) => !plant.isDeleted).toList();
          return Right(activePlants);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar plantas: $e'));
    }
  }

  /// Adiciona uma nova planta
  Future<Either<Failure, Plant>> addPlant(AddPlantParams params) async {
    try {
      if (!_authProvider.isAuthenticated) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final result = await _addPlantUseCase.call(params);
      
      return result.fold(
        (failure) => Left(failure),
        (plant) => Right(plant),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar planta: $e'));
    }
  }

  /// Atualiza uma planta existente
  Future<Either<Failure, Plant>> updatePlant(UpdatePlantParams params) async {
    try {
      if (!_authProvider.isAuthenticated) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final result = await _updatePlantUseCase.call(params);
      
      return result.fold(
        (failure) => Left(failure),
        (plant) => Right(plant),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar planta: $e'));
    }
  }

  /// Remove uma planta (soft delete)
  Future<Either<Failure, void>> deletePlant(String plantId) async {
    try {
      if (!_authProvider.isAuthenticated) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final result = await _deletePlantUseCase.call(plantId);
      
      return result.fold(
        (failure) => Left(failure),
        (success) => const Right(null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar planta: $e'));
    }
  }

  /// Busca uma planta específica por ID
  Future<Either<Failure, Plant?>> getPlantById(String plantId) async {
    try {
      final plantsResult = await loadPlants();
      
      return plantsResult.fold(
        (failure) => Left(failure),
        (plants) {
          final plant = plants.where((p) => p.id == plantId).firstOrNull;
          return Right(plant);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar planta: $e'));
    }
  }

  /// Verifica se o usuário atual é o proprietário da planta
  bool isCurrentUserOwner(Plant plant) {
    final currentUserId = _authProvider.currentUserId;
    return currentUserId != null && plant.userId == currentUserId;
  }

  /// Obtém plantas por espaço
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String? spaceId) async {
    try {
      final plantsResult = await loadPlants();
      
      return plantsResult.fold(
        (failure) => Left(failure),
        (plants) {
          final filteredPlants = plants.where((plant) => plant.spaceId == spaceId).toList();
          return Right(filteredPlants);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar plantas por espaço: $e'));
    }
  }
}

