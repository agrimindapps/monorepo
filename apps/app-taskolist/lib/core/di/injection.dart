import 'package:core/core.dart' hide Column;

import '../../database/taskolist_database.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register Drift database (singleton)
  getIt.registerLazySingleton<TaskolistDatabase>(
    () => TaskolistDatabase(),
  );

  // Registrar manualmente ConnectivityService (singleton do core package)
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService.instance,
  );

  // Inicializar injetáveis gerados
  await getIt.init();
}
