import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart'; // Commented out - using manual DI
import 'package:shared_preferences/shared_preferences.dart';

// Injectable configuration (commented out - using manual DI)
// import 'injectable_config.dart';

// Logging imports
import '../logging/data/datasources/log_local_data_source.dart';
import '../logging/data/datasources/log_remote_data_source.dart';
import '../logging/data/repositories/log_repository_impl.dart';
import '../logging/repositories/log_repository.dart';
import '../logging/services/logging_service.dart';
import '../services/analytics_service.dart';
import '../services/avatar_service.dart';
import '../services/platform_service.dart';
import '../services/auth_rate_limiter.dart';
import '../services/local_data_service.dart';

// Auth imports (keeping only needed ones)
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_anonymously.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/domain/usecases/send_password_reset.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;

// Vehicle imports
import '../../features/vehicles/data/datasources/vehicle_local_data_source.dart';
import '../../features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../features/vehicles/domain/usecases/get_all_vehicles.dart';
import '../../features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../features/vehicles/domain/usecases/add_vehicle.dart';
import '../../features/vehicles/domain/usecases/update_vehicle.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle.dart';
import '../../features/vehicles/domain/usecases/search_vehicles.dart';
import '../../features/vehicles/presentation/providers/vehicles_provider.dart';
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
import '../../features/odometer/data/datasources/odometer_remote_data_source.dart';
import '../../features/odometer/data/repositories/odometer_repository.dart';
import '../../features/odometer/presentation/providers/odometer_provider.dart';
// Expenses imports
import '../../features/expenses/data/datasources/expenses_remote_data_source.dart';
import '../../features/expenses/data/repositories/expenses_repository.dart';
import '../../features/expenses/presentation/providers/expenses_provider.dart';
// Premium imports
import '../../features/premium/data/datasources/premium_local_data_source.dart';
import '../../features/premium/data/datasources/premium_remote_data_source.dart';
import '../../features/premium/data/datasources/premium_firebase_data_source.dart';
import '../../features/premium/data/datasources/premium_webhook_data_source.dart';
import '../../features/premium/data/repositories/premium_repository_impl.dart';
import '../../features/premium/data/services/premium_sync_service.dart';
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

// Device Management imports
import 'package:device_info_plus/device_info_plus.dart';
import '../../features/device_management/presentation/providers/device_management_provider.dart';
import '../../features/device_management/domain/repositories/device_repository.dart';
import '../../features/device_management/data/repositories/device_repository_impl.dart';
import '../../features/device_management/data/datasources/device_local_datasource.dart';
import '../../features/device_management/data/datasources/device_remote_datasource.dart';
import '../../features/device_management/domain/usecases/get_user_devices.dart';
import '../../features/device_management/domain/usecases/revoke_device.dart';
import '../../features/device_management/domain/usecases/validate_device_limit.dart';

// Data Export imports
import '../../features/data_export/presentation/providers/data_export_provider.dart';
import '../../features/data_export/domain/repositories/data_export_repository.dart';
import '../../features/data_export/data/repositories/data_export_repository_impl.dart';
import '../../features/data_export/domain/services/platform_export_service.dart';

// Additional imports (removing duplicates)
import '../error/error_handler.dart';
import '../error/error_logger.dart';
import '../error/error_reporter.dart';
import '../services/gasometer_notification_service.dart';
import '../services/image_compression_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/receipt_image_service.dart';
// import '../sync/presentation/providers/sync_status_provider.dart'; // TODO: Replace with UnifiedSync in Phase 2

// Profile Image Service
import '../../features/profile/domain/services/profile_image_service.dart';

final sl = GetIt.instance;

/// Configuração completa do DI usando injectable + manual registrations
Future<void> initializeDependencies() async {
  // ===== Call injectable configuration first (commented out - using manual DI) =====
  // await configureDependencies();
  
  // ===== External Dependencies =====

  // Register external dependencies manually (since injectable is disabled)
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<Connectivity>(Connectivity());
  sl.registerSingleton<core.ISubscriptionRepository>(core.RevenueCatService());
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));

  // ===== Services =====
  
  // Core Services
  sl.registerLazySingleton<LocalDataService>(() => LocalDataService());
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<AvatarService>(() => AvatarService());
  sl.registerLazySingleton<PlatformService>(() => const PlatformService());
  sl.registerLazySingleton<AuthRateLimiter>(() => AuthRateLimiter(sl<FlutterSecureStorage>()));

  // Logging Service
  sl.registerLazySingleton<LoggingService>(() => LoggingService(
    sl<LogRepository>(),
    sl<AnalyticsService>(),
  ));

  // Image Services
  sl.registerLazySingleton<ImageCompressionService>(() => ImageCompressionService());
  sl.registerLazySingleton<FirebaseStorageService>(() => FirebaseStorageService());
  sl.registerLazySingleton<ReceiptImageService>(() => ReceiptImageService(
    sl<ImageCompressionService>(),
    sl<FirebaseStorageService>(),
  ));

  // Profile Image Service
  sl.registerLazySingleton<GasometerProfileImageService>(() => GasometerProfileImageService(
    sl<AnalyticsService>(),
  ));
  
  // Logging Service - requires AnalyticsService and LogRepository (both now injectable)
  // LoggingService is now registered by injectable (@LazySingleton annotation)
  
  // AuthRateLimiter is now registered by injectable (@LazySingleton annotation)
  sl.registerLazySingleton<GasOMeterNotificationService>(() => GasOMeterNotificationService());
  // PlatformService will be registered by injectable (@injectable annotation)

  // Error Handling Services
  sl.registerLazySingleton<ErrorLogger>(() => ErrorLogger());
  sl.registerLazySingleton<ErrorHandler>(() => ErrorHandler(sl<ErrorLogger>()));
  sl.registerLazySingleton<ErrorReporter>(() => ErrorReporter(sl<AnalyticsService>()));

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


  // Premium Sync Service
  sl.registerLazySingleton<PremiumSyncService>(() => PremiumSyncService(
    sl<PremiumRemoteDataSource>(),
    sl<PremiumFirebaseDataSource>(),
    sl<PremiumWebhookDataSource>(),
    sl<core.IAuthRepository>(),
  ));

  // ===== Connectivity =====
  // Connectivity will be registered by injectable RegisterModule

  // ===== Data Sources =====

  // Auth Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
    sl<SharedPreferences>(),
    sl<FlutterSecureStorage>(),
  ));

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
    sl<FirebaseAuth>(),
    sl<FirebaseFirestore>(),
  ));

  // Vehicle Data Sources
  sl.registerLazySingleton<VehicleLocalDataSource>(() => VehicleLocalDataSourceImpl(
    sl<LocalDataService>(),
  ));
  sl.registerLazySingleton<VehicleRemoteDataSource>(() => VehicleRemoteDataSourceImpl(
    sl<FirebaseFirestore>(),
  ));

  // Log Data Sources
  sl.registerLazySingleton<LogLocalDataSource>(() => LogLocalDataSourceImpl());
  sl.registerLazySingleton<LogRemoteDataSource>(() => LogRemoteDataSourceImpl(
    firestore: sl<FirebaseFirestore>(),
  ));

  // Fuel Data Sources
  sl.registerLazySingleton<FuelLocalDataSource>(() => FuelLocalDataSourceImpl(
    sl<LocalDataService>(),
  ));
  sl.registerLazySingleton<FuelRemoteDataSource>(() => FuelRemoteDataSourceImpl(
    sl<FirebaseFirestore>(),
  ));

  // Maintenance Data Sources
  sl.registerLazySingleton<MaintenanceLocalDataSource>(() => MaintenanceLocalDataSourceImpl(
    sl<LocalDataService>(),
  ));
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(() => MaintenanceRemoteDataSourceImpl(
    sl<FirebaseAuth>(),
    sl<FirebaseFirestore>(),
  ));

  // Expenses Remote Data Source
  sl.registerLazySingleton<ExpensesRemoteDataSource>(() => ExpensesRemoteDataSourceImpl(
    sl<FirebaseFirestore>(),
  ));

  // Odometer Remote Data Source
  sl.registerLazySingleton<OdometerRemoteDataSource>(() => OdometerRemoteDataSourceImpl(
    sl<FirebaseFirestore>(),
  ));

  // Premium Data Sources
  sl.registerLazySingleton<PremiumLocalDataSource>(() => PremiumLocalDataSourceImpl(
    sl<SharedPreferences>(),
  ));
  sl.registerLazySingleton<PremiumRemoteDataSource>(() => PremiumRemoteDataSourceImpl(
    sl<core.ISubscriptionRepository>(),
  ));
  sl.registerLazySingleton<PremiumFirebaseDataSource>(() => PremiumFirebaseDataSource(
    sl<FirebaseFirestore>(),
    sl<core.IAuthRepository>(),
  ));
  sl.registerLazySingleton<PremiumWebhookDataSource>(() => PremiumWebhookDataSource(
    sl<FirebaseFirestore>(),
  ));

  // Reports Data Source
  sl.registerLazySingleton<ReportsDataSource>(() => ReportsDataSourceImpl(
    sl<FuelRepository>(),
  ));

  // ===== Repositories =====

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl<AuthRemoteDataSource>(),
    localDataSource: sl<AuthLocalDataSource>(),
  ));

  // Core IAuthRepository (use FirebaseAuthService from core)
  sl.registerLazySingleton<core.IAuthRepository>(() => core.FirebaseAuthService(
    firebaseAuth: sl<FirebaseAuth>(),
  ));

  // Log Repository
  sl.registerLazySingleton<LogRepository>(() => LogRepositoryImpl(
    localDataSource: sl<LogLocalDataSource>(),
    remoteDataSource: sl<LogRemoteDataSource>(),
    connectivity: sl<Connectivity>(),
  ));

  // Vehicle Repository
  sl.registerLazySingleton<VehicleRepository>(() => VehicleRepositoryImpl(
    localDataSource: sl<VehicleLocalDataSource>(),
    remoteDataSource: sl<VehicleRemoteDataSource>(),
    connectivity: sl<Connectivity>(),
    authRepository: sl<AuthRepository>(),
    loggingService: sl<LoggingService>(),
  ));

  // Fuel Repository
  sl.registerLazySingleton<FuelRepository>(() => FuelRepositoryImpl(
    localDataSource: sl<FuelLocalDataSource>(),
    remoteDataSource: sl<FuelRemoteDataSource>(),
    connectivity: sl<Connectivity>(),
    authRepository: sl<AuthRepository>(),
    loggingService: sl<LoggingService>(),
  ));

  // Maintenance Repository
  sl.registerLazySingleton<MaintenanceRepository>(() => MaintenanceRepositoryImpl(
    localDataSource: sl<MaintenanceLocalDataSource>(),
    remoteDataSource: sl<MaintenanceRemoteDataSource>(),
    connectivity: sl<Connectivity>(),
    loggingService: sl<LoggingService>(),
  ));

  // Premium Repository
  sl.registerLazySingleton<PremiumRepository>(() => PremiumRepositoryImpl(
    localDataSource: sl<PremiumLocalDataSource>(),
    remoteDataSource: sl<PremiumRemoteDataSource>(),
    syncService: sl<PremiumSyncService>(),
  ));

  // Reports Repository
  sl.registerLazySingleton<ReportsRepository>(() => ReportsRepositoryImpl(
    sl<ReportsDataSource>(),
  ));

  // ===== Use Cases =====

  // Auth Use Cases
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl<AuthRepository>()));
  sl.registerLazySingleton<WatchAuthState>(() => WatchAuthState(sl<AuthRepository>()));
  sl.registerLazySingleton<SignInWithEmail>(() => SignInWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton<SignUpWithEmail>(() => SignUpWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton<SignInAnonymously>(() => SignInAnonymously(sl<AuthRepository>()));
  sl.registerLazySingleton<SignOut>(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton<DeleteAccount>(() => DeleteAccount(sl<AuthRepository>()));
  sl.registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl<AuthRepository>()));
  sl.registerLazySingleton<SendPasswordReset>(() => SendPasswordReset(sl<AuthRepository>()));

  // Vehicle Use Cases
  sl.registerLazySingleton<GetAllVehicles>(() => GetAllVehicles(sl<VehicleRepository>()));
  sl.registerLazySingleton<GetVehicleById>(() => GetVehicleById(sl<VehicleRepository>()));
  sl.registerLazySingleton<AddVehicle>(() => AddVehicle(sl<VehicleRepository>()));
  sl.registerLazySingleton<UpdateVehicle>(() => UpdateVehicle(sl<VehicleRepository>()));
  sl.registerLazySingleton<DeleteVehicle>(() => DeleteVehicle(sl<VehicleRepository>()));
  sl.registerLazySingleton<SearchVehicles>(() => SearchVehicles(sl<VehicleRepository>()));

  // Fuel Use Cases
  sl.registerLazySingleton<GetAllFuelRecords>(() => GetAllFuelRecords(sl<FuelRepository>()));
  sl.registerLazySingleton<AddFuelRecord>(() => AddFuelRecord(sl<FuelRepository>()));
  sl.registerLazySingleton<UpdateFuelRecord>(() => UpdateFuelRecord(sl<FuelRepository>()));
  sl.registerLazySingleton<DeleteFuelRecord>(() => DeleteFuelRecord(sl<FuelRepository>()));
  sl.registerLazySingleton<GetFuelRecordsByVehicle>(() => GetFuelRecordsByVehicle(sl<FuelRepository>()));
  sl.registerLazySingleton<SearchFuelRecords>(() => SearchFuelRecords(sl<FuelRepository>()));
  sl.registerLazySingleton<GetAverageConsumption>(() => GetAverageConsumption(sl<FuelRepository>()));
  sl.registerLazySingleton<GetTotalSpent>(() => GetTotalSpent(sl<FuelRepository>()));
  sl.registerLazySingleton<GetRecentFuelRecords>(() => GetRecentFuelRecords(sl<FuelRepository>()));

  // Maintenance Use Cases
  sl.registerLazySingleton<GetAllMaintenanceRecords>(() => GetAllMaintenanceRecords(sl<MaintenanceRepository>()));
  sl.registerLazySingleton<AddMaintenanceRecord>(() => AddMaintenanceRecord(sl<MaintenanceRepository>()));
  sl.registerLazySingleton<UpdateMaintenanceRecord>(() => UpdateMaintenanceRecord(sl<MaintenanceRepository>()));
  sl.registerLazySingleton<DeleteMaintenanceRecord>(() => DeleteMaintenanceRecord(sl<MaintenanceRepository>()));
  sl.registerLazySingleton<GetMaintenanceRecordsByVehicle>(() => GetMaintenanceRecordsByVehicle(sl<MaintenanceRepository>()));
  sl.registerLazySingleton<GetUpcomingMaintenanceRecords>(() => GetUpcomingMaintenanceRecords(sl<MaintenanceRepository>()));
  sl.registerLazySingleton<GetMaintenanceAnalytics>(() => GetMaintenanceAnalytics(sl<MaintenanceRepository>()));

  // Reports Use Cases (using correct class names)
  sl.registerLazySingleton<GenerateCustomReport>(() => GenerateCustomReport(sl<ReportsRepository>()));
  sl.registerLazySingleton<GenerateMonthlyReport>(() => GenerateMonthlyReport(sl<ReportsRepository>()));
  sl.registerLazySingleton<GenerateYearlyReport>(() => GenerateYearlyReport(sl<ReportsRepository>()));
  sl.registerLazySingleton<CompareMonthlyReports>(() => CompareMonthlyReports(sl<ReportsRepository>()));
  sl.registerLazySingleton<CompareYearlyReports>(() => CompareYearlyReports(sl<ReportsRepository>()));
  sl.registerLazySingleton<ExportReportToCSV>(() => ExportReportToCSV(sl<ReportsRepository>()));
  sl.registerLazySingleton<ExportReportToPDF>(() => ExportReportToPDF(sl<ReportsRepository>()));
  sl.registerLazySingleton<GetFuelEfficiencyTrends>(() => GetFuelEfficiencyTrends(sl<ReportsRepository>()));
  sl.registerLazySingleton<GetCostAnalysis>(() => GetCostAnalysis(sl<ReportsRepository>()));
  sl.registerLazySingleton<GetUsagePatterns>(() => GetUsagePatterns(sl<ReportsRepository>()));

  // Premium Use Cases
  sl.registerLazySingleton<CheckPremiumStatus>(() => CheckPremiumStatus(sl<PremiumRepository>()));
  sl.registerLazySingleton<CanUseFeature>(() => CanUseFeature(sl<PremiumRepository>()));
  sl.registerLazySingleton<CanAddVehicle>(() => CanAddVehicle(sl<PremiumRepository>()));
  sl.registerLazySingleton<CanAddFuelRecord>(() => CanAddFuelRecord(sl<PremiumRepository>()));
  sl.registerLazySingleton<CanAddMaintenanceRecord>(() => CanAddMaintenanceRecord(sl<PremiumRepository>()));
  sl.registerLazySingleton<PurchasePremium>(() => PurchasePremium(sl<PremiumRepository>()));
  sl.registerLazySingleton<GetAvailableProducts>(() => GetAvailableProducts(sl<PremiumRepository>()));
  sl.registerLazySingleton<RestorePurchases>(() => RestorePurchases(sl<PremiumRepository>()));
  sl.registerLazySingleton<GenerateLocalLicense>(() => GenerateLocalLicense(sl<PremiumRepository>()));
  sl.registerLazySingleton<RevokeLocalLicense>(() => RevokeLocalLicense(sl<PremiumRepository>()));
  sl.registerLazySingleton<HasActiveLocalLicense>(() => HasActiveLocalLicense(sl<PremiumRepository>()));

  // Expenses Use Cases (removing since files don't exist)

  // ===== Providers =====

  // Auth Provider
  sl.registerFactory<auth_provider.AuthProvider>(() => auth_provider.AuthProvider(
    getCurrentUser: sl<GetCurrentUser>(),
    watchAuthState: sl<WatchAuthState>(),
    signInWithEmail: sl<SignInWithEmail>(),
    signUpWithEmail: sl<SignUpWithEmail>(),
    signInAnonymously: sl<SignInAnonymously>(),
    signOut: sl<SignOut>(),
    deleteAccount: sl<DeleteAccount>(),
    updateProfile: sl<UpdateProfile>(),
    sendPasswordReset: sl<SendPasswordReset>(),
    analytics: sl<AnalyticsService>(),
    platformService: sl<PlatformService>(),
    rateLimiter: sl<AuthRateLimiter>(),
    // syncService: sl<sync_interface.ISyncService>(), // TODO: Replace with UnifiedSync in Phase 2
    authLocalDataSource: sl<AuthLocalDataSource>(),
  ));

  // Vehicles Provider
  sl.registerLazySingleton<VehiclesProvider>(() => VehiclesProvider(
    getAllVehicles: sl<GetAllVehicles>(),
    getVehicleById: sl<GetVehicleById>(),
    addVehicle: sl<AddVehicle>(),
    updateVehicle: sl<UpdateVehicle>(),
    deleteVehicle: sl<DeleteVehicle>(),
    searchVehicles: sl<SearchVehicles>(),
    repository: sl<VehicleRepository>(),
  ));

  // Fuel Provider (simplified - using only available use cases)
  sl.registerLazySingleton<FuelProvider>(() => FuelProvider(
    getAllFuelRecords: sl<GetAllFuelRecords>(),
    getFuelRecordsByVehicle: sl<GetFuelRecordsByVehicle>(),
    addFuelRecord: sl<AddFuelRecord>(),
    updateFuelRecord: sl<UpdateFuelRecord>(),
    deleteFuelRecord: sl<DeleteFuelRecord>(),
    searchFuelRecords: sl<SearchFuelRecords>(),
    getAverageConsumption: sl<GetAverageConsumption>(), // Available use case
    getTotalSpent: sl<GetTotalSpent>(), // Available use case
    getRecentFuelRecords: sl<GetRecentFuelRecords>(), // Using available use case
    errorHandler: sl<ErrorHandler>(),
    errorReporter: sl<ErrorReporter>(),
  ));

  // Maintenance Provider
  sl.registerLazySingleton<MaintenanceProvider>(() => MaintenanceProvider(
    sl<GetAllMaintenanceRecords>(),
    sl<GetMaintenanceRecordsByVehicle>(),
    sl<AddMaintenanceRecord>(),
    sl<UpdateMaintenanceRecord>(),
    sl<DeleteMaintenanceRecord>(),
    sl<GetUpcomingMaintenanceRecords>(),
    sl<GetMaintenanceAnalytics>(),
  ));

  // Reports Provider
  sl.registerLazySingleton<ReportsProvider>(() => ReportsProvider(
    generateMonthlyReport: sl<GenerateMonthlyReport>(),
    generateYearlyReport: sl<GenerateYearlyReport>(),
    generateCustomReport: sl<GenerateCustomReport>(),
    compareMonthlyReports: sl<CompareMonthlyReports>(),
    compareYearlyReports: sl<CompareYearlyReports>(),
    getFuelEfficiencyTrends: sl<GetFuelEfficiencyTrends>(),
    getCostAnalysis: sl<GetCostAnalysis>(),
    getUsagePatterns: sl<GetUsagePatterns>(),
    exportReportToCSV: sl<ExportReportToCSV>(),
  ));

  // Odometer Repository - now requires remote data source, connectivity and auth
  sl.registerLazySingleton<OdometerRepository>(() {
    final repository = OdometerRepository(
      sl<LoggingService>(),
      sl<OdometerRemoteDataSource>(),
      sl<Connectivity>(),
      sl<AuthRepository>()
    );
    // Initialize asynchronously (not blocking registration)
    repository.initialize().catchError((Object e) {
      debugPrint('⚠️ OdometerRepository initialization failed: $e');
    });
    return repository;
  });

  // Expenses Repository - now requires remote data source, connectivity and auth
  sl.registerLazySingleton<ExpensesRepository>(() {
    final repository = ExpensesRepository(
      sl<LoggingService>(),
      sl<ExpensesRemoteDataSource>(),
      sl<Connectivity>(),
      sl<AuthRepository>()
    );
    // Initialize asynchronously (not blocking registration)
    repository.initialize().catchError((Object e) {
      debugPrint('⚠️ ExpensesRepository initialization failed: $e');
    });
    return repository;
  });

  // Premium Repository already registered above

  // ===== Additional Providers (Manual Registration) =====
  
  // Expenses Provider
  sl.registerLazySingleton<ExpensesProvider>(() => ExpensesProvider(
    sl<ExpensesRepository>(),
    sl<VehiclesProvider>(),
  ));

  // Premium Provider
  sl.registerLazySingleton<PremiumProvider>(() => PremiumProvider(
    sl<CheckPremiumStatus>(),
    sl<CanUseFeature>(),
    sl<CanAddVehicle>(),
    sl<CanAddFuelRecord>(),
    sl<CanAddMaintenanceRecord>(),
    sl<PurchasePremium>(),
    sl<GetAvailableProducts>(),
    sl<RestorePurchases>(),
    sl<GenerateLocalLicense>(),
    sl<RevokeLocalLicense>(),
    sl<PremiumRepository>(),
  ));

  // Settings Provider
  sl.registerFactory<SettingsProvider>(
    () => SettingsProvider(
      preferences: sl(),
      appRatingRepository: sl(),
    ),
  );

  // Odometer Provider
  sl.registerLazySingleton<OdometerProvider>(
    () => OdometerProvider(
      sl<OdometerRepository>(),
      sl<VehiclesProvider>(),
    ),
  );

  // ===== Device Management =====
  
  // Device Info Plugin
  sl.registerLazySingleton<DeviceInfoPlugin>(() => DeviceInfoPlugin());
  
  // Device Management Data Sources
  sl.registerLazySingleton<DeviceLocalDataSource>(() => DeviceLocalDataSource());
  sl.registerLazySingleton<DeviceRemoteDataSource>(() => DeviceRemoteDataSource(
    firestore: sl<FirebaseFirestore>(),
    deviceInfoPlugin: sl<DeviceInfoPlugin>(),
  ));
  
  // Device Management Repository
  sl.registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl(
    sl<DeviceRemoteDataSource>(),
    sl<DeviceLocalDataSource>(),
    sl<Connectivity>(),
  ));
  
  // Device Management Use Cases
  sl.registerLazySingleton<GetUserDevicesUseCase>(() => GetUserDevicesUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton<RevokeDeviceUseCase>(() => RevokeDeviceUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton<ValidateDeviceLimitUseCase>(() => ValidateDeviceLimitUseCase(sl<DeviceRepository>()));
  
  // Device Management Provider
  sl.registerLazySingleton<DeviceManagementProvider>(() => DeviceManagementProvider(
    getUserDevicesUseCase: sl<GetUserDevicesUseCase>(),
    revokeDeviceUseCase: sl<RevokeDeviceUseCase>(),
    validateDeviceLimitUseCase: sl<ValidateDeviceLimitUseCase>(),
  ));

  // ===== Data Export =====
  
  // Data Export Repository
  sl.registerLazySingleton<DataExportRepository>(() => DataExportRepositoryImpl());
  
  // Platform Export Service (factory pattern)
  sl.registerLazySingleton<PlatformExportService>(() => PlatformExportServiceFactory.create());
  
  // Data Export Provider
  sl.registerLazySingleton<DataExportProvider>(() => DataExportProvider(
    repository: sl<DataExportRepository>(),
    platformService: sl<PlatformExportService>(),
    analyticsService: sl<AnalyticsService>(),
  ));

  // Sync Status Provider - REMOVED: Legacy sync system
  // sl.registerLazySingleton<SyncStatusProvider>(() => SyncStatusProvider(
  //   sl<SyncService>(),
  // )); // TODO: Replace with UnifiedSync status provider in Phase 2

  // ===== Initialize services that need post-DI setup =====
  // await initializePostDIServices(); // Function not defined - commenting out
}

// @module // Commented out - using manual DI
class RegisterModule {
  // External dependencies can be registered here
  // @preResolve // Commented out - using manual DI
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // @singleton // Commented out - using manual DI
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // @singleton // Commented out - using manual DI
  static FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  // @singleton // Commented out - using manual DI
  static Connectivity get connectivity => Connectivity();

  // @singleton // Commented out - using manual DI
  static core.ISubscriptionRepository get subscriptionRepository => core.RevenueCatService();

  // @singleton // Commented out - using manual DI
  static FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
}

// Extension para facilitar o acesso
extension GetItExtension on GetIt {
  T getService<T extends Object>() => get<T>();
}