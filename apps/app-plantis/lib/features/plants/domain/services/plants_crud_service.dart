import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../entities/plant.dart';
import '../usecases/add_plant_usecase.dart';
import '../usecases/delete_plant_usecase.dart';
import '../usecases/get_plants_usecase.dart';
import '../usecases/update_plant_usecase.dart';

/// Service responsible for CRUD operations on plants
/// Extracted from PlantsProvider to follow Single Responsibility Principle
class PlantsCrudService {
  final GetPlantsUseCase _getPlantsUseCase;
  final GetPlantByIdUseCase _getPlantByIdUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;
  final DeletePlantUseCase _deletePlantUseCase;

  PlantsCrudService({
    required GetPlantsUseCase getPlantsUseCase,
    required GetPlantByIdUseCase getPlantByIdUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
  })  : _getPlantsUseCase = getPlantsUseCase,
        _getPlantByIdUseCase = getPlantByIdUseCase,
        _addPlantUseCase = addPlantUseCase,
        _updatePlantUseCase = updatePlantUseCase,
        _deletePlantUseCase = deletePlantUseCase;

  /// Load all plants from repository
  /// Returns Either<Failure, List<Plant>>
  Future<Either<Failure, List<Plant>>> getAllPlants() async {
    if (kDebugMode) {
      print('📋 PlantsCrudService: Loading all plants');
    }
    return await _getPlantsUseCase.call(const NoParams());
  }

  /// Get single plant by ID
  Future<Either<Failure, Plant?>> getPlantById(String id) async {
    if (kDebugMode) {
      print('📋 PlantsCrudService: Getting plant by ID: $id');
    }
    return await _getPlantByIdUseCase.call(id);
  }

  /// Add new plant
  Future<Either<Failure, Plant>> addPlant(AddPlantParams params) async {
    if (kDebugMode) {
      print('📋 PlantsCrudService: Adding new plant: ${params.name}');
    }
    return await _addPlantUseCase.call(params);
  }

  /// Update existing plant
  Future<Either<Failure, Plant>> updatePlant(UpdatePlantParams params) async {
    if (kDebugMode) {
      print('📋 PlantsCrudService: Updating plant: ${params.id}');
    }
    return await _updatePlantUseCase.call(params);
  }

  /// Delete plant
  Future<Either<Failure, void>> deletePlant(String id) async {
    if (kDebugMode) {
      print('📋 PlantsCrudService: Deleting plant: $id');
    }
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

  /// Get error message from Failure
  String getErrorMessage(Failure failure) {
    if (kDebugMode) {
      print('PlantsCrudService Error Details:');
      print('- Type: ${failure.runtimeType}');
      print('- Message: ${failure.message}');
    }

    switch (failure.runtimeType) {
      case ValidationFailure _:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Dados inválidos fornecidos';
      case CacheFailure _:
        if (failure.message.contains('PlantaModelAdapter') ||
            failure.message.contains('TypeAdapter')) {
          return 'Erro ao acessar dados locais. O app será reiniciado para corrigir o problema.';
        }
        if (failure.message.contains('HiveError') ||
            failure.message.contains('corrupted')) {
          return 'Dados locais corrompidos. Sincronizando com servidor...';
        }
        return failure.message.isNotEmpty
            ? 'Cache: ${failure.message}'
            : 'Erro ao acessar dados locais';
      case NetworkFailure _:
        return 'Sem conexão com a internet. Verifique sua conectividade.';
      case ServerFailure _:
        if (failure.message.contains('não autenticado') ||
            failure.message.contains('unauthorized') ||
            failure.message.contains('Usuário não autenticado')) {
          return 'Sessão expirada. Tente fazer login novamente.';
        }
        if (failure.message.contains('403') ||
            failure.message.contains('Forbidden')) {
          return 'Acesso negado. Verifique suas permissões.';
        }
        if (failure.message.contains('500') ||
            failure.message.contains('Internal')) {
          return 'Erro no servidor. Tente novamente em alguns instantes.';
        }
        return failure.message.isNotEmpty
            ? 'Servidor: ${failure.message}'
            : 'Erro no servidor';
      case NotFoundFailure _:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Dados não encontrados';
      default:
        final errorContext =
            kDebugMode ? ' (${failure.runtimeType}: ${failure.message})' : '';
        return 'Ops! Algo deu errado$errorContext';
    }
  }
}
