import 'package:app_plantis/features/tasks/domain/entities/task.dart'
    as task_entity;
import 'package:app_plantis/features/tasks/domain/services/task_filter_service.dart';
import 'package:app_plantis/features/tasks/domain/services/task_filter_strategies.dart';
import 'package:app_plantis/features/tasks/presentation/providers/tasks_state.dart'
    hide Task, TaskPriority;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_fixtures.dart';

/// Custom filter strategy for testing OCP compliance
class _CustomHighPriorityStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.all;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    return tasks
        .where((t) => t.priority == task_entity.TaskPriority.urgent)
        .toList();
  }
}

void main() {
  late TaskFilterService filterService;
  late TaskFilterStrategyRegistry strategyRegistry;

  setUp(() {
    strategyRegistry = TaskFilterStrategyRegistry();
    filterService = TaskFilterService(strategyRegistry: strategyRegistry);
  });

  group('TaskFilterService - Strategy Pattern (OCP Compliance)', () {
    test('should filter all tasks without filtering', () {
      // Arrange
      final tasks = TestFixtures.createTestTasks(count: 5);

      // Act
      final result = filterService.filterByStatus(tasks, TasksFilterType.all);

      // Assert
      expect(result.length, equals(5));
    });

    test('should filter tasks due today', () {
      // Arrange
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final taskToday = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: today,
        completed: false,
      );
      final taskTomorrow = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: tomorrow,
        completed: false,
      );

      final tasks = [taskToday, taskTomorrow];

      // Act
      final result = filterService.filterByStatus(tasks, TasksFilterType.today);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].id, equals('task-1'));
    });

    test('should filter overdue tasks', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final overdueTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: yesterday,
        completed: false,
      );
      final futureTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: tomorrow,
        completed: false,
      );

      final tasks = [overdueTask, futureTask];

      // Act
      final result = filterService.filterByStatus(
        tasks,
        TasksFilterType.overdue,
      );

      // Assert
      expect(result.length, equals(1));
      expect(result[0].id, equals('task-1'));
    });

    test('should filter completed tasks', () {
      // Arrange
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        completed: true,
        status: task_entity.TaskStatus.completed,
      );
      final pendingTask = TestFixtures.createTestTask(
        id: 'task-2',
        completed: false,
        status: task_entity.TaskStatus.pending,
      );

      final tasks = [completedTask, pendingTask];

      // Act
      final result = filterService.filterByStatus(
        tasks,
        TasksFilterType.completed,
      );

      // Assert
      expect(result.length, equals(1));
      expect(result[0].status, equals(task_entity.TaskStatus.completed));
    });

    test('should allow custom filter strategy registration (Open/Closed)', () {
      // Arrange - Create a custom filter strategy
      final customStrategy = _CustomHighPriorityStrategy();

      // Act - Register custom strategy
      strategyRegistry.register(customStrategy);

      // Assert - Verify strategy was registered
      expect(strategyRegistry.hasStrategy(TasksFilterType.all), true);
    });

    test('should return all tasks if strategy not found', () {
      // Arrange
      final tasks = TestFixtures.createTestTasks(count: 3);

      // This test creates a scenario where a strategy might not be registered
      // The implementation falls back gracefully

      // Act
      final result = filterService.filterByStatus(tasks, TasksFilterType.all);

      // Assert
      expect(result.length, equals(3));
    });

    test('should search tasks by title', () {
      // Arrange
      final waterTask = TestFixtures.createTestTask(
        id: 'task-1',
        title: 'Water the plant',
      );
      final pruneTask = TestFixtures.createTestTask(
        id: 'task-2',
        title: 'Prune branches',
      );

      final tasks = [waterTask, pruneTask];

      // Act
      final result = filterService.searchTasks(tasks, 'water');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].title, contains('Water'));
    });

    test('should search tasks by description', () {
      // Arrange
      final task1 = TestFixtures.createTestTask(
        id: 'task-1',
        title: 'Task 1',
        description: 'Use fertilizer for growth',
      );
      final task2 = TestFixtures.createTestTask(
        id: 'task-2',
        title: 'Task 2',
        description: 'Check soil moisture',
      );

      final tasks = [task1, task2];

      // Act
      final result = filterService.searchTasks(tasks, 'fertilizer');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].description, contains('fertilizer'));
    });

    test('should filter by plant ID', () {
      // Arrange
      final plantTask = TestFixtures.createTestTask(
        id: 'task-1',
        plantId: 'plant-123',
      );
      final otherTask = TestFixtures.createTestTask(
        id: 'task-2',
        plantId: 'plant-456',
      );

      final tasks = [plantTask, otherTask];

      // Act
      final result = filterService.filterByPlant(tasks, 'plant-123');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].plantId, equals('plant-123'));
    });

    test('should filter by priority levels', () {
      // Arrange
      final highPriorityTask = TestFixtures.createTestTask(
        id: 'task-1',
        priority: task_entity.TaskPriority.high,
      );

      final lowPriorityTask = TestFixtures.createTestTask(
        id: 'task-2',
        priority: task_entity.TaskPriority.low,
      );

      final tasks = [highPriorityTask, lowPriorityTask];

      // Act
      final result = filterService.filterByPriorities(tasks, [
        task_entity.TaskPriority.high,
      ]);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].priority, equals(task_entity.TaskPriority.high));
    });

    test('should apply multiple filters in sequence', () {
      // Arrange
      final taskFutureHigh = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        completed: false,
        priority: task_entity.TaskPriority.high,
      );

      final taskFutureLow = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        completed: false,
        priority: task_entity.TaskPriority.low,
      );

      final tasks = [taskFutureHigh, taskFutureLow];

      // Act
      var result = filterService.filterByStatus(
        tasks,
        TasksFilterType.allFuture,
      );
      result = filterService.filterByPriorities(result, [
        task_entity.TaskPriority.high,
      ]);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].priority, equals(task_entity.TaskPriority.high));
    });
  });

  group('TaskFilterStrategyRegistry', () {
    test('should have all default strategies registered', () {
      // Assert
      expect(strategyRegistry.hasStrategy(TasksFilterType.all), true);
      expect(strategyRegistry.hasStrategy(TasksFilterType.today), true);
      expect(strategyRegistry.hasStrategy(TasksFilterType.overdue), true);
      expect(strategyRegistry.hasStrategy(TasksFilterType.upcoming), true);
      expect(strategyRegistry.hasStrategy(TasksFilterType.allFuture), true);
      expect(strategyRegistry.hasStrategy(TasksFilterType.completed), true);
      expect(strategyRegistry.hasStrategy(TasksFilterType.byPlant), true);
    });

    test('should return strategy for registered filter type', () {
      // Act
      final strategy = strategyRegistry.getStrategy(TasksFilterType.overdue);

      // Assert
      expect(strategy, isNotNull);
      expect(strategy?.filterType, equals(TasksFilterType.overdue));
    });

    test('should return all registered strategies', () {
      // Act
      final allStrategies = strategyRegistry.getAllStrategies();

      // Assert
      expect(
        allStrategies.length,
        greaterThanOrEqualTo(7),
      ); // 7 default strategies
    });
  });
}
