import 'package:get_it/get_it.dart';
import '../../database/gasometer_database.dart';
import '../../database/repositories/repositories.dart';

/// Módulo para registrar o banco de dados e repositórios
/// 
/// Funciona em todas as plataformas:
/// - Mobile/Desktop: SQLite nativo via drift
/// - Web: WASM + IndexedDB via drift
final getIt = GetIt.instance;

/// Registra o GasometerDatabase e repositórios
/// 
/// Deve ser chamado APÓS outras dependências terem sido registradas
void registerDatabaseModule() {
  print('📦 [DatabaseModule] Registering Drift database for all platforms');
  print('    - Mobile/Desktop: SQLite nativo');
  print('    - Web: WASM + IndexedDB');
  
  // Registra o banco de dados em todas as plataformas
  if (!getIt.isRegistered<GasometerDatabase>()) {
    getIt.registerSingleton<GasometerDatabase>(
      GasometerDatabase.production(),
    );
    print('✅ [DatabaseModule] GasometerDatabase registered');
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
