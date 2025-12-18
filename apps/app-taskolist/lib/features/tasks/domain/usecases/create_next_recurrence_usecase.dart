import 'package:core/core.dart' hide Failure, ValidationFailure;
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../task_entity.dart';
import '../task_repository.dart';

/// Use case to create the next occurrence of a recurring task
/// 
/// When a recurring task is completed, this creates the next instance
/// with the same properties but updated due date.
class CreateNextRecurrenceUseCase {
  final TaskRepository _repository;

  CreateNextRecurrenceUseCase(this._repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity completedTask) async {
    // Validate task is recurring
    if (!completedTask.isRecurring) {
      return Left(ValidationFailure('Task is not recurring'));
    }

    // Get next occurrence date
    final nextDate = completedTask.nextOccurrence;
    if (nextDate == null) {
      return Left(ValidationFailure('No more occurrences for this task'));
    }

    // Create new task with same properties but new dates
    final nextTask = completedTask.copyWith(
      id: const Uuid().v4(), // New ID
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastSyncAt: null,
      isDirty: true,
      status: TaskStatus.pending, // Reset to pending
      dueDate: nextDate,
      reminderDate: completedTask.reminderDate != null
          ? nextDate.subtract(
              completedTask.dueDate!.difference(completedTask.reminderDate!),
            )
          : null,
    );

    // Save next occurrence
    final result = await _repository.createTask(nextTask);
    return result.fold(
      (failure) => Left(failure),
      (taskId) async {
        // TODO: Implementar getTaskById no repository
        return Left(DatabaseFailure('getTaskById not implemented yet'));
      },
    );
  }
}
