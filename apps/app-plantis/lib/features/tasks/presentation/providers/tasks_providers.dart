import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../../domain/services/task_filter_service.dart';
import '../../domain/services/task_ownership_validator.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/get_task_by_id_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';

part 'tasks_providers.g.dart';

/// Provider for TasksRepository from dependency injection
@riverpod
TasksRepository tasksRepository(TasksRepositoryRef ref) {
  return getIt<TasksRepository>();
}

/// Provider for GetTasksUseCase
@riverpod
GetTasksUseCase getTasksUseCase(GetTasksUseCaseRef ref) {
  return GetTasksUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for GetTaskByIdUseCase
@riverpod
GetTaskByIdUseCase getTaskByIdUseCase(GetTaskByIdUseCaseRef ref) {
  return GetTaskByIdUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for AddTaskUseCase
@riverpod
AddTaskUseCase addTaskUseCase(AddTaskUseCaseRef ref) {
  return AddTaskUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for CompleteTaskUseCase
@riverpod
CompleteTaskUseCase completeTaskUseCase(CompleteTaskUseCaseRef ref) {
  return CompleteTaskUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for TaskFilterService
@riverpod
ITaskFilterService taskFilterService(TaskFilterServiceRef ref) {
  return TaskFilterService();
}

/// Provider for TaskOwnershipValidator
@riverpod
ITaskOwnershipValidator taskOwnershipValidator(TaskOwnershipValidatorRef ref) {
  return TaskOwnershipValidator(AuthStateNotifier.instance);
}
