import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Injectable configuration
import 'injectable_config.dart';

// Logging imports
import '../logging/data/datasources/log_local_data_source.dart';
import '../logging/data/datasources/log_remote_data_source.dart';
import '../logging/data/repositories/log_repository_impl.dart';
import '../logging/repositories/log_repository.dart';
import '../logging/services/logging_service.dart';
import '../sync/services/conflict_resolver.dart';
import '../services/analytics_service.dart';
import '../services/avatar_service.dart';
import '../data/models/base_sync_model.dart';

// Auth imports
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/send_password_reset.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/sign_in_anonymously.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;
// Fuel imports
import '../../features/fuel/data/datasources/fuel_local_data_source.dart';
import '../../features/fuel/data/datasources/fuel_remote_data_source.dart';
import '../../features/fuel/data/repositories/fuel_repository_impl.dart';
import '../../features/fuel/domain/repositories/fuel_repository.dart';
import '../../features/fuel/domain/usecases/add_fuel_record.dart';
import '../../features/fuel/domain/usecases/delete_fuel_record.dart';
import '../../features/fuel/domain/usecases/get_all_fuel_records.dart';
import '../../features/fuel/domain/usecases/get_fuel_analytics.dart';
import '../../features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../features/fuel/domain/usecases/search_fuel_records.dart';
import '../../features/fuel/domain/usecases/update_fuel_record.dart';
import '../../features/fuel/presentation/providers/fuel_provider.dart';
// Settings imports
import '../../features/settings/presentation/providers/settings_provider.dart';
// Maintenance imports
import '../../features/maintenance/data/datasources/maintenance_local_data_source.dart';
import '../../features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import '../../features/maintenance/data/repositories/maintenance_repository_impl.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../features/maintenance/domain/usecases/add_maintenance_record.dart';
import '../../features/maintenance/domain/usecases/delete_maintenance_record.dart';
import '../../features/maintenance/domain/usecases/get_all_maintenance_records.dart';
import '../../features/maintenance/domain/usecases/get_maintenance_analytics.dart';
import '../../features/maintenance/domain/usecases/get_maintenance_records_by_vehicle.dart';
import '../../features/maintenance/domain/usecases/get_upcoming_maintenance_records.dart';
import '../../features/maintenance/domain/usecases/update_maintenance_record.dart';
import '../../features/maintenance/presentation/providers/maintenance_provider.dart';
// Odometer imports
import '../../features/odometer/data/repositories/odometer_repository.dart';
import '../../features/odometer/presentation/providers/odometer_provider.dart';
// Expenses imports
import '../../features/expenses/data/repositories/expenses_repository.dart';
import '../../features/expenses/presentation/providers/expenses_provider.dart';
// Premium imports
import '../../features/premium/data/datasources/premium_local_data_source.dart';
import '../../features/premium/data/datasources/premium_remote_data_source.dart';
import '../../features/premium/data/repositories/premium_repository_impl.dart';
import '../../features/premium/domain/repositories/premium_repository.dart';
import '../../features/premium/domain/usecases/can_add_fuel_record.dart';
import '../../features/premium/domain/usecases/can_add_maintenance_record.dart';
import '../../features/premium/domain/usecases/can_add_vehicle.dart';
import '../../features/premium/domain/usecases/can_use_feature.dart';
import '../../features/premium/domain/usecases/check_premium_status.dart';
import '../../features/premium/domain/usecases/get_available_products.dart';
import '../../features/premium/domain/usecases/manage_local_license.dart';
import '../../features/premium/domain/usecases/purchase_premium.dart';
import '../../features/premium/domain/usecases/restore_purchases.dart';
import '../../features/premium/presentation/providers/premium_provider.dart';
// Reports imports
import '../../features/reports/data/datasources/reports_data_source.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/compare_reports.dart';
import '../../features/reports/domain/usecases/export_report.dart';
import '../../features/reports/domain/usecases/generate_custom_report.dart';
import '../../features/reports/domain/usecases/generate_monthly_report.dart';
import '../../features/reports/domain/usecases/generate_yearly_report.dart';
import '../../features/reports/domain/usecases/get_reports_analytics.dart';
import '../../features/reports/presentation/providers/reports_provider.dart';
// Vehicle imports
import '../../features/vehicles/data/datasources/vehicle_local_data_source.dart';
import '../../features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../features/vehicles/domain/usecases/add_vehicle.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle.dart';
import '../../features/vehicles/domain/usecases/get_all_vehicles.dart';
import '../../features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../features/vehicles/domain/usecases/search_vehicles.dart';
import '../../features/vehicles/domain/usecases/update_vehicle.dart';
import '../../features/vehicles/presentation/providers/vehicles_provider.dart';
// Additional imports (removing duplicates)
import '../error/error_handler.dart';
import '../error/error_reporter.dart';
import '../services/auth_rate_limiter.dart';
import '../services/gasometer_notification_service.dart';
import '../services/local_data_service.dart';
import '../services/platform_service.dart';
import '../sync/presentation/providers/sync_status_provider.dart';

final sl = GetIt.instance;

/// Configuração completa do DI usando injectable + manual registrations
Future<void> initializeDependencies() async {
  // ===== Call injectable configuration first =====
  configureDependencies();
  
  // ===== External Dependencies =====
  
  // Firebase services will be registered by injectable RegisterModule
  
  // SharedPreferences will be registered by injectable RegisterModule
  
  // FlutterSecureStorage will be registered by injectable RegisterModule

  // ===== Services =====
  
  // Core Services
  // LocalDataService is now registered by injectable (@singleton annotation)
  // AnalyticsService will be registered by injectable (@singleton annotation)
  sl.registerLazySingleton<AvatarService>(() => AvatarService());
  
  // Logging Service - requires AnalyticsService and LogRepository (both now injectable)
  // LoggingService is now registered by injectable (@LazySingleton annotation)
  
  // AuthRateLimiter is now registered by injectable (@LazySingleton annotation)
  sl.registerLazySingleton<GasOMeterNotificationService>(() => GasOMeterNotificationService());
  // PlatformService will be registered by injectable (@injectable annotation)

  // Error Handling Services
  // ErrorLogger will be registered by injectable (@injectable annotation)
  sl.registerLazySingleton<ErrorHandler>(() => ErrorHandler(sl()));
  sl.registerLazySingleton<ErrorReporter>(() => ErrorReporter(sl()));

  // Core Package Services - ISubscriptionRepository will be registered by injectable RegisterModule
  
  // App Rating Service from core package
  sl.registerLazySingleton<core.IAppRatingRepository>(() => core.AppRatingService(
    // IDs reais das lojas (extraídos dos arquivos de configuração do projeto)
    appStoreId: '123456789', // TODO: Atualizar com ID real quando app for publicado na App Store
    googlePlayId: 'br.com.agrimind.gasometer', // ID real do Google Play
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
  ));

  // Sync Services
  // Note: SyncQueue, SyncOperations and SyncService are now registered by injectable
  // ConflictResolver<BaseSyncModel> is also registered by injectable now

  // ===== Connectivity =====
  // Connectivity will be registered by injectable RegisterModule

  // ===== Data Sources =====
  
  // Vehicle Data Sources
  sl.registerLazySingleton<VehicleLocalDataSource>(
    () => VehicleLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(sl()),
  );

  // Auth Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );

  // Fuel Data Sources
  sl.registerLazySingleton<FuelLocalDataSource>(
    () => FuelLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FuelRemoteDataSource>(
    () => FuelRemoteDataSourceImpl(sl()),
  );

  // Reports Data Sources
  sl.registerLazySingleton<ReportsDataSource>(
    () => ReportsDataSourceImpl(sl()),
  );

  // Maintenance Data Sources
  sl.registerLazySingleton<MaintenanceLocalDataSource>(
    () => MaintenanceLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(sl(), sl()),
  );

  // Premium Data Sources
  sl.registerLazySingleton<PremiumLocalDataSource>(
    () => PremiumLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PremiumRemoteDataSource>(
    () => PremiumRemoteDataSourceImpl(sl()),
  );

  // Log Data Sources
  sl.registerLazySingleton<LogLocalDataSource>(
    () => LogLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<LogRemoteDataSource>(
    () => LogRemoteDataSourceImpl(firestore: sl()),
  );

  // ===== Repositories =====
  
  // Log Repository
  sl.registerLazySingleton<LogRepository>(
    () => LogRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivity: sl(),
    ),
  );
  
  // Vehicle Repository
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivity: sl(),
      authRepository: sl(),
      loggingService: sl(),
    ),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Fuel Repository
  sl.registerLazySingleton<FuelRepository>(
    () => FuelRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivity: sl(),
      authRepository: sl(),
      loggingService: sl(),
    ),
  );

  // Reports Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );

  // Maintenance Repository
  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
      loggingService: sl(),
    ),
  );

  // Odometer Repository
  sl.registerLazySingleton<OdometerRepository>(() {
    final repository = OdometerRepository(sl<LoggingService>());
    // Initialize asynchronously (not blocking registration)
    repository.initialize().catchError((Object e) {
      debugPrint('⚠️ OdometerRepository initialization failed: $e');
    });
    return repository;
  });

  // Expenses Repository
  sl.registerLazySingleton<ExpensesRepository>(() {
    final repository = ExpensesRepository(sl<LoggingService>());
    // Initialize asynchronously (not blocking registration)
    repository.initialize().catchError((Object e) {
      debugPrint('⚠️ ExpensesRepository initialization failed: $e');
    });
    return repository;
  });

  // Premium Repository
  sl.registerLazySingleton<PremiumRepository>(
    () => PremiumRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ===== Use Cases =====
  
  // Vehicle Use Cases
  sl.registerLazySingleton<GetAllVehicles>(() => GetAllVehicles(sl()));
  sl.registerLazySingleton<GetVehicleById>(() => GetVehicleById(sl()));
  sl.registerLazySingleton<AddVehicle>(() => AddVehicle(sl()));
  sl.registerLazySingleton<UpdateVehicle>(() => UpdateVehicle(sl()));
  sl.registerLazySingleton<DeleteVehicle>(() => DeleteVehicle(sl()));
  sl.registerLazySingleton<SearchVehicles>(() => SearchVehicles(sl()));

  // Auth Use Cases
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));
  sl.registerLazySingleton<WatchAuthState>(() => WatchAuthState(sl()));
  sl.registerLazySingleton<SignInWithEmail>(() => SignInWithEmail(sl()));
  sl.registerLazySingleton<SignUpWithEmail>(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton<SignInAnonymously>(() => SignInAnonymously(sl()));
  sl.registerLazySingleton<SignOut>(() => SignOut(sl()));
  sl.registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl()));
  sl.registerLazySingleton<SendPasswordReset>(() => SendPasswordReset(sl()));
  sl.registerLazySingleton<DeleteAccount>(() => DeleteAccount(sl()));

  // Fuel Use Cases
  sl.registerLazySingleton<GetAllFuelRecords>(() => GetAllFuelRecords(sl()));
  sl.registerLazySingleton<GetFuelRecordsByVehicle>(() => GetFuelRecordsByVehicle(sl()));
  sl.registerLazySingleton<AddFuelRecord>(() => AddFuelRecord(sl()));
  sl.registerLazySingleton<UpdateFuelRecord>(() => UpdateFuelRecord(sl()));
  sl.registerLazySingleton<DeleteFuelRecord>(() => DeleteFuelRecord(sl()));
  sl.registerLazySingleton<SearchFuelRecords>(() => SearchFuelRecords(sl()));
  sl.registerLazySingleton<GetAverageConsumption>(() => GetAverageConsumption(sl()));
  sl.registerLazySingleton<GetTotalSpent>(() => GetTotalSpent(sl()));
  sl.registerLazySingleton<GetRecentFuelRecords>(() => GetRecentFuelRecords(sl()));

  // Reports Use Cases
  sl.registerLazySingleton<GenerateMonthlyReport>(() => GenerateMonthlyReport(sl()));
  sl.registerLazySingleton<GenerateYearlyReport>(() => GenerateYearlyReport(sl()));
  sl.registerLazySingleton<GenerateCustomReport>(() => GenerateCustomReport(sl()));
  sl.registerLazySingleton<CompareMonthlyReports>(() => CompareMonthlyReports(sl()));
  sl.registerLazySingleton<CompareYearlyReports>(() => CompareYearlyReports(sl()));
  sl.registerLazySingleton<GetFuelEfficiencyTrends>(() => GetFuelEfficiencyTrends(sl()));
  sl.registerLazySingleton<GetCostAnalysis>(() => GetCostAnalysis(sl()));
  sl.registerLazySingleton<GetUsagePatterns>(() => GetUsagePatterns(sl()));
  sl.registerLazySingleton<ExportReportToCSV>(() => ExportReportToCSV(sl()));
  sl.registerLazySingleton<ExportReportToPDF>(() => ExportReportToPDF(sl()));

  // Maintenance Use Cases
  sl.registerLazySingleton<GetAllMaintenanceRecords>(() => GetAllMaintenanceRecords(sl()));
  sl.registerLazySingleton<GetMaintenanceRecordsByVehicle>(() => GetMaintenanceRecordsByVehicle(sl()));
  sl.registerLazySingleton<AddMaintenanceRecord>(() => AddMaintenanceRecord(sl()));
  sl.registerLazySingleton<UpdateMaintenanceRecord>(() => UpdateMaintenanceRecord(sl()));
  sl.registerLazySingleton<DeleteMaintenanceRecord>(() => DeleteMaintenanceRecord(sl()));
  sl.registerLazySingleton<GetUpcomingMaintenanceRecords>(() => GetUpcomingMaintenanceRecords(sl()));
  sl.registerLazySingleton<GetMaintenanceAnalytics>(() => GetMaintenanceAnalytics(sl()));

  // Premium Use Cases
  sl.registerLazySingleton<CheckPremiumStatus>(() => CheckPremiumStatus(sl()));
  sl.registerLazySingleton<CanUseFeature>(() => CanUseFeature(sl()));
  sl.registerLazySingleton<CanAddVehicle>(() => CanAddVehicle(sl()));
  sl.registerLazySingleton<CanAddFuelRecord>(() => CanAddFuelRecord(sl()));
  sl.registerLazySingleton<CanAddMaintenanceRecord>(() => CanAddMaintenanceRecord(sl()));
  sl.registerLazySingleton<PurchasePremium>(() => PurchasePremium(sl()));
  sl.registerLazySingleton<GetAvailableProducts>(() => GetAvailableProducts(sl()));
  sl.registerLazySingleton<RestorePurchases>(() => RestorePurchases(sl()));
  sl.registerLazySingleton<GenerateLocalLicense>(() => GenerateLocalLicense(sl()));
  sl.registerLazySingleton<RevokeLocalLicense>(() => RevokeLocalLicense(sl()));
  
  // ===== Providers =====
  
  // Vehicle Provider
  sl.registerLazySingleton<VehiclesProvider>(
    () => VehiclesProvider(
      getAllVehicles: sl(),
      getVehicleById: sl(),
      addVehicle: sl(),
      updateVehicle: sl(),
      deleteVehicle: sl(),
      searchVehicles: sl(),
      repository: sl(),
    ),
  );

  // Auth Provider
  sl.registerFactory<auth_provider.AuthProvider>(
    () => auth_provider.AuthProvider(
      getCurrentUser: sl(),
      watchAuthState: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInAnonymously: sl(),
      signOut: sl(),
      deleteAccount: sl(),
      updateProfile: sl(),
      sendPasswordReset: sl(),
      analytics: sl(),
      platformService: sl(),
      rateLimiter: sl(),
      syncService: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Fuel Provider
  sl.registerLazySingleton<FuelProvider>(
    () => FuelProvider(
      getAllFuelRecords: sl(),
      getFuelRecordsByVehicle: sl(),
      addFuelRecord: sl(),
      updateFuelRecord: sl(),
      deleteFuelRecord: sl(),
      searchFuelRecords: sl(),
      getAverageConsumption: sl(),
      getTotalSpent: sl(),
      getRecentFuelRecords: sl(),
      errorHandler: sl(),
      errorReporter: sl(),
    ),
  );

  // Expenses Provider
  sl.registerLazySingleton<ExpensesProvider>(
    () => ExpensesProvider(
      sl<ExpensesRepository>(),
      sl<VehiclesProvider>(),
    ),
  );

  // Settings Provider
  sl.registerFactory<SettingsProvider>(
    () => SettingsProvider(
      preferences: sl(),
      appRatingRepository: sl(),
    ),
  );

  // Reports Provider
  sl.registerLazySingleton<ReportsProvider>(
    () => ReportsProvider(
      generateMonthlyReport: sl(),
      generateYearlyReport: sl(),
      generateCustomReport: sl(),
      compareMonthlyReports: sl(),
      compareYearlyReports: sl(),
      getFuelEfficiencyTrends: sl(),
      getCostAnalysis: sl(),
      getUsagePatterns: sl(),
      exportReportToCSV: sl(),
    ),
  );

  // Maintenance Provider
  sl.registerLazySingleton<MaintenanceProvider>(
    () => MaintenanceProvider(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  // Odometer Provider
  sl.registerLazySingleton<OdometerProvider>(
    () => OdometerProvider(
      sl<OdometerRepository>(),
      sl<VehiclesProvider>(),
    ),
  );

  // Premium Provider
  sl.registerFactory<PremiumProvider>(
    () => PremiumProvider(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  // Sync Provider
  sl.registerFactory<SyncStatusProvider>(() => SyncStatusProvider(sl()));

  // ===== Initialize services that need post-DI setup =====
  await initializePostDIServices();
}

@module
abstract class RegisterModule {
  // External dependencies can be registered here
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  
  @singleton
  Connectivity get connectivity => Connectivity();
  
  @singleton
  core.ISubscriptionRepository get subscriptionRepository => core.RevenueCatService();
  
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
}

// Extension para facilitar o acesso
extension GetItExtension on GetIt {
  T getService<T extends Object>() => get<T>();
}