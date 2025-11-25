import 'package:app_plantis/features/tasks/domain/entities/task.dart' as task_entity;
import 'package:app_plantis/features/tasks/domain/services/task_filter_service.dart';
import 'package:app_plantis/features/tasks/presentation/notifiers/tasks_schedule_notifier.dart';
import 'package:app_plantis/features/tasks/presentation/providers/tasks_state.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

// Mock services
class MockTaskFilterService extends Mock implements ITaskFilterService {}

void main() {
  // late MockTaskFilterService mockFilterService;

  // setUp(() {
  //   mockFilterService = MockTaskFilterService();
  // });

  group('TasksScheduleNotifier', () {
    test('build initializes with empty TasksState', () {
      final container = ProviderContainer();
      final state = container.read(tasksScheduleNotifierProvider);

      expect(state, equals(TasksStateX.initial()));
    });

    test('updateTasksState updates internal state', () {
      final tasks = TestFixtures.createTestTasks(count: 3);
      final newState = TasksState(
        allTasks: tasks,
        filteredTasks: tasks,
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);
      notifier.updateTasksState(newState);

      final currentState = container.read(tasksScheduleNotifierProvider);
      expect(currentState.allTasks.length, 3);
    });

    test('getOverdueTasks returns tasks past due date', () {
      final overdueTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        completed: false,
      );
      final upcomingTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        completed: false,
      );

      final state = TasksState(
        allTasks: [overdueTask, upcomingTask],
        filteredTasks: [overdueTask, upcomingTask],
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);
      notifier.updateTasksState(state);

      final overdueTasks = notifier.getOverdueTasks();
      expect(overdueTasks.length, 1);
      expect(overdueTasks.first.id, 'task-1');
    });

    test('getOverdueTasks excludes completed tasks', () {
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        completed: true,
      );

      final state = TasksState(
        allTasks: [completedTask],
        filteredTasks: [completedTask],
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);
      notifier.updateTasksState(state);

      final overdueTasks = notifier.getOverdueTasks();
      expect(overdueTasks.length, 0);
    });

    test('getTodayTasks returns tasks due today', () {
      final now = DateTime.now();
      final todayTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: now,
        completed: false,
      );
      final tomorrowTask = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: now.add(const Duration(days: 1)),
        completed: false,
      );

      final state = TasksState(
        allTasks: [todayTask, tomorrowTask],
        filteredTasks: [todayTask, tomorrowTask],
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);
      notifier.updateTasksState(state);

      final todayTasks = notifier.getTodayTasks();
      expect(todayTasks.length, 1);
      expect(todayTasks.first.id, 'task-1');
    });

    test('getUpcomingTasks returns tasks within specified days', () {
      final now = DateTime.now();
      final task1 = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: now.add(const Duration(days: 3)),
        completed: false,
      );
      final task2 = TestFixtures.createTestTask(
        id: 'task-2',
        dueDate: now.add(const Duration(days: 10)),
        completed: false,
      );

      final state = TasksState(
        allTasks: [task1, task2],
        filteredTasks: [task1, task2],
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);
      notifier.updateTasksState(state);

      final upcomingTasks = notifier.getUpcomingTasks(days: 7);
      expect(upcomingTasks.length, 1);
      expect(upcomingTasks.first.id, 'task-1');
    });

    test('generateNextRecurringTask creates next occurrence', () {
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        dueDate: DateTime.now(),
        completed: true,
      );
      
      // Create a version with recurring enabled
      final recurringTask = task_entity.Task(
        id: completedTask.id,
        title: completedTask.title,
        description: completedTask.description,
        plantId: completedTask.plantId,
        type: completedTask.type,
        priority: completedTask.priority,
        dueDate: completedTask.dueDate,
        status: task_entity.TaskStatus.completed,
        userId: completedTask.userId,
        createdAt: completedTask.createdAt,
        updatedAt: completedTask.updatedAt,
        isDirty: completedTask.isDirty,
        isRecurring: true,
        recurringIntervalDays: 7, // weekly = 7 days
        completedAt: DateTime.now(),
        completionNotes: 'Done',
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);

      final nextTask = notifier.generateNextRecurringTask(recurringTask);

      expect(nextTask, isNotNull);
      expect(nextTask!.status, task_entity.TaskStatus.pending);
      expect(nextTask.isDirty, true);
    });

    test('generateNextRecurringTask returns null for non-recurring tasks', () {
      final task = TestFixtures.createTestTask(
        id: 'task-1',
        completed: true,
      );

      final container = ProviderContainer();
      final notifier = container.read(tasksScheduleNotifierProvider.notifier);

      final nextTask = notifier.generateNextRecurringTask(task);
      expect(nextTask, isNull);
    });
  });
}
