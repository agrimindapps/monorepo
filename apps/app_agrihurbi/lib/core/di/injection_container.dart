import 'package:core/core.dart' as core_lib;

// Core local (mantido apenas se necessário)
import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:app_agrihurbi/core/network/dio_client.dart';

// Auth Feature - Using local implementations for now
import 'package:app_agrihurbi/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_agrihurbi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_agrihurbi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_agrihurbi/features/auth/presentation/controllers/auth_controller.dart';

/// Service locator instance - reusing from core package
final sl = core_lib.getIt;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Initialize core services first
  await core_lib.InjectionContainer.init();
  
  // Initialize app-specific dependencies
  await _initExternal();
  _initCore();
  _initAuth();
  _initLivestock();
  _initCalculators();
  _initWeather();
  _initNews();
  _initMarkets();
}

/// Initialize external dependencies
Future<void> _initExternal() async {
  // App-specific external dependencies can be added here
  // Core package already provides: SharedPreferences, FlutterSecureStorage, Connectivity, Dio
}

/// Initialize core dependencies
void _initCore() {
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  
  // Dio Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl()),
  );
}

/// Initialize authentication dependencies
void _initAuth() {
  // Controllers - using core use cases
  sl.registerFactory(
    () => AuthController(
      loginUsecase: sl<core_lib.LoginUseCase>(),
      registerUsecase: sl(), // Local implementation for now
      logoutUsecase: sl<core_lib.LogoutUseCase>(),
      getCurrentUserUsecase: sl(), // Local implementation for now
    ),
  );
  
  // Local use cases (temporary - until fully migrated to core)
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );
}

/// Initialize livestock dependencies
void _initLivestock() {
  // TODO: Implement livestock dependencies
}

/// Initialize calculators dependencies
void _initCalculators() {
  // TODO: Implement calculators dependencies
}

/// Initialize weather dependencies
void _initWeather() {
  // TODO: Implement weather dependencies
}

/// Initialize news dependencies
void _initNews() {
  // TODO: Implement news dependencies
}

/// Initialize markets dependencies
void _initMarkets() {
  // TODO: Implement markets dependencies
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}