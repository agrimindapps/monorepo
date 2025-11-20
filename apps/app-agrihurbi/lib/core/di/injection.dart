import 'package:core/core.dart';

import '../../database/agrihurbi_database.dart';
import '../../features/livestock/data/datasources/livestock_local_datasource.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Inicializar Injectable gerado
  await getIt.init();

  // Registrar Drift Database manualmente (não pode estar em @module)
  getIt.registerSingleton<AgrihurbiDatabase>(AgrihurbiDatabase.production());

  // Registrar Drift Local Data Source
  getIt.registerSingleton<LivestockLocalDataSource>(
    LivestockDriftLocalDataSource(getIt<AgrihurbiDatabase>()),
  );
}
