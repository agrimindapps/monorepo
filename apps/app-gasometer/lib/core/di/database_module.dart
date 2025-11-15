import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../database/gasometer_database.dart';
import '../../database/repositories/repositories.dart';

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
