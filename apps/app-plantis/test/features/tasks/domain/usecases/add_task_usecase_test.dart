import 'package:app_plantis/features/tasks/domain/entities/task.dart' as task_entity;
import 'package:app_plantis/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockTasksRepository mockTasksRepository;
  late AddTaskUseCase addTaskUseCase;

  setUp(() {
    mockTasksRepository = MockTasksRepository();
    addTaskUseCase = AddTaskUseCase(mockTasksRepository);

    registerFallbackValue(
      task_entity.Task(
        id: 'test',
        title: 'Test',
        dueDate: DateTime.now(),
        plantId: 'plant-1',
        type: task_entity.TaskType.watering,
        userId: 'test-user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: false,
      ),
    );
  });

  group('AddTaskUseCase', () {
    test('should return Right with Task when repository returns success',
        () async {
      // Arrange
      final testTask = TestFixtures.createTestTask(
        title: 'Water Plant',
      );

      when(() => mockTasksRepository.addTask(any()))
          .thenAnswer((_) async => Right(testTask));

      final params = AddTaskParams(task: testTask);

      // Act
      final result = await addTaskUseCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (task) {
          expect(task.title, equals('Water Plant'));
          expect(task.id, equals(testTask.id));
        },
      );

      verify(() => mockTasksRepository.addTask(any())).called(1);
    });

    test('should return Left when repository fails with server error',
        () async {
      // Arrange
      final testTask = TestFixtures.createTestTask();

      when(() => mockTasksRepository.addTask(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Database error')),
      );

      final params = AddTaskParams(task: testTask);

      // Act
      final result = await addTaskUseCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database error'));
        },
        (_) => fail('Should return failure'),
      );

      verify(() => mockTasksRepository.addTask(any())).called(1);
    });

    test('should return Left when repository fails with network error',
        () async {
      // Arrange
      final testTask = TestFixtures.createTestTask();

      when(() => mockTasksRepository.addTask(any())).thenAnswer(
        (_) async => const Left(NetworkFailure('No internet')),
      );

      final params = AddTaskParams(task: testTask);

      // Act
      final result = await addTaskUseCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Should return failure'),
      );

      verify(() => mockTasksRepository.addTask(any())).called(1);
    });

    test('should pass exact task to repository', () async {
      // Arrange
      final testTask = TestFixtures.createTestTask(
        title: 'Specific Task',
        description: 'Specific Description',
      );

      when(() => mockTasksRepository.addTask(any()))
          .thenAnswer((_) async => Right(testTask));

      final params = AddTaskParams(task: testTask);

      // Act
      await addTaskUseCase(params);

      // Assert
      verify(() => mockTasksRepository.addTask(testTask)).called(1);
    });

    test('should handle multiple task additions sequentially', () async {
      // Arrange
      final task1 = TestFixtures.createTestTask(id: 'task-1', title: 'Task 1');
      final task2 = TestFixtures.createTestTask(id: 'task-2', title: 'Task 2');

      when(() => mockTasksRepository.addTask(task1))
          .thenAnswer((_) async => Right(task1));
      when(() => mockTasksRepository.addTask(task2))
          .thenAnswer((_) async => Right(task2));

      // Act
      final result1 = await addTaskUseCase(AddTaskParams(task: task1));
      final result2 = await addTaskUseCase(AddTaskParams(task: task2));

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      verify(() => mockTasksRepository.addTask(any())).called(2);
    });

    test('should maintain task properties through usecase call', () async {
      // Arrange
      final dueDate = DateTime(2025, 12, 31);
      final testTask = TestFixtures.createTestTask(
        title: 'Important Task',
        dueDate: dueDate,
        plantId: 'plant-123',
      );

      when(() => mockTasksRepository.addTask(any()))
          .thenAnswer((_) async => Right(testTask));

      final params = AddTaskParams(task: testTask);

      // Act
      final result = await addTaskUseCase(params);

      // Assert
      result.fold(
        (_) => fail('Should return success'),
        (task) {
          expect(task.title, equals('Important Task'));
          expect(task.dueDate, equals(dueDate));
          expect(task.plantId, equals('plant-123'));
        },
      );
    });
  });
}
