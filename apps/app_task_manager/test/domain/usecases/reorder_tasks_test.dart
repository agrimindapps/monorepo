import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:app_task_manager/domain/usecases/reorder_tasks.dart';
import 'package:app_task_manager/domain/repositories/task_repository.dart';
import 'package:app_task_manager/core/errors/failures.dart';

import 'reorder_tasks_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late ReorderTasks usecase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    usecase = ReorderTasks(mockTaskRepository);
  });

  const tTaskIds = ['task1', 'task2', 'task3'];

  test('should call repository reorderTasks with correct parameters', () async {
    // arrange
    when(mockTaskRepository.reorderTasks(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(const ReorderTasksParams(taskIds: tTaskIds));

    // assert
    expect(result, const Right(null));
    verify(mockTaskRepository.reorderTasks(tTaskIds));
    verifyNoMoreInteractions(mockTaskRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = ServerFailure('Server Failure');
    when(mockTaskRepository.reorderTasks(any))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const ReorderTasksParams(taskIds: tTaskIds));

    // assert
    expect(result, const Left(tFailure));
    verify(mockTaskRepository.reorderTasks(tTaskIds));
    verifyNoMoreInteractions(mockTaskRepository);
  });
}