import 'package:app_agrihurbi/core/network/dio_client.dart';
// Core
import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:app_agrihurbi/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_agrihurbi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_agrihurbi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/refresh_user_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/register_usecase.dart';
// App Features - Auth
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_agrihurbi/features/calculators/data/datasources/calculator_local_datasource.dart';
import 'package:app_agrihurbi/features/calculators/data/datasources/calculator_remote_datasource.dart';
import 'package:app_agrihurbi/features/calculators/data/repositories/calculator_repository_impl.dart';
import 'package:app_agrihurbi/features/calculators/domain/registry/calculator_registry.dart';
import 'package:app_agrihurbi/features/calculators/domain/repositories/calculator_repository.dart';
// Calculator System Services
import 'package:app_agrihurbi/features/calculators/domain/services/calculator_engine.dart';
import 'package:app_agrihurbi/features/calculators/domain/services/calculator_favorites_service.dart';
import 'package:app_agrihurbi/features/calculators/domain/usecases/execute_calculation.dart';
import 'package:app_agrihurbi/features/calculators/domain/usecases/get_calculators.dart';
import 'package:app_agrihurbi/features/calculators/domain/usecases/manage_calculation_history.dart';
// App Features - Calculators
import 'package:app_agrihurbi/features/calculators/presentation/providers/calculator_provider_simple.dart';
import 'package:app_agrihurbi/features/livestock/data/datasources/livestock_local_datasource.dart';
import 'package:app_agrihurbi/features/livestock/data/datasources/livestock_remote_datasource.dart';
import 'package:app_agrihurbi/features/livestock/data/repositories/livestock_repository_impl.dart';
// import 'package:app_agrihurbi/features/livestock/presentation/providers/equines_provider.dart' as equines_providers;
import 'package:app_agrihurbi/features/livestock/domain/repositories/livestock_repository.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/create_bovine.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/delete_bovine.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/get_bovine_by_id.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/get_bovines.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/get_equines.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/search_animals.dart';
import 'package:app_agrihurbi/features/livestock/domain/usecases/update_bovine.dart';
import 'package:app_agrihurbi/features/livestock/presentation/providers/bovines_provider.dart' as bovines_providers;
// App Features - Livestock
import 'package:app_agrihurbi/features/livestock/presentation/providers/livestock_provider.dart';
import 'package:app_agrihurbi/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:app_agrihurbi/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:app_agrihurbi/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:app_agrihurbi/features/weather/domain/repositories/weather_repository.dart';
import 'package:app_agrihurbi/features/weather/domain/usecases/calculate_weather_statistics.dart';
import 'package:app_agrihurbi/features/weather/domain/usecases/create_weather_measurement.dart';
import 'package:app_agrihurbi/features/weather/domain/usecases/get_rain_gauges.dart';
import 'package:app_agrihurbi/features/weather/domain/usecases/get_weather_measurements.dart';
// App Features - Weather
import 'package:app_agrihurbi/features/weather/presentation/providers/weather_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// Core Services Integration
import 'package:core/core.dart' as core_lib;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import generated file
// import 'injection_container.config.dart';

final getIt = GetIt.instance;

// @InjectableInit()
// void configureDependencies() => getIt.init();

/// Configure dependencies manually until we generate the config file
Future<void> configureDependencies() async {
  // Core Services
  getIt.registerSingleton<core_lib.HiveStorageService>(core_lib.HiveStorageService());
  getIt.registerSingleton<core_lib.FirebaseAuthService>(core_lib.FirebaseAuthService());
  getIt.registerSingleton<core_lib.RevenueCatService>(core_lib.RevenueCatService());
  getIt.registerSingleton<core_lib.FirebaseAnalyticsService>(core_lib.FirebaseAnalyticsService());
  
  // Network & Storage
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl(getIt<Connectivity>()));
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<DioClient>(DioClient(getIt<Dio>()));
  
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  
  // Auth Data Sources
  getIt.registerSingleton<AuthLocalDataSource>(
    AuthLocalDataSourceImpl(
      getIt<SharedPreferences>(),
      getIt<FlutterSecureStorage>(),
    ),
  );
  
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  
  // Auth Repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      getIt<AuthLocalDataSource>(),
      getIt<AuthRemoteDataSource>(),
      getIt<Connectivity>(),
    ),
  );
  
  // Auth Use Cases
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerSingleton<RegisterUseCase>(
    RegisterUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerSingleton<RefreshUserUseCase>(
    RefreshUserUseCase(getIt<AuthRepository>()),
  );
  
  // Core Use Cases (temporariamente comentadas até ter as interfaces corretas)
  // getIt.registerSingleton<core_lib.LoginUseCase>(
  //   core_lib.LoginUseCase(getIt<core_lib.IAuthRepository>(), getIt<core_lib.IAnalyticsRepository>()),
  // );
  
  // getIt.registerSingleton<core_lib.LogoutUseCase>(
  //   core_lib.LogoutUseCase(getIt<core_lib.IAuthRepository>(), getIt<core_lib.IAnalyticsRepository>()),
  // );
  
  // Auth Provider
  getIt.registerSingleton<AuthProvider>(
    AuthProvider(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      refreshUserUseCase: getIt<RefreshUserUseCase>(),
    ),
  );

  // === LIVESTOCK DEPENDENCIES ===
  
  // Livestock Data Sources
  getIt.registerSingleton<LivestockLocalDataSource>(
    LivestockLocalDataSourceImpl(),
  );
  
  getIt.registerSingleton<LivestockRemoteDataSource>(
    LivestockRemoteDataSourceImpl(getIt<DioClient>()),
  );
  
  // Livestock Repository
  getIt.registerSingleton<LivestockRepository>(
    LivestockRepositoryImpl(
      getIt<LivestockLocalDataSource>(),
      getIt<LivestockRemoteDataSource>(),
      getIt<Connectivity>(),
    ),
  );
  
  // Livestock Use Cases
  getIt.registerSingleton<GetAllBovinesUseCase>(
    GetAllBovinesUseCase(getIt<LivestockRepository>()),
  );
  
  getIt.registerSingleton<GetEquinesUseCase>(
    GetEquinesUseCase(getIt<LivestockRepository>()),
  );
  
  getIt.registerSingleton<CreateBovineUseCase>(
    CreateBovineUseCase(getIt<LivestockRepository>()),
  );
  
  getIt.registerSingleton<UpdateBovineUseCase>(
    UpdateBovineUseCase(getIt<LivestockRepository>()),
  );
  
  getIt.registerSingleton<DeleteBovineUseCase>(
    DeleteBovineUseCase(getIt<LivestockRepository>()),
  );
  
  getIt.registerSingleton<SearchAnimalsUseCase>(
    SearchAnimalsUseCase(getIt<LivestockRepository>()),
  );
  
  // Livestock Providers
  getIt.registerSingleton<LivestockProvider>(
    LivestockProvider(
      repository: getIt<LivestockRepository>(),
      getAllBovines: getIt<GetAllBovinesUseCase>(),
      getEquines: getIt<GetEquinesUseCase>(),
      createBovine: getIt<CreateBovineUseCase>(),
      updateBovine: getIt<UpdateBovineUseCase>(),
      deleteBovine: getIt<DeleteBovineUseCase>(),
      searchAnimals: getIt<SearchAnimalsUseCase>(),
    ),
  );
  
  // Specialized Bovines Provider
  getIt.registerSingleton<bovines_providers.BovinesProvider>(
    bovines_providers.BovinesProvider(
      getAllBovines: getIt<GetAllBovinesUseCase>(),
      getBovineById: getIt<GetBovineByIdUseCase>(),
      createBovine: getIt<CreateBovineUseCase>(),
      updateBovine: getIt<UpdateBovineUseCase>(),
      deleteBovine: getIt<DeleteBovineUseCase>(),
    ),
  );
  
  // TODO: Specialized Equines Provider - Implementar quando GetAllEquinesUseCase e GetEquineByIdUseCase estiverem disponíveis
  // getIt.registerSingleton<equines_providers.EquinesProvider>(
  //   equines_providers.EquinesProvider(
  //     getAllEquines: getIt<GetAllEquinesUseCase>(),
  //     getEquines: getIt<GetEquinesUseCase>(),
  //     getEquineById: getIt<GetEquineByIdUseCase>(),
  //   ),
  // );

  // === CALCULATOR DEPENDENCIES ===
  
  // Calculator Data Sources
  getIt.registerSingleton<CalculatorLocalDataSource>(
    CalculatorLocalDataSourceImpl(),
  );
  
  getIt.registerSingleton<CalculatorRemoteDataSource>(
    CalculatorRemoteDataSourceImpl(getIt<DioClient>()),
  );
  
  // Calculator Repository
  getIt.registerSingleton<CalculatorRepository>(
    CalculatorRepositoryImpl(getIt<CalculatorLocalDataSource>()),
  );
  
  // Calculator Use Cases
  getIt.registerSingleton<GetCalculators>(
    GetCalculators(getIt<CalculatorRepository>()),
  );
  
  getIt.registerSingleton<GetCalculatorById>(
    GetCalculatorById(getIt<CalculatorRepository>()),
  );
  
  getIt.registerSingleton<ExecuteCalculation>(
    ExecuteCalculation(getIt<CalculatorRepository>()),
  );
  
  getIt.registerSingleton<GetCalculationHistory>(
    GetCalculationHistory(getIt<CalculatorRepository>()),
  );
  
  // Calculator System Services
  getIt.registerSingleton<CalculatorRegistry>(
    CalculatorRegistry(),
  );
  
  getIt.registerSingleton<CalculatorEngine>(
    CalculatorEngine(),
  );
  
  getIt.registerSingleton<CalculatorFavoritesService>(
    CalculatorFavoritesService(getIt<SharedPreferences>()),
  );
  
  // Calculator Provider
  getIt.registerSingleton<CalculatorProvider>(
    CalculatorProvider(
      getCalculators: getIt<GetCalculators>(),
      getCalculatorById: getIt<GetCalculatorById>(),
      executeCalculation: getIt<ExecuteCalculation>(),
      getCalculationHistory: getIt<GetCalculationHistory>(),
    ),
  );
  
  // === WEATHER DEPENDENCIES ===
  
  // Weather Data Sources
  getIt.registerSingleton<WeatherLocalDataSource>(
    WeatherLocalDataSourceImpl(),
  );
  
  getIt.registerSingleton<WeatherRemoteDataSource>(
    WeatherRemoteDataSourceImpl(getIt<DioClient>()),
  );
  
  // Weather Repository
  getIt.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(
      getIt<WeatherLocalDataSource>(),
      getIt<WeatherRemoteDataSource>(),
      getIt<Connectivity>(),
    ),
  );
  
  // Weather Use Cases
  getIt.registerSingleton<GetWeatherMeasurements>(
    GetWeatherMeasurements(getIt<WeatherRepository>()),
  );
  
  getIt.registerSingleton<CreateWeatherMeasurement>(
    CreateWeatherMeasurement(getIt<WeatherRepository>()),
  );
  
  getIt.registerSingleton<GetRainGauges>(
    GetRainGauges(getIt<WeatherRepository>()),
  );
  
  getIt.registerSingleton<CalculateWeatherStatistics>(
    CalculateWeatherStatistics(getIt<WeatherRepository>()),
  );
  
  // Weather Provider
  getIt.registerSingleton<WeatherProvider>(
    WeatherProvider(
      getWeatherMeasurements: getIt<GetWeatherMeasurements>(),
      createWeatherMeasurement: getIt<CreateWeatherMeasurement>(),
      getRainGauges: getIt<GetRainGauges>(),
      calculateWeatherStatistics: getIt<CalculateWeatherStatistics>(),
      weatherRepository: getIt<WeatherRepository>(),
    ),
  );

  // Inicializar sistema de calculadoras
  _initializeCalculatorSystem();
  
  // Initialize weather system
  _initializeWeatherSystem();
}

/// Inicializa o sistema completo de calculadoras
void _initializeCalculatorSystem() {
  try {
    // Configurar registry e motor de cálculo
    CalculatorDependencyConfigurator.configure();
    
    // Validar configuração
    final validation = CalculatorDependencyConfigurator.validateConfiguration();
    
    if (!validation.isValid) {
      print('⚠️  Avisos na configuração das calculadoras:');
      for (final error in validation.errors) {
        print('   - $error');
      }
    }
    
    if (validation.warnings.isNotEmpty) {
      print('ℹ️  Avisos na configuração das calculadoras:');
      for (final warning in validation.warnings) {
        print('   - $warning');
      }
    }
    
    print('✅ Sistema de calculadoras inicializado com sucesso!');
    print('   - ${validation.registryStats.totalRegistered} calculadoras registradas');
    print('   - ${validation.engineStats.totalCalculators} calculadoras no motor');
    print('   - ${validation.registryStats.totalCached} calculadoras em cache');
    
  } catch (e) {
    print('❌ Erro ao inicializar sistema de calculadoras: $e');
    rethrow;
  }
}

/// Inicializa o sistema meteorológico
void _initializeWeatherSystem() {
  try {
    // Initialize weather local data source
    final weatherLocalDataSource = getIt<WeatherLocalDataSource>();
    if (weatherLocalDataSource is WeatherLocalDataSourceImpl) {
      weatherLocalDataSource.init();
    }
    
    print('✅ Sistema meteorológico inicializado com sucesso!');
    print('   - Weather measurements, rain gauges, e statistics habilitados');
    print('   - Offline-first strategy configurada');
    print('   - APIs externas integradas');
    
  } catch (e) {
    print('❌ Erro ao inicializar sistema meteorológico: $e');
    // Continue execution - weather system is not critical for app startup
  }
}

@module
abstract class CoreServicesModule {
  @singleton
  core_lib.HiveStorageService get hiveService => core_lib.HiveStorageService();
  
  @singleton  
  core_lib.FirebaseAuthService get authService => core_lib.FirebaseAuthService();
  
  @singleton
  core_lib.RevenueCatService get premiumService => core_lib.RevenueCatService();
  
  @singleton
  core_lib.FirebaseAnalyticsService get analyticsService => core_lib.FirebaseAnalyticsService();
}

@module
abstract class NetworkModule {
  @singleton
  Connectivity get connectivity => Connectivity();
  
  @singleton
  NetworkInfo networkInfo(Connectivity connectivity) => NetworkInfoImpl(connectivity);
  
  @singleton
  Dio get dio => Dio();
  
  @singleton
  DioClient dioClient(Dio dio) => DioClient(dio);
}

@module 
abstract class StorageModule {
  @singleton
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
  
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}

