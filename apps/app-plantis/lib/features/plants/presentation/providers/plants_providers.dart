import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plant_by_id_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/search_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../domain/services/plant_task_generator.dart';
import '../../../tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../../../tasks/presentation/providers/tasks_providers.dart';
import '../../../../core/services/task_generation_service.dart';

// Import core providers
import '../../../../core/providers/repository_providers.dart';

part 'plants_providers.g.dart';

// Services
@riverpod
TaskGenerationService taskGenerationService(Ref ref) {
  return TaskGenerationService();
}

@riverpod
PlantTaskGenerator plantTaskGenerator(Ref ref) {
  return PlantTaskGenerator();
}

// UseCases
@riverpod
GenerateInitialTasksUseCase generateInitialTasksUseCase(
    Ref ref) {
  return GenerateInitialTasksUseCase(
    tasksRepository: ref.watch(tasksRepositoryProvider),
    taskGenerationService: ref.watch(taskGenerationServiceProvider),
  );
}

@riverpod
GetPlantsUseCase getPlantsUseCase(Ref ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return GetPlantsUseCase(repository);
}

@riverpod
GetPlantByIdUseCase getPlantByIdUseCase(Ref ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return GetPlantByIdUseCase(repository);
}

@riverpod
SearchPlantsUseCase searchPlantsUseCase(Ref ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return SearchPlantsUseCase(repository);
}

@riverpod
AddPlantUseCase addPlantUseCase(Ref ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  final generateInitialTasks = ref.watch(generateInitialTasksUseCaseProvider);
  final plantTaskGenerator = ref.watch(plantTaskGeneratorProvider);
  final plantTasksRepository = ref.watch(plantTasksRepositoryProvider);

  return AddPlantUseCase(
    repository,
    generateInitialTasks,
    plantTaskGenerator,
    plantTasksRepository,
  );
}

@riverpod
UpdatePlantUseCase updatePlantUseCase(Ref ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return UpdatePlantUseCase(repository);
}

@riverpod
DeletePlantUseCase deletePlantUseCase(Ref ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return DeletePlantUseCase(repository);
}