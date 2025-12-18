import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/tasks/domain/entities/task.dart'
    as task_entity;
import 'package:app_plantis/features/tasks/domain/usecases/complete_task_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockTasksRepository mockTasksRepository;
  late CompleteTaskUseCase completeTaskUseCase;

  setUpAll(() {
    registerFallbackValue(TestFixtures.createTestTask());

    final testUser = UserEntity(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );
    AuthStateNotifier.instance.updateUser(testUser);
  });

  setUp(() {
    mockTasksRepository = MockTasksRepository();
    completeTaskUseCase = CompleteTaskUseCase(mockTasksRepository);
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('CompleteTaskUseCase', () {
    test('should complete task successfully', () async {
      // Arrange
      final task = TestFixtures.createTestTask(id: 'task-1');
      final completedTask = task.copyWithTaskData(
        status: task_entity.TaskStatus.completed,
        completedAt: DateTime.now(),
      );

      when(
        () => mockTasksRepository.completeTask(
          task.id,
          notes: null,
          nextDueDate: null,
        ),
      ).thenAnswer((_) async => Right(completedTask));

      // Act
      final result = await completeTaskUseCase(
        CompleteTaskParams(taskId: task.id),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (completedTask) {
        expect(completedTask.status, task_entity.TaskStatus.completed);
        expect(completedTask.completedAt, isNotNull);
      });
      verify(
        () => mockTasksRepository.completeTask(
          task.id,
          notes: null,
          nextDueDate: null,
        ),
      ).called(1);
    });

    test('should complete task with notes', () async {
      // Arrange
      final task = TestFixtures.createTestTask(id: 'task-1');
      const notes = 'Concluída com sucesso';
      final completedTask = task.copyWithTaskData(
        status: task_entity.TaskStatus.completed,
        completedAt: DateTime.now(),
        completionNotes: notes,
      );

      when(
        () => mockTasksRepository.completeTask(
          task.id,
          notes: notes,
          nextDueDate: null,
        ),
      ).thenAnswer((_) async => Right(completedTask));

      // Act
      final result = await completeTaskUseCase(
        CompleteTaskParams(taskId: task.id, notes: notes),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (task) => expect(task.completionNotes, notes),
      );
    });

    test(
      'should complete recurring task and generate next occurrence',
      () async {
        // Arrange
        final recurringTask = TestFixtures.createTestTask(
          id: 'task-1',
        ).copyWithTaskData(isRecurring: true, recurringIntervalDays: 7);
        final completedTask = recurringTask.copyWithTaskData(
          status: task_entity.TaskStatus.completed,
          completedAt: DateTime.now(),
        );

        when(
          () => mockTasksRepository.completeTask(
            recurringTask.id,
            notes: null,
            nextDueDate: null,
          ),
        ).thenAnswer((_) async => Right(completedTask));

        // Act
        final result = await completeTaskUseCase(
          CompleteTaskParams(taskId: recurringTask.id),
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return success'), (task) {
          expect(task.status, task_entity.TaskStatus.completed);
          expect(task.isRecurring, true);
        });
      },
    );

    test(
      'should complete task with custom next due date for recurring',
      () async {
        // Arrange
        final recurringTask = TestFixtures.createTestTask(
          id: 'task-1',
        ).copyWithTaskData(isRecurring: true, recurringIntervalDays: 7);
        final nextDueDate = DateTime.now().add(const Duration(days: 14));
        final completedTask = recurringTask.copyWithTaskData(
          status: task_entity.TaskStatus.completed,
          completedAt: DateTime.now(),
        );

        when(
          () => mockTasksRepository.completeTask(
            recurringTask.id,
            notes: null,
            nextDueDate: nextDueDate,
          ),
        ).thenAnswer((_) async => Right(completedTask));

        // Act
        final result = await completeTaskUseCase(
          CompleteTaskParams(
            taskId: recurringTask.id,
            nextDueDate: nextDueDate,
          ),
        );

        // Assert
        expect(result.isRight(), true);
        verify(
          () => mockTasksRepository.completeTask(
            recurringTask.id,
            notes: null,
            nextDueDate: nextDueDate,
          ),
        ).called(1);
      },
    );

    test('should return failure when repository fails', () async {
      // Arrange
      const taskId = 'task-1';

      when(
        () => mockTasksRepository.completeTask(
          taskId,
          notes: null,
          nextDueDate: null,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro ao completar')));

      // Act
      final result = await completeTaskUseCase(
        CompleteTaskParams(taskId: taskId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('completar')),
        (_) => fail('Should return failure'),
      );
    });

    test('should validate task ID not empty', () async {
      // Act
      final result = await completeTaskUseCase(CompleteTaskParams(taskId: ''));

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('ID'));
      }, (_) => fail('Should return validation failure'));
      verifyNever(
        () => mockTasksRepository.completeTask(
          any(),
          notes: any(),
          nextDueDate: any(),
        ),
      );
    });

    test(
      'should validate nextDueDate is in the future for recurring tasks',
      () async {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 1));

        // Act
        final result = await completeTaskUseCase(
          CompleteTaskParams(taskId: 'task-1', nextDueDate: pastDate),
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('futuro'));
        }, (_) => fail('Should return validation failure'));
      },
    );
  });
}
