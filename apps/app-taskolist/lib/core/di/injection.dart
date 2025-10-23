import 'package:core/core.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Registrar manualmente ConnectivityService (singleton do core package)
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService.instance,
  );

  // Inicializar injetáveis gerados
  await getIt.init();
}
