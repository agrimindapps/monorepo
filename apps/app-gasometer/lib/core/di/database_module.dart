import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../database/gasometer_database.dart';
import '../../database/repositories/repositories.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/data_management/domain/services/data_cleaner_service.dart';

/// Módulo para registrar o banco de dados e repositórios de forma condicional
/// 
/// Na web, o banco não é registrado para evitar erros WASM.
/// Em mobile/desktop, o banco e todos os repositórios são registrados normalmente.
final getIt = GetIt.instance;

/// Registra o GasometerDatabase e repositórios condicionalmente
/// 
/// Deve ser chamado APÓS outras dependências terem sido registradas
void registerDatabaseModule() {
  if (kIsWeb) {
    print('⚠️  [DatabaseModule] Skipping Drift registration on web');
    print('    - GasometerDatabase will not be available');
    print('    - Repositories will work with null database (returning empty lists)');
    print('    - Use Firestore as backend instead');
    
    // Registra AuthRepository manualmente na web (sem DataCleanerService)
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: getIt<AuthRemoteDataSource>(),
          localDataSource: getIt<AuthLocalDataSource>(),
          dataCleanerService: null, // Null na web
        ),
      );
      print('✅ [DatabaseModule] AuthRepository (Web - no cleaner) registered');
    }
    return;
  }

  print('📦 [DatabaseModule] Registering Drift database for mobile/desktop');
  
  // Registra o banco de dados apenas em plataformas que suportam Drift
  if (!getIt.isRegistered<GasometerDatabase>()) {
    getIt.registerSingleton<GasometerDatabase>(
      GasometerDatabase.production(),
    );
    print('✅ [DatabaseModule] GasometerDatabase registered');
  }

  // Registra DataCleanerService (depende de GasometerDatabase)
  if (!getIt.isRegistered<DataCleanerService>()) {
    final db = getIt<GasometerDatabase>();
    getIt.registerLazySingleton<DataCleanerService>(
      () => DataCleanerService(db),
    );
    print('✅ [DatabaseModule] DataCleanerService registered');
  }
  
  // Registra AuthRepository manualmente (mobile/desktop com DataCleanerService)
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
        dataCleanerService: getIt<DataCleanerService>(),
      ),
    );
    print('✅ [DatabaseModule] AuthRepository (with cleaner) registered');
  }

  // Registra todos os repositórios
  if (!getIt.isRegistered<VehicleRepository>()) {
    final db = getIt<GasometerDatabase>();
    getIt.registerSingleton<VehicleRepository>(VehicleRepository(db));
    getIt.registerSingleton<FuelSupplyRepository>(FuelSupplyRepository(db));
    getIt.registerSingleton<MaintenanceRepository>(MaintenanceRepository(db));
    getIt.registerSingleton<ExpenseRepository>(ExpenseRepository(db));
    getIt.registerSingleton<OdometerReadingRepository>(
      OdometerReadingRepository(db),
    );
    getIt.registerSingleton<AuditTrailRepository>(AuditTrailRepository(db));
    print('✅ [DatabaseModule] All repositories registered');
  }
}
