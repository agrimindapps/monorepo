import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTasksRepository mockTasksRepository;
  late DeleteTaskUseCase deleteTaskUseCase;

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
    deleteTaskUseCase = DeleteTaskUseCase(mockTasksRepository);
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('DeleteTaskUseCase', () {
    test('should delete task successfully', () async {
      // Arrange
      const taskId = 'task-1';

      when(
        () => mockTasksRepository.deleteTask(taskId),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await deleteTaskUseCase(
        const DeleteTaskParams(taskId: taskId),
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockTasksRepository.deleteTask(taskId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const taskId = 'task-1';

      when(
        () => mockTasksRepository.deleteTask(taskId),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro ao deletar')));

      // Act
      final result = await deleteTaskUseCase(
        const DeleteTaskParams(taskId: taskId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('deletar')),
        (_) => fail('Should return failure'),
      );
    });

    test('should validate task ID not empty', () async {
      // Act
      final result = await deleteTaskUseCase(
        const DeleteTaskParams(taskId: ''),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('ID'));
      }, (_) => fail('Should return validation failure'));
      verifyNever(() => mockTasksRepository.deleteTask(any()));
    });

    test('should handle network failures', () async {
      // Arrange
      const taskId = 'task-1';

      when(
        () => mockTasksRepository.deleteTask(taskId),
      ).thenAnswer((_) async => const Left(NetworkFailure('Sem conexão')));

      // Act
      final result = await deleteTaskUseCase(
        const DeleteTaskParams(taskId: taskId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('conexão'));
      }, (_) => fail('Should return network failure'));
    });

    test('should handle cache failures', () async {
      // Arrange
      const taskId = 'task-1';

      when(
        () => mockTasksRepository.deleteTask(taskId),
      ).thenAnswer((_) async => const Left(CacheFailure('Erro no cache')));

      // Act
      final result = await deleteTaskUseCase(
        const DeleteTaskParams(taskId: taskId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return cache failure'),
      );
    });
  });
}
