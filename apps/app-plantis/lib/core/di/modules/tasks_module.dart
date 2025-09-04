import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

import '../../../features/tasks/data/datasources/local/tasks_local_datasource.dart';
import '../../../features/tasks/data/datasources/remote/tasks_remote_datasource.dart';
// Data
import '../../../features/tasks/data/repositories/tasks_repository_impl.dart';
// Domain
import '../../../features/tasks/domain/repositories/tasks_repository.dart';
import '../../../features/tasks/domain/usecases/add_task_usecase.dart';
import '../../../features/tasks/domain/usecases/complete_task_usecase.dart';
import '../../../features/tasks/domain/usecases/complete_task_with_regeneration_usecase.dart';
import '../../../features/tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../../features/tasks/domain/usecases/update_task_usecase.dart';
// Presentation
import '../../../features/tasks/presentation/providers/tasks_provider.dart';
// Core services
import '../../services/task_generation_service.dart';

class TasksModule {
  static void init(GetIt sl) {
    // Presentation Layer
    sl.registerFactory(
      () => TasksProvider(
        getTasksUseCase: sl(),
        addTaskUseCase: sl(),
        completeTaskUseCase: sl(),
        // AuthStateNotifier will be accessed as singleton, no DI needed
      ),
    );

    // Services
    sl.registerLazySingleton(() => TaskGenerationService());

    // Use Cases
    sl.registerLazySingleton(() => GetTasksUseCase(sl()));
    sl.registerLazySingleton(() => AddTaskUseCase(sl()));
    sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
    sl.registerLazySingleton(() => CompleteTaskUseCase(sl()));
    sl.registerLazySingleton(
      () => GenerateInitialTasksUseCase(
        tasksRepository: sl(),
        taskGenerationService: sl(),
      ),
    );
    sl.registerLazySingleton(
      () => CompleteTaskWithRegenerationUseCase(
        tasksRepository: sl(),
        plantsRepository: sl(),
        taskGenerationService: sl(),
      ),
    );

    // Repository
    sl.registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
        authService: sl(),
      ),
    );

    // Data Sources
    sl.registerLazySingleton<TasksRemoteDataSource>(
      () => TasksRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<TasksLocalDataSource>(
      () => TasksLocalDataSourceImpl(sl<ILocalStorageRepository>()),
    );
  }
}
