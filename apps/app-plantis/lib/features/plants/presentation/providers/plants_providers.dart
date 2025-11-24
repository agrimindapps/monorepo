import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plant_by_id_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/search_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../domain/services/plant_task_generator.dart';
import '../../domain/repositories/plant_comments_repository.dart';
import '../../../tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../../../tasks/presentation/providers/tasks_providers.dart';
import '../../../../core/services/task_generation_service.dart';

// Import core providers
import '../../../../core/providers/repository_providers.dart';

part 'plants_providers.g.dart';

// Services
@riverpod
TaskGenerationService taskGenerationService(TaskGenerationServiceRef ref) {
  return TaskGenerationService();
}

@riverpod
PlantTaskGenerator plantTaskGenerator(PlantTaskGeneratorRef ref) {
  return PlantTaskGenerator();
}

// UseCases
@riverpod
GenerateInitialTasksUseCase generateInitialTasksUseCase(
    GenerateInitialTasksUseCaseRef ref) {
  return GenerateInitialTasksUseCase(
    tasksRepository: ref.watch(tasksRepositoryProvider),
    taskGenerationService: ref.watch(taskGenerationServiceProvider),
  );
}

@riverpod
GetPlantsUseCase getPlantsUseCase(GetPlantsUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return GetPlantsUseCase(repository);
}

@riverpod
GetPlantByIdUseCase getPlantByIdUseCase(GetPlantByIdUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return GetPlantByIdUseCase(repository);
}

@riverpod
SearchPlantsUseCase searchPlantsUseCase(SearchPlantsUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return SearchPlantsUseCase(repository);
}

@riverpod
AddPlantUseCase addPlantUseCase(AddPlantUseCaseRef ref) {
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
UpdatePlantUseCase updatePlantUseCase(UpdatePlantUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return UpdatePlantUseCase(repository);
}

@riverpod
DeletePlantUseCase deletePlantUseCase(DeletePlantUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return DeletePlantUseCase(repository);
}