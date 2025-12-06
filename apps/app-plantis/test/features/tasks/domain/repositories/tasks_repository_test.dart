import 'package:app_plantis/features/tasks/domain/entities/task.dart';
import 'package:app_plantis/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:core/core.dart' hide Column, Task;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_fixtures.dart';

/// Concrete implementation for testing abstract TasksRepository
class _TestTasksRepository implements TasksRepository {
  final List<Task> _tasks = [];

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    return Right(_tasks);
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      return Right(task);
    } catch (e) {
      return Left(NotFoundFailure('Task with id $id not found'));
    }
  }

  @override
  Future<Either<Failure, Task>> addTask(Task task) async {
    _tasks.add(task);
    return Right(task);
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      return const Left(NotFoundFailure('Task not found'));
    }
    _tasks[index] = task;
    return Right(task);
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    return const Right(null);
  }

  Future<Either<Failure, List<Task>>> getTasksByPlant(String plantId) async {
    final results = _tasks.where((t) => t.plantId == plantId).toList();
    return Right(results);
  }

  Future<Either<Failure, List<Task>>> getCompletedTasks() async {
    final results = _tasks.where((t) => t.status == TaskStatus.completed).toList();
    return Right(results);
  }

  Future<Either<Failure, List<Task>>> getPendingTasks() async {
    final results = _tasks.where((t) => t.status == TaskStatus.pending).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    final now = DateTime.now();
    final results = _tasks
        .where((t) => t.status != TaskStatus.completed && t.dueDate.isBefore(now))
        .toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, Task>> completeTask(
    String id, {
    String? notes,
    DateTime? nextDueDate,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Left(NotFoundFailure('Task not found'));
    }
    final completedTask = _tasks[index].copyWithTaskData(
      status: TaskStatus.completed,
      completionNotes: notes,
    );
    _tasks[index] = completedTask;
    return Right(completedTask);
  }

  @override
  Future<Either<Failure, void>> markTaskAsOverdue(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Left(NotFoundFailure('Task not found'));
    }
    _tasks[index] = _tasks[index].copyWithTaskData(
      status: TaskStatus.overdue,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, Task>> createRecurringTask(Task completedTask) async {
    if (!completedTask.isRecurring) {
      return const Left(ValidationFailure('Task is not recurring'));
    }
    final intervalDays = completedTask.recurringIntervalDays ?? 7;
    final newTask = completedTask.copyWithTaskData(
      dueDate: completedTask.dueDate.add(Duration(days: intervalDays)),
      status: TaskStatus.pending,
      completionNotes: null,
    );
    _tasks.add(newTask);
    return Right(newTask);
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPlantId(String plantId) async {
    final results = _tasks.where((t) => t.plantId == plantId).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(
      TaskStatus status) async {
    final results = _tasks.where((t) => t.status == status).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    final results = _tasks
        .where((t) =>
            t.isDueToday &&
            t.status != TaskStatus.completed &&
            t.status != TaskStatus.cancelled)
        .toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Task>>> getUpcomingTasks() async {
    final now = DateTime.now();
    final results = _tasks
        .where((t) =>
            t.dueDate.isAfter(now) &&
            t.status == TaskStatus.pending)
        .toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Task>>> filterByPlantId(String plantId) async {
    final results = _tasks.where((t) => t.plantId == plantId).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Task>>> filterByStatus(TaskStatus status) async {
    final results = _tasks.where((t) => t.status == status).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.status == TaskStatus.completed).length;
    final pending = _tasks.where((t) => t.status == TaskStatus.pending).length;
    final overdue = _tasks.where((t) => 
      t.status != TaskStatus.completed && 
      t.dueDate.isBefore(DateTime.now())
    ).length;
    
    return Right({
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    });
  }

  @override
  Future<Either<Failure, List<Task>>> searchTasks(String query) async {
    final results = _tasks.where((t) =>
      t.title.toLowerCase().contains(query.toLowerCase()) ||
      (t.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
    return Right(results);
  }
}

void main() {
  late _TestTasksRepository repository;

  setUp(() {
    repository = _TestTasksRepository();
  });

  group('TasksRepository', () {
    test('should add task and retrieve it', () async {
      // Arrange
      final task = TestFixtures.createTestTask();

      // Act
      final addResult = await repository.addTask(task);
      final getResult = await repository.getTaskById(task.id);

      // Assert
      expect(addResult.isRight(), true);
      expect(getResult.isRight(), true);
      getResult.fold(
        (_) => fail('Should return task'),
        (retrievedTask) {
          expect(retrievedTask.id, equals(task.id));
          expect(retrievedTask.title, equals(task.title));
        },
      );
    });

    test('should return NotFoundFailure when task does not exist', () async {
      // Act
      final result = await repository.getTaskById('non-existent-id');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should get all tasks', () async {
      // Arrange
      final tasks = TestFixtures.createTestTasks(count: 3);

      // Act
      for (var task in tasks) {
        await repository.addTask(task);
      }
      final result = await repository.getTasks();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return tasks'),
        (retrievedTasks) {
          expect(retrievedTasks.length, equals(3));
        },
      );
    });

    test('should update existing task', () async {
      // Arrange
      final originalTask = TestFixtures.createTestTask(title: 'Original Title');
      await repository.addTask(originalTask);

      final updatedTask = originalTask.copyWithTaskData(
        title: 'Updated Title',
      );

      // Act
      final result = await repository.updateTask(updatedTask);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return updated task'),
        (task) {
          expect(task.title, equals('Updated Title'));
        },
      );
    });

    test('should return Left when updating non-existent task', () async {
      // Arrange
      final task = TestFixtures.createTestTask(id: 'non-existent');

      // Act
      final result = await repository.updateTask(task);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should delete task by id', () async {
      // Arrange
      final task = TestFixtures.createTestTask();
      await repository.addTask(task);

      // Act
      await repository.deleteTask(task.id);
      final getResult = await repository.getTaskById(task.id);

      // Assert
      expect(getResult.isLeft(), true);
    });

    test('should get tasks by plant id', () async {
      // Arrange
      final task1 = TestFixtures.createTestTask(
        id: 'task-1',
        plantId: 'plant-1',
      );
      final task2 = TestFixtures.createTestTask(
        id: 'task-2',
        plantId: 'plant-2',
      );
      await repository.addTask(task1);
      await repository.addTask(task2);

      // Act
      final result = await repository.getTasksByPlant('plant-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return tasks'),
        (tasks) {
          expect(tasks.length, equals(1));
          expect(tasks[0].plantId, equals('plant-1'));
        },
      );
    });

    test('should get completed tasks', () async {
      // Arrange
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        completed: true,
        status: TaskStatus.completed,
      );
      final pendingTask = TestFixtures.createTestTask(
        id: 'task-2',
        completed: false,
        status: TaskStatus.pending,
      );
      await repository.addTask(completedTask);
      await repository.addTask(pendingTask);

      // Act
      final result = await repository.getCompletedTasks();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return tasks'),
        (tasks) {
          expect(tasks.length, equals(1));
          expect(tasks[0].status, equals(TaskStatus.completed));
        },
      );
    });

    test('should get pending tasks', () async {
      // Arrange
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        completed: true,
        status: TaskStatus.completed,
      );
      final pendingTask = TestFixtures.createTestTask(
        id: 'task-2',
        completed: false,
        status: TaskStatus.pending,
      );
      await repository.addTask(completedTask);
      await repository.addTask(pendingTask);

      // Act
      final result = await repository.getPendingTasks();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return tasks'),
        (tasks) {
          expect(tasks.length, equals(1));
          expect(tasks[0].status, equals(TaskStatus.pending));
        },
      );
    });

    test('should get overdue tasks', () async {
      // Arrange
      final yesterdayDate = DateTime.now().subtract(const Duration(days: 1));
      final tomorrowDate = DateTime.now().add(const Duration(days: 1));

      final overdueTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: yesterdayDate,
        completed: false,
      );
      final futureTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: tomorrowDate,
        completed: false,
      );
      await repository.addTask(overdueTask);
      await repository.addTask(futureTask);

      // Act
      final result = await repository.getOverdueTasks();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return tasks'),
        (tasks) {
          expect(tasks.length, equals(1));
          expect(tasks[0].dueDate.isBefore(DateTime.now()), true);
        },
      );
    });
  });
}
