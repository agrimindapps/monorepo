import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockTasksRepository mockTasksRepository;
  late GetTasksUseCase getTasksUseCase;

  setUpAll(() {
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
    getTasksUseCase = GetTasksUseCase(mockTasksRepository);
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('GetTasksUseCase', () {
    test('should return list of tasks successfully', () async {
      // Arrange
      final tasks = [
        TestFixtures.createTestTask(id: 'task-1', title: 'Regar plantas'),
        TestFixtures.createTestTask(id: 'task-2', title: 'Podar folhas'),
        TestFixtures.createTestTask(id: 'task-3', title: 'Fertilizar solo'),
      ];

      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => Right(tasks));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (taskList) {
        expect(taskList.length, 3);
        expect(taskList[0].title, 'Regar plantas');
        expect(taskList[1].title, 'Podar folhas');
        expect(taskList[2].title, 'Fertilizar solo');
      });
      verify(() => mockTasksRepository.getTasks()).called(1);
    });

    test('should return empty list when no tasks exist', () async {
      // Arrange
      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (taskList) => expect(taskList, isEmpty),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro no servidor')));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('servidor')),
        (_) => fail('Should return failure'),
      );
    });

    test('should handle network failures', () async {
      // Arrange
      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => const Left(NetworkFailure('Sem conexão')));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('conexão'));
      }, (_) => fail('Should return network failure'));
    });

    test('should return tasks with recurring information', () async {
      // Arrange
      final tasks = [
        TestFixtures.createTestTask(
          id: 'task-1',
          title: 'Regar plantas',
          isRecurring: true,
          recurringIntervalDays: 7,
        ),
        TestFixtures.createTestTask(
          id: 'task-2',
          title: 'Fertilizar',
          isRecurring: false,
        ),
      ];

      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => Right(tasks));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (taskList) {
        expect(taskList[0].isRecurring, true);
        expect(taskList[0].recurringIntervalDays, 7);
        expect(taskList[1].isRecurring, false);
      });
    });

    test('should return tasks with different statuses', () async {
      // Arrange
      final tasks = [
        TestFixtures.createTestTask(id: 'task-1', status: TaskStatus.pending),
        TestFixtures.createTestTask(id: 'task-2', status: TaskStatus.completed),
        TestFixtures.createTestTask(id: 'task-3', status: TaskStatus.overdue),
      ];

      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => Right(tasks));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (taskList) {
        expect(taskList[0].status, TaskStatus.pending);
        expect(taskList[1].status, TaskStatus.completed);
        expect(taskList[2].status, TaskStatus.overdue);
      });
    });

    test('should return tasks with different priorities', () async {
      // Arrange
      final tasks = [
        TestFixtures.createTestTask(id: 'task-1', priority: TaskPriority.high),
        TestFixtures.createTestTask(
          id: 'task-2',
          priority: TaskPriority.medium,
        ),
        TestFixtures.createTestTask(id: 'task-3', priority: TaskPriority.low),
      ];

      when(
        () => mockTasksRepository.getTasks(),
      ).thenAnswer((_) async => Right(tasks));

      // Act
      final result = await getTasksUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (taskList) {
        expect(taskList[0].priority, TaskPriority.high);
        expect(taskList[1].priority, TaskPriority.medium);
        expect(taskList[2].priority, TaskPriority.low);
      });
    });
  });
}
