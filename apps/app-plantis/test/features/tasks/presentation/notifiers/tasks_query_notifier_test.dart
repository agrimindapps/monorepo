import 'package:app_plantis/features/tasks/domain/services/task_filter_service.dart';
import 'package:app_plantis/features/tasks/presentation/notifiers/tasks_query_notifier.dart';
import 'package:app_plantis/features/tasks/presentation/providers/tasks_state.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

// Mock services
class MockTaskFilterService extends Mock implements ITaskFilterService {}

void main() {
  late MockTaskFilterService mockFilterService;

  setUpAll(() {
    registerFallbackValue(TasksFilterType.all);
  });

  setUp(() {
    mockFilterService = MockTaskFilterService();
  });

  group('TasksQueryNotifier', () {
    test('build initializes with empty TasksState', () {
      final container = ProviderContainer();
      final state = container.read(tasksQueryNotifierProvider);

      expect(state, equals(TasksStateX.initial()));
    });

    test('searchTasks filters by query string', () {
      final tasks = TestFixtures.createTestTasks(count: 3);
      final initialState = TasksState(
        allTasks: tasks,
        filteredTasks: tasks,
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer(
        overrides: [
          // taskFilterServiceProvider.overrideWithValue(mockFilterService),
        ],
      );

      // Mock filter service to return filtered results
      when(
        () => mockFilterService.applyFilters(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn([tasks[0]]);

      final notifier = container.read(tasksQueryNotifierProvider.notifier);

      // Set initial state
      notifier.loadTasksState(initialState);
      notifier.searchTasks('Water');

      verify(
        () => mockFilterService.applyFilters(
          any(),
          any(),
          'Water',
          any(),
          any(),
          any(),
        ),
      ).called(1);
    });

    test('setFilter updates filter state correctly', () {
      final tasks = TestFixtures.createTestTasks(count: 3);
      final initialState = TasksState(
        allTasks: tasks,
        filteredTasks: tasks,
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer(
        overrides: [
          // taskFilterServiceProvider.overrideWithValue(mockFilterService),
        ],
      );

      when(
        () => mockFilterService.applyFilters(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn([tasks[0]]);

      final notifier = container.read(tasksQueryNotifierProvider.notifier);
      notifier.loadTasksState(initialState);
      notifier.setFilter(TasksFilterType.today);

      final currentState = container.read(tasksQueryNotifierProvider);
      expect(currentState.currentFilter, TasksFilterType.today);
    });

    test('setPlantFilter filters by plant ID', () {
      final tasks = TestFixtures.createTestTasks(count: 3);
      final initialState = TasksState(
        allTasks: tasks,
        filteredTasks: tasks,
        searchQuery: '',
        currentFilter: TasksFilterType.all,
        selectedPlantId: null,
        selectedTaskTypes: const [],
        selectedPriorities: const [],
        isLoading: false,
      );

      final container = ProviderContainer(
        overrides: [
          // taskFilterServiceProvider.overrideWithValue(mockFilterService),
        ],
      );

      when(
        () => mockFilterService.applyFilters(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn([tasks[0]]);

      final notifier = container.read(tasksQueryNotifierProvider.notifier);
      notifier.loadTasksState(initialState);
      notifier.setPlantFilter('plant-1');

      final currentState = container.read(tasksQueryNotifierProvider);
      expect(currentState.selectedPlantId, 'plant-1');
    });

    test('loadTasksState updates state from parent notifier', () {
      final tasks = TestFixtures.createTestTasks(count: 2);
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
      final notifier = container.read(tasksQueryNotifierProvider.notifier);

      notifier.loadTasksState(newState);

      final currentState = container.read(tasksQueryNotifierProvider);
      expect(currentState.allTasks.length, 2);
      expect(currentState.filteredTasks.length, 2);
    });
  });
}
