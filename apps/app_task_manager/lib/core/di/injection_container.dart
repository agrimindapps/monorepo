import 'package:get_it/get_it.dart';
import 'package:core/core.dart';

import '../../data/datasources/task_local_datasource.dart';
import '../../data/datasources/task_local_datasource_impl.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_local_datasource_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource_mock.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_subtasks.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/reorder_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/delete_account.dart';
import '../../infrastructure/services/analytics_service.dart';
import '../../infrastructure/services/crashlytics_service.dart';
import '../../infrastructure/services/performance_service.dart';
import '../../infrastructure/services/subscription_service.dart';
import '../../infrastructure/services/notification_service.dart';
import '../../infrastructure/services/auth_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Task Use Cases
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => GetSubtasks(sl()));
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => ReorderTasks(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => WatchTasks(sl()));

  // Auth Use Cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => WatchAuthState(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: sl(),
      // remoteDataSource: sl(), // Será adicionado quando Firebase estiver configurado
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(() => TaskLocalDataSourceImpl());
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceMock());
  
  // Firebase Services (Core)
  sl.registerLazySingleton<IAnalyticsRepository>(() => FirebaseAnalyticsService());
  sl.registerLazySingleton<ICrashlyticsRepository>(() => FirebaseCrashlyticsService());
  sl.registerLazySingleton<IPerformanceRepository>(() => PerformanceService());
  sl.registerLazySingleton<ISubscriptionRepository>(() => RevenueCatService());
  sl.registerLazySingleton<INotificationRepository>(() => LocalNotificationService());
  sl.registerLazySingleton<IAuthRepository>(() => FirebaseAuthService());
  
  // Task Manager Services
  sl.registerLazySingleton(() => TaskManagerAnalyticsService(sl()));
  sl.registerLazySingleton(() => TaskManagerCrashlyticsService(sl()));
  sl.registerLazySingleton(() => TaskManagerPerformanceService(sl()));
  sl.registerLazySingleton(() => TaskManagerSubscriptionService(sl(), sl(), sl()));
  sl.registerLazySingleton(() => TaskManagerNotificationService(sl(), sl(), sl()));
  sl.registerLazySingleton(() => TaskManagerAuthService(authRepository: sl()));
  
  // TODO: Implementar TaskRemoteDataSourceImpl quando Firebase estiver configurado
  // sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl());
}