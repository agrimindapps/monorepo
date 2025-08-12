import 'package:get_it/get_it.dart';
import 'package:core/src/infrastructure/services/hive_storage_service.dart';
import '../../interfaces/network_info.dart';

// Domain
import '../../../features/tasks/domain/repositories/tasks_repository.dart';
import '../../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../../features/tasks/domain/usecases/add_task_usecase.dart';
import '../../../features/tasks/domain/usecases/update_task_usecase.dart';
import '../../../features/tasks/domain/usecases/complete_task_usecase.dart';

// Data
import '../../../features/tasks/data/repositories/tasks_repository_impl.dart';
import '../../../features/tasks/data/datasources/local/tasks_local_datasource.dart';
import '../../../features/tasks/data/datasources/remote/tasks_remote_datasource.dart';

// Presentation
import '../../../features/tasks/presentation/providers/tasks_provider.dart';

class TasksModule {
  static void init(GetIt sl) {
    // Presentation Layer
    sl.registerFactory(
      () => TasksProvider(
        getTasksUseCase: sl(),
        getTasksByPlantIdUseCase: sl(),
        getTasksByStatusUseCase: sl(),
        getOverdueTasksUseCase: sl(),
        getTodayTasksUseCase: sl(),
        getUpcomingTasksUseCase: sl(),
        addTaskUseCase: sl(),
        updateTaskUseCase: sl(),
        completeTaskUseCase: sl(),
        deleteTaskUseCase: sl(),
      ),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetTasksUseCase(sl()));
    sl.registerLazySingleton(() => GetTasksByPlantIdUseCase(sl()));
    sl.registerLazySingleton(() => GetTasksByStatusUseCase(sl()));
    sl.registerLazySingleton(() => GetOverdueTasksUseCase(sl()));
    sl.registerLazySingleton(() => GetTodayTasksUseCase(sl()));
    sl.registerLazySingleton(() => GetUpcomingTasksUseCase(sl()));
    sl.registerLazySingleton(() => AddTaskUseCase(sl()));
    sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
    sl.registerLazySingleton(() => CompleteTaskUseCase(sl()));
    sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

    // Repository
    sl.registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    );

    // Data Sources
    sl.registerLazySingleton<TasksRemoteDataSource>(
      () => TasksRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<TasksLocalDataSource>(
      () => TasksLocalDataSourceImpl(sl<HiveStorageService>()),
    );
  }
}