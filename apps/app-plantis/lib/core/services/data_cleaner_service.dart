import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';

class DataCleanerService implements IAppDataCleaner {
  final PlantsRepository plantsRepository;
  final TasksRepository tasksRepository;
  final SpacesRepository spacesRepository;
  final DeletePlantUseCase deletePlantUseCase;

  DataCleanerService({
    required this.plantsRepository,
    required this.tasksRepository,
    required this.spacesRepository,
    required this.deletePlantUseCase,
  });

  @override
  String get appName => 'Plantis';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Limpeza de plantas, tarefas e dados relacionados do Plantis';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    // Para logout, usar limpeza local sem marcação como deletado
    return clearAllAppDataForLogout();
  }

  /// Limpeza específica para logout - remove dados locais sem marcar como deletado
  /// Evita sincronização indevida com Firebase durante logout
  Future<Map<String, dynamic>> clearAllAppDataForLogout() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      // Obter estatísticas antes da limpeza
      final statsBefore = await getDataStatsBeforeCleaning();
      final totalBefore = statsBefore['totalRecords'] as int;

      // 1. Limpar todas as tarefas individualmente (limpeza local sem soft delete)
      try {
        final tasksResult = await tasksRepository.getTasks();
        if (tasksResult.isRight()) {
          final tasks = tasksResult.getOrElse(() => []);
          for (final task in tasks) {
            try {
              await tasksRepository.deleteTask(task.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar tarefa ${task.id}: $e');
            }
          }
        }
        (result['clearedBoxes'] as List<String>).add('tasks_box');
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar tasks localmente: $e');
      }

      // 2. Limpar todas as plantas individualmente (limpeza local sem soft delete)
      try {
        final plantsResult = await plantsRepository.getPlants();
        if (plantsResult.isRight()) {
          final plants = plantsResult.getOrElse(() => []);
          for (final plant in plants) {
            try {
              await deletePlantUseCase(plant.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar planta ${plant.id}: $e');
            }
          }
        }
        (result['clearedBoxes'] as List<String>).add('plants_box');
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar plants localmente: $e');
      }

      // 3. Limpar todos os espaços individualmente (limpeza local sem soft delete)
      try {
        final spacesResult = await spacesRepository.getSpaces();
        if (spacesResult.isRight()) {
          final spaces = spacesResult.getOrElse(() => []);
          for (final space in spaces) {
            try {
              await spacesRepository.deleteSpace(space.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar espaço ${space.id}: $e');
            }
          }
        }
        (result['clearedBoxes'] as List<String>).add('spaces_box');
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar spaces localmente: $e');
      }

      result['totalRecordsCleared'] = totalBefore;
      result['success'] = (result['errors'] as List<String>).isEmpty;

      return result;
    } catch (e) {
      (result['errors'] as List<String>).add('Erro geral: $e');
      return result;
    }
  }

  /// Limpeza padrão para exclusão de conta - marca como deletado para sincronização
  Future<Map<String, dynamic>> clearAllAppDataForAccountDeletion() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      // Obter estatísticas antes da limpeza
      final statsBefore = await getDataStatsBeforeCleaning();
      final totalBefore = statsBefore['totalRecords'] as int;

      // 1. Limpar todas as tarefas com soft delete para sincronização
      final tasksResult = await tasksRepository.getTasks();
      if (tasksResult.isRight()) {
        final tasks = tasksResult.getOrElse(() => []);
        for (final task in tasks) {
          try {
            await tasksRepository.deleteTask(task.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar tarefa ${task.id}: $e');
          }
        }
        (result['clearedBoxes'] as List<String>).add('tasks_box');
      }

      // 2. Limpar todas as plantas com soft delete para sincronização
      final plantsResult = await plantsRepository.getPlants();
      if (plantsResult.isRight()) {
        final plants = plantsResult.getOrElse(() => []);
        for (final plant in plants) {
          try {
            await deletePlantUseCase(plant.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar planta ${plant.id}: $e');
          }
        }
        (result['clearedBoxes'] as List<String>).add('plants_box');
      }

      result['totalRecordsCleared'] = totalBefore;
      result['success'] = (result['errors'] as List<String>).isEmpty;

      return result;
    } catch (e) {
      (result['errors'] as List<String>).add('Erro geral: $e');
      return result;
    }
  }

  @override
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
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

      return {
        'plantsCount': plantsCount,
        'tasksCount': tasksCount,
        'totalRecords': plantsCount + tasksCount,
        'categories': ['plants', 'tasks'],
      };
    } catch (e) {
      return {
        'plantsCount': 0,
        'tasksCount': 0,
        'totalRecords': 0,
        'categories': <String>[],
        'error': e.toString(),
      };
    }
  }

  @override
  Future<bool> hasDataToClear() async {
    final stats = await getDataStatsBeforeCleaning();
    return (stats['totalRecords'] as int) > 0;
  }

  @override
  Future<bool> verifyDataCleanup() async {
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

      return plantsCount == 0 && tasksCount == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableCategories() {
    return ['plants', 'tasks', 'all'];
  }

  @override
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    switch (category) {
      case 'plants':
        return _clearPlantsOnly();
      case 'tasks':
        return _clearTasksOnly();
      case 'all':
      default:
        return clearAllAppData();
    }
  }

  Future<Map<String, dynamic>> _clearPlantsOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final plantsResult = await plantsRepository.getPlants();
      if (plantsResult.isRight()) {
        final plants = plantsResult.getOrElse(() => []);
        for (final plant in plants) {
          try {
            await deletePlantUseCase(plant.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar planta ${plant.id}: $e');
          }
        }
        result['totalRecordsCleared'] = plants.length;
        (result['clearedBoxes'] as List<String>).add('plants_box');
        result['success'] = (result['errors'] as List<String>).isEmpty;
      }
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  Future<Map<String, dynamic>> _clearTasksOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final tasksResult = await tasksRepository.getTasks();
      if (tasksResult.isRight()) {
        final tasks = tasksResult.getOrElse(() => []);
        for (final task in tasks) {
          try {
            await tasksRepository.deleteTask(task.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar tarefa ${task.id}: $e');
          }
        }
        result['totalRecordsCleared'] = tasks.length;
        (result['clearedBoxes'] as List<String>).add('tasks_box');
        result['success'] = (result['errors'] as List<String>).isEmpty;
      }
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  /// Limpa apenas o conteúdo do usuário (plantas, tarefas, espaços)
  /// Mantém: perfil, subscription, settings, theme, comentários
  Future<Map<String, dynamic>> clearUserContentOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
      'plantsCleaned': 0,
      'tasksCleaned': 0,
      'spacesCleaned': 0,
    };

    try {
      // Obter estatísticas antes da limpeza
      int totalCleared = 0;

      // 1. Limpar todas as tarefas
      final tasksResult = await tasksRepository.getTasks();
      if (tasksResult.isRight()) {
        final tasks = tasksResult.getOrElse(() => []);
        for (final task in tasks) {
          try {
            await tasksRepository.deleteTask(task.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar tarefa ${task.id}: $e');
          }
        }
        result['tasksCleaned'] = tasks.length;
        totalCleared += tasks.length;
        (result['clearedBoxes'] as List<String>).add('tasks_box');
      }

      // 2. Limpar todas as plantas
      final plantsResult = await plantsRepository.getPlants();
      if (plantsResult.isRight()) {
        final plants = plantsResult.getOrElse(() => []);
        for (final plant in plants) {
          try {
            await deletePlantUseCase(plant.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar planta ${plant.id}: $e');
          }
        }
        result['plantsCleaned'] = plants.length;
        totalCleared += plants.length;
        (result['clearedBoxes'] as List<String>).add('plants_box');
      }

      // 3. Limpar todos os espaços
      final spacesResult = await spacesRepository.getSpaces();
      if (spacesResult.isRight()) {
        final spaces = spacesResult.getOrElse(() => []);
        for (final space in spaces) {
          try {
            await spacesRepository.deleteSpace(space.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar espaço ${space.id}: $e');
          }
        }
        result['spacesCleaned'] = spaces.length;
        totalCleared += spaces.length;
        (result['clearedBoxes'] as List<String>).add('spaces_box');
      }

      result['totalRecordsCleared'] = totalCleared;
      result['success'] = (result['errors'] as List<String>).isEmpty;

      return result;
    } catch (e) {
      (result['errors'] as List<String>).add('Erro geral: $e');
      return result;
    }
  }

  // Métodos legados mantidos para compatibilidade
  Future<Either<Failure, void>> clearAllData() async {
    try {
      // 1. Primeiro, obter todas as plantas
      final plantsResult = await plantsRepository.getPlants();

      if (plantsResult.isLeft()) {
        return const Left(ServerFailure('Erro ao obter plantas'));
      }

      final plants = plantsResult.getOrElse(() => []);

      // 2. Obter todas as tarefas
      final tasksResult = await tasksRepository.getTasks();

      if (tasksResult.isLeft()) {
        return const Left(ServerFailure('Erro ao obter tarefas'));
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
