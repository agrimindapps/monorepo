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
  await configureDependencies();
  
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
  // ErrorHandler will be registered by injectable (@factory annotation)
  // ErrorReporter will be registered by injectable (@factory annotation)

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
  
  // Data Sources are now registered by injectable - see injectable_config.config.dart
  // VehicleLocalDataSource - registered by injectable
  // VehicleRemoteDataSource - registered by injectable  
  // AuthLocalDataSource - registered by injectable
  // AuthRemoteDataSource - registered by injectable
  // FuelLocalDataSource - registered by injectable
  // FuelRemoteDataSource - registered by injectable
  // MaintenanceLocalDataSource - registered by injectable
  // MaintenanceRemoteDataSource - registered by injectable
  // PremiumLocalDataSource - registered by injectable
  // PremiumRemoteDataSource - registered by injectable
  // LogLocalDataSource - registered by injectable
  // LogRemoteDataSource - registered by injectable

  // ReportsDataSource - registered by injectable

  // ===== Repositories =====
  
  // Repositories are now registered by injectable - see injectable_config.config.dart
  // LogRepository - registered by injectable
  // VehicleRepository - registered by injectable
  // AuthRepository - registered by injectable  
  // FuelRepository - registered by injectable
  // ReportsRepository - registered by injectable
  // MaintenanceRepository - registered by injectable
  // PremiumRepository - registered by injectable

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

  // Premium Repository - registered by injectable

  // ===== Use Cases =====
  
  // Use Cases are now registered by injectable - see injectable_config.config.dart
  // All Vehicle, Auth, Fuel, Reports, Maintenance, and Premium Use Cases are registered automatically
  
  // ===== Providers =====
  
  // Most Providers are now registered by injectable - see injectable_config.config.dart
  // VehiclesProvider - registered by injectable (@factory)
  // AuthProvider - registered by injectable (@factory) 
  // FuelProvider - registered by injectable (@factory)
  // ReportsProvider - registered by injectable (@factory)
  // MaintenanceProvider - registered by injectable (@factory)
  // PremiumProvider - registered by injectable (@factory)
  // SyncStatusProvider - registered by injectable (@factory)
  
  // Providers that need manual registration (not injectable or have special dependencies):
  
  // Expenses Provider - needs to be checked if injectable
  sl.registerLazySingleton<ExpensesProvider>(
    () => ExpensesProvider(
      sl<ExpensesRepository>(),
      sl<VehiclesProvider>(),
    ),
  );

  // Settings Provider - needs to be checked if injectable
  sl.registerFactory<SettingsProvider>(
    () => SettingsProvider(
      preferences: sl(),
      appRatingRepository: sl(),
    ),
  );

  // Odometer Provider - needs to be checked if injectable
  sl.registerLazySingleton<OdometerProvider>(
    () => OdometerProvider(
      sl<OdometerRepository>(),
      sl<VehiclesProvider>(),
    ),
  );

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