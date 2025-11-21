import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/services/services_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
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
TasksLocalDataSource tasksLocalDataSource(TasksLocalDataSourceRef ref) {
  final driftRepo = ref.watch(tasksDriftRepositoryProvider);
  return TasksLocalDataSourceImpl(driftRepo);
}

@riverpod
TasksRemoteDataSource tasksRemoteDataSource(TasksRemoteDataSourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  return TasksRemoteDataSourceImpl(firestore, rateLimiter: rateLimiter);
}

/// Provider for TasksRepository
@riverpod
TasksRepository tasksRepository(TasksRepositoryRef ref) {
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
