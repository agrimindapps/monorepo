import 'package:app_plantis/features/tasks/domain/entities/task.dart'
    as task_entity;
import 'package:app_plantis/features/tasks/domain/services/task_filter_service.dart';
import 'package:app_plantis/features/tasks/domain/services/task_ownership_validator.dart';
import 'package:app_plantis/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:app_plantis/features/tasks/domain/usecases/complete_task_usecase.dart';
import 'package:app_plantis/features/tasks/presentation/notifiers/tasks_crud_notifier.dart';
import 'package:app_plantis/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:app_plantis/features/tasks/presentation/providers/tasks_state.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

// Mock use cases
class MockAddTaskUseCase extends Mock implements AddTaskUseCase {}

class MockCompleteTaskUseCase extends Mock implements CompleteTaskUseCase {}

class MockTaskFilterService extends Mock implements ITaskFilterService {}

class MockTaskOwnershipValidator extends Mock
    implements ITaskOwnershipValidator {}

// Fake classes
class _FakeTask extends Fake implements task_entity.Task {}

class _FakeAddTaskParams extends Fake implements AddTaskParams {}

class _FakeCompleteTaskParams extends Fake implements CompleteTaskParams {}

void main() {
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockCompleteTaskUseCase mockCompleteTaskUseCase;
  late MockTaskFilterService mockFilterService;
  late MockTaskOwnershipValidator mockOwnershipValidator;

  setUpAll(() {
    registerFallbackValue(_FakeTask());
    registerFallbackValue(_FakeAddTaskParams());
    registerFallbackValue(_FakeCompleteTaskParams());
  });

  setUp(() {
    mockAddTaskUseCase = MockAddTaskUseCase();
    mockCompleteTaskUseCase = MockCompleteTaskUseCase();
    mockFilterService = MockTaskFilterService();
    mockOwnershipValidator = MockTaskOwnershipValidator();
  });

  group('TasksCrudNotifier', () {
    test('build initializes with empty TasksState', () {
      final container = ProviderContainer(
        overrides: [
          addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
          completeTaskUseCaseProvider.overrideWithValue(
            mockCompleteTaskUseCase,
          ),
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          taskOwnershipValidatorProvider.overrideWithValue(
            mockOwnershipValidator,
          ),
        ],
      );
      final state = container.read(tasksCrudNotifierProvider);

      expect(state, equals(TasksState.initial()));
    });

    test('addTask should add task successfully', () async {
      final newTask = TestFixtures.createTestTask(
        id: 'new-task-1',
        title: 'New Task',
      );

      when(
        () => mockAddTaskUseCase(any()),
      ).thenAnswer((_) async => Right(newTask));

      final container = ProviderContainer(
        overrides: [
          addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
          completeTaskUseCaseProvider.overrideWithValue(
            mockCompleteTaskUseCase,
          ),
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          taskOwnershipValidatorProvider.overrideWithValue(
            mockOwnershipValidator,
          ),
        ],
      );

      final notifier = container.read(tasksCrudNotifierProvider.notifier);
      await notifier.addTask(newTask);

      verify(() => mockAddTaskUseCase(any())).called(1);
    });

    test('addTask handles repository failure', () async {
      const failure = ServerFailure('Failed to add task');
      final newTask = TestFixtures.createTestTask();

      when(
        () => mockAddTaskUseCase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final container = ProviderContainer(
        overrides: [
          addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
          completeTaskUseCaseProvider.overrideWithValue(
            mockCompleteTaskUseCase,
          ),
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          taskOwnershipValidatorProvider.overrideWithValue(
            mockOwnershipValidator,
          ),
        ],
      );

      final notifier = container.read(tasksCrudNotifierProvider.notifier);
      await notifier.addTask(newTask);

      verify(() => mockAddTaskUseCase(any())).called(1);
    });

    test('addTask validates task data', () async {
      final invalidTask = TestFixtures.createTestTask().copyWithTaskData(
        title: '', // Invalid - empty title
      );

      when(() => mockAddTaskUseCase(any())).thenAnswer(
        (_) async => const Left(ValidationFailure('Title cannot be empty')),
      );

      final container = ProviderContainer(
        overrides: [
          addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
          completeTaskUseCaseProvider.overrideWithValue(
            mockCompleteTaskUseCase,
          ),
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          taskOwnershipValidatorProvider.overrideWithValue(
            mockOwnershipValidator,
          ),
        ],
      );

      final notifier = container.read(tasksCrudNotifierProvider.notifier);
      await notifier.addTask(invalidTask);

      verify(() => mockAddTaskUseCase(any())).called(1);
    });

    test('completeTask marks task as completed', () async {
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        completed: true,
      );

      when(
        () => mockCompleteTaskUseCase(any()),
      ).thenAnswer((_) async => Right(completedTask));

      final container = ProviderContainer(
        overrides: [
          addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
          completeTaskUseCaseProvider.overrideWithValue(
            mockCompleteTaskUseCase,
          ),
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          taskOwnershipValidatorProvider.overrideWithValue(
            mockOwnershipValidator,
          ),
        ],
      );

      final notifier = container.read(tasksCrudNotifierProvider.notifier);
      await notifier.completeTask('task-1', notes: 'Completed!');

      verify(() => mockCompleteTaskUseCase(any())).called(1);
    });

    test('completeTask handles completion without notes', () async {
      final completedTask = TestFixtures.createTestTask(
        id: 'task-1',
        completed: true,
      );

      when(
        () => mockCompleteTaskUseCase(any()),
      ).thenAnswer((_) async => Right(completedTask));

      final container = ProviderContainer(
        overrides: [
          addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
          completeTaskUseCaseProvider.overrideWithValue(
            mockCompleteTaskUseCase,
          ),
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          taskOwnershipValidatorProvider.overrideWithValue(
            mockOwnershipValidator,
          ),
        ],
      );

      final notifier = container.read(tasksCrudNotifierProvider.notifier);
      await notifier.completeTask('task-1');

      verify(() => mockCompleteTaskUseCase(any())).called(1);
    });

    test(
      'completeTask with recurring task generates next occurrence',
      () async {
        final now = DateTime.now();
        final recurringTask = task_entity.Task(
          id: 'task-1',
          title: 'Water Plant',
          description: null,
          plantId: 'plant-1',
          type: task_entity.TaskType.watering,
          priority: task_entity.TaskPriority.medium,
          dueDate: now,
          status: task_entity.TaskStatus.completed,
          userId: 'user-1',
          createdAt: now,
          updatedAt: now,
          isDirty: false,
          isRecurring: true,
          recurringIntervalDays: 7, // weekly = 7 days
          completedAt: now,
        );

        when(
          () => mockCompleteTaskUseCase(any()),
        ).thenAnswer((_) async => Right(recurringTask));

        final container = ProviderContainer(
          overrides: [
            addTaskUseCaseProvider.overrideWithValue(mockAddTaskUseCase),
            completeTaskUseCaseProvider.overrideWithValue(
              mockCompleteTaskUseCase,
            ),
            taskFilterServiceProvider.overrideWithValue(mockFilterService),
            taskOwnershipValidatorProvider.overrideWithValue(
              mockOwnershipValidator,
            ),
          ],
        );

        final notifier = container.read(tasksCrudNotifierProvider.notifier);
        await notifier.completeTask('task-1');

        verify(() => mockCompleteTaskUseCase(any())).called(1);
      },
    );
  });
}
