import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../data/datasources/local/tasks_local_datasource.dart';
import '../../data/datasources/remote/tasks_remote_datasource.dart';
import '../../data/repositories/tasks_repository_impl.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../../domain/services/task_filter_service.dart';
import '../../domain/services/task_ownership_validator.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/get_task_by_id_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';

part 'tasks_providers.g.dart';

// Datasources
@riverpod
TasksLocalDataSource tasksLocalDataSource(Ref ref) {
  final driftRepo = ref.watch(tasksDriftRepositoryProvider);
  return TasksLocalDataSourceImpl(driftRepo);
}

@riverpod
TasksRemoteDataSource tasksRemoteDataSource(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  return TasksRemoteDataSourceImpl(firestore, rateLimiter: rateLimiter);
}

/// Provider for TasksRepository
@riverpod
TasksRepository tasksRepository(Ref ref) {
  final localDataSource = ref.watch(tasksLocalDataSourceProvider);
  final remoteDataSource = ref.watch(tasksRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final plantsRepository = ref.watch(plantsRepositoryProvider);

  return TasksRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
    authService: authRepository,
    plantsRepository: plantsRepository,
  );
}

/// Provider for GetTasksUseCase
@riverpod
GetTasksUseCase getTasksUseCase(Ref ref) {
  return GetTasksUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for GetTaskByIdUseCase
@riverpod
GetTaskByIdUseCase getTaskByIdUseCase(Ref ref) {
  return GetTaskByIdUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for AddTaskUseCase
@riverpod
AddTaskUseCase addTaskUseCase(Ref ref) {
  return AddTaskUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for CompleteTaskUseCase
@riverpod
CompleteTaskUseCase completeTaskUseCase(Ref ref) {
  return CompleteTaskUseCase(ref.watch(tasksRepositoryProvider));
}

/// Provider for TaskFilterService
@riverpod
ITaskFilterService taskFilterService(Ref ref) {
  return TaskFilterService();
}

/// Provider for TaskOwnershipValidator
@riverpod
ITaskOwnershipValidator taskOwnershipValidator(Ref ref) {
  return TaskOwnershipValidator(AuthStateNotifier.instance);
}
