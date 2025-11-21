import '../../database/gasometer_database.dart';
import '../../database/repositories/repositories.dart';

/// ⚠️ DEPRECATED MODULE - DO NOT USE
///
/// Este módulo está DEPRECATED e NÃO deve ser usado.
/// O GasometerDatabase agora é registrado automaticamente via 
/// pelo injectable/build_runner em injection.config.dart.
///
/// O Riverpod provider (gasometerDatabaseProvider) acessa a instância via GetIt.I<>().
///
/// Se você precisar da instância do banco:
/// - Via GetIt: `GetIt.I<GasometerDatabase>()`
/// - Via Riverpod: `ref.watch(gasometerDatabaseProvider)`
///
/// Ambos retornam a MESMA instância singleton para evitar race conditions.

final getIt = GetIt.instance;

@Deprecated('Use  no GasometerDatabase + injectable')
void registerDatabaseModule() {
  print('📦 [DatabaseModule] Registering Drift database for all platforms');
  print('    - Mobile/Desktop: SQLite nativo');
  print('    - Web: WASM + IndexedDB');
  print('    ⚠️  SINGLE INSTANCE - Shared between GetIt and Riverpod');

  // Registra o banco de dados em todas as plataformas
  if (!getIt.isRegistered<GasometerDatabase>()) {
    getIt.registerSingleton<GasometerDatabase>(GasometerDatabase.production());
    print('✅ [DatabaseModule] GasometerDatabase registered as SINGLETON');
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
