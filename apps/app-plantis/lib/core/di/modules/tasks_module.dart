import 'package:core/core.dart';

import '../../../features/tasks/data/datasources/local/task_history_local_datasource.dart';
import '../../../features/tasks/data/datasources/local/tasks_local_datasource.dart';
import '../../../features/tasks/data/datasources/remote/task_history_remote_datasource.dart';
import '../../../features/tasks/data/datasources/remote/tasks_remote_datasource.dart';
import '../../../features/tasks/data/repositories/task_history_repository_impl.dart';
import '../../../features/tasks/data/repositories/tasks_repository_impl.dart';
import '../../../features/tasks/domain/repositories/task_history_repository.dart';
import '../../../features/tasks/domain/repositories/tasks_repository.dart';
import '../../../features/tasks/domain/usecases/add_task_usecase.dart';
import '../../../features/tasks/domain/usecases/complete_task_usecase.dart';
import '../../../features/tasks/domain/usecases/complete_task_with_regeneration_usecase.dart';
import '../../../features/tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../../features/tasks/domain/usecases/update_task_usecase.dart';
import '../../services/task_generation_service.dart';

class TasksModule {
  static void init(GetIt sl) {
    // TasksProvider agora usa Riverpod @riverpod (tasks_notifier.dart)
    // Não precisa mais de registro no GetIt
    sl.registerLazySingleton(() => TaskGenerationService());
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
        taskHistoryRepository: sl(),
      ),
    );
    sl.registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
        authService: sl(),
        plantsRepository: sl(),
      ),
    );
    sl.registerLazySingleton<TaskHistoryRepository>(
      () => TaskHistoryRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
        authService: sl(),
      ),
    );
    sl.registerLazySingleton<TaskHistoryRemoteDataSource>(
      () => TaskHistoryRemoteDataSourceImpl(),
    );
    sl.registerLazySingleton<TaskHistoryLocalDataSource>(
      () => TaskHistoryLocalDataSourceImpl(sl<ILocalStorageRepository>()),
    );
    sl.registerLazySingleton<TasksRemoteDataSource>(
      () => TasksRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<TasksLocalDataSource>(
      () => TasksLocalDataSourceImpl(sl<ILocalStorageRepository>()),
    );
  }
}
