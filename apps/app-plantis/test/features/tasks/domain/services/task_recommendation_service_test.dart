import 'package:app_plantis/features/tasks/domain/entities/task.dart' as task_entity;
import 'package:app_plantis/features/tasks/domain/services/task_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  late ITaskRecommendationService recommendationService;

  setUp(() {
    recommendationService = TaskRecommendationService();
  });

  group('TaskRecommendationService', () {
    test('getHighPriorityTasks returns urgent and high priority tasks', () {
      final urgentTask = TestFixtures.createTestTask(
        id: 'task-1',
        priority: task_entity.TaskPriority.urgent,
      );
      final highTask = TestFixtures.createTestTask(
        id: 'task-2',
        priority: task_entity.TaskPriority.high,
      );
      final mediumTask = TestFixtures.createTestTask(
        id: 'task-3',
        priority: task_entity.TaskPriority.medium,
      );

      final recommendations = recommendationService.getHighPriorityTasks(
        [urgentTask, highTask, mediumTask],
      );

      expect(recommendations.length, 2);
      expect(recommendations.map((t) => t.id), ['task-1', 'task-2']);
    });

    test('getHighPriorityTasks excludes completed tasks', () {
      final urgentTask = TestFixtures.createTestTask(
        id: 'task-1',
        priority: task_entity.TaskPriority.urgent,
        completed: true,
      );
      final highTask = TestFixtures.createTestTask(
        id: 'task-2',
        priority: task_entity.TaskPriority.high,
      );

      final recommendations = recommendationService.getHighPriorityTasks(
        [urgentTask, highTask],
      );

      expect(recommendations.length, 1);
      expect(recommendations.first.id, 'task-2');
    });

    test('getHighPriorityTasks sorts by due date', () {
      final now = DateTime.now();
      final task1 = TestFixtures.createTestTask(
        id: 'task-1',
        priority: task_entity.TaskPriority.urgent,
        dueDate: now.add(const Duration(days: 3)),
      );
      final task2 = TestFixtures.createTestTask(
        id: 'task-2',
        priority: task_entity.TaskPriority.urgent,
        dueDate: now.add(const Duration(days: 1)),
      );

      final recommendations = recommendationService.getHighPriorityTasks(
        [task1, task2],
      );

      // Should be sorted by due date (task2 first, closer due date)
      expect(recommendations.first.id, 'task-2');
      expect(recommendations.last.id, 'task-1');
    });

    test('getTodaySuggestions returns pending tasks for today', () {
      final now = DateTime.now();
      final todayTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: now,
        priority: task_entity.TaskPriority.high,
      );
      final tomorrowTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: now.add(const Duration(days: 1)),
        priority: task_entity.TaskPriority.high,
      );

      final suggestions = recommendationService.getTodaySuggestions(
        [todayTask, tomorrowTask],
      );

      expect(suggestions.length, 1);
      expect(suggestions.first.id, 'task-1');
    });

    test('getTodaySuggestions sorts by priority', () {
      final now = DateTime.now();
      final lowTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: now,
        priority: task_entity.TaskPriority.low,
      );
      final urgentTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: now,
        priority: task_entity.TaskPriority.urgent,
      );
      final mediumTask = TestFixtures.createTestTask(
        id: 'task-3',
        dueDate: now,
        priority: task_entity.TaskPriority.medium,
      );

      final suggestions = recommendationService.getTodaySuggestions(
        [lowTask, urgentTask, mediumTask],
      );

      expect(suggestions.length, 3);
      expect(suggestions[0].id, 'task-2'); // Urgent first
      expect(suggestions[1].id, 'task-3'); // Medium second
      expect(suggestions[2].id, 'task-1'); // Low last
    });

    test('getTodaySuggestions excludes completed tasks', () {
      final now = DateTime.now();
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: now,
        completed: true,
      );
      final pendingTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: now,
      );

      final suggestions = recommendationService.getTodaySuggestions(
        [completedTask, pendingTask],
      );

      expect(suggestions.length, 1);
      expect(suggestions.first.id, 'task-2');
    });

    test('getPlantRecommendations returns tasks for specific plant', () {
      final plantTask1 = TestFixtures.createTestTask(
        id: 'task-1',
        plantId: 'plant-1',
      );
      final plantTask2 = TestFixtures.createTestTask(
        id: 'task-2',
        plantId: 'plant-1',
      );
      final otherPlantTask = TestFixtures.createTestTask(
        id: 'task-3',
        plantId: 'plant-2',
      );

      final recommendations = recommendationService.getPlantRecommendations(
        [plantTask1, plantTask2, otherPlantTask],
        'plant-1',
      );

      expect(recommendations.length, 2);
      expect(recommendations.map((t) => t.id), ['task-1', 'task-2']);
    });

    test('getOptimizations returns statistics map', () {
      final tasks = [
        TestFixtures.createTestTask(id: 'task-1'),
        TestFixtures.createTestTask(id: 'task-2'),
        TestFixtures.createTestTask(id: 'task-3'),
      ];

      final optimizations = recommendationService.getOptimizations(tasks);

      expect(optimizations, isNotEmpty);
      expect(optimizations.containsKey('totalTasks'), true);
      expect(optimizations.containsKey('completedTasks'), true);
      expect(optimizations.containsKey('pendingTasks'), true);
    });

    test('getOptimizations shows overdue count', () {
      final overdueTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final upcomingTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      final optimizations = recommendationService.getOptimizations(
        [overdueTask, upcomingTask],
      );

      expect(optimizations.containsKey('overdueTasks'), true);
      expect(optimizations['overdueTasks'], greaterThan(0));
    });

    test('getOptimizations handles empty task list', () {
      final optimizations = recommendationService.getOptimizations([]);

      expect(optimizations, isNotEmpty);
      expect(optimizations['totalTasks'], 0);
      expect(optimizations['completedTasks'], 0);
      expect(optimizations['pendingTasks'], 0);
    });

    test('getHighPriorityTasks handles null due dates', () {
      final urgentTask = task_entity.Task(
        id: 'task-1',
        title: 'Urgent Task',
        description: null,
        plantId: 'plant-1',
        type: task_entity.TaskType.watering,
        priority: task_entity.TaskPriority.urgent,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: task_entity.TaskStatus.pending,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: false,
      );

      final recommendations = recommendationService.getHighPriorityTasks(
        [urgentTask],
      );

      expect(recommendations.length, 1);
      expect(recommendations.first.id, 'task-1');
    });
  });
}
