import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';

class DataCleanerService {
  final PlantsRepository plantsRepository;
  final TasksRepository tasksRepository;
  final DeletePlantUseCase deletePlantUseCase;

  DataCleanerService({
    required this.plantsRepository,
    required this.tasksRepository,
    required this.deletePlantUseCase,
  });

  Future<Either<Failure, void>> clearAllData() async {
    try {
      // 1. Primeiro, obter todas as plantas
      final plantsResult = await plantsRepository.getPlants();

      if (plantsResult.isLeft()) {
        return Left(ServerFailure('Erro ao obter plantas'));
      }

      final plants = plantsResult.getOrElse(() => []);

      // 2. Obter todas as tarefas
      final tasksResult = await tasksRepository.getTasks();

      if (tasksResult.isLeft()) {
        return Left(ServerFailure('Erro ao obter tarefas'));
      }

      final tasks = tasksResult.getOrElse(() => []);

      // 3. Deletar todas as tarefas primeiro
      for (final task in tasks) {
        await tasksRepository.deleteTask(task.id);
      }

      // 4. Deletar todas as plantas
      for (final plant in plants) {
        await deletePlantUseCase(plant.id);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao limpar dados: $e'));
    }
  }

  Future<DataClearStats> getDataStats() async {
    try {
      final plantsResult = await plantsRepository.getPlants();
      final tasksResult = await tasksRepository.getTasks();

      final plantsCount = plantsResult.fold(
        (failure) => 0,
        (plants) => plants.length,
      );

      final tasksCount = tasksResult.fold(
        (failure) => 0,
        (tasks) => tasks.length,
      );

      return DataClearStats(plantsCount: plantsCount, tasksCount: tasksCount);
    } catch (e) {
      return const DataClearStats(plantsCount: 0, tasksCount: 0);
    }
  }
}

class DataClearStats {
  final int plantsCount;
  final int tasksCount;

  const DataClearStats({required this.plantsCount, required this.tasksCount});

  int get totalItems => plantsCount + tasksCount;

  bool get hasData => totalItems > 0;
}
