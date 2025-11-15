import 'package:app_plantis/features/plants/domain/repositories/plant_tasks_repository.dart';
import 'package:app_plantis/features/plants/domain/repositories/plants_repository.dart';
import 'package:app_plantis/features/plants/domain/services/plant_task_generator.dart';
import 'package:app_plantis/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:app_plantis/features/tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Repository mocks
class MockPlantsRepository extends Mock implements PlantsRepository {}

class MockTasksRepository extends Mock implements TasksRepository {}

class MockPlantTasksRepository extends Mock implements PlantTasksRepository {}

// UseCase mocks
class MockGenerateInitialTasksUseCase extends Mock
    implements GenerateInitialTasksUseCase {}

// Service mocks
class MockPlantTaskGenerator extends Mock implements PlantTaskGenerator {}
