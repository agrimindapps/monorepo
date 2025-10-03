import 'package:core/core.dart';

// Data
import '../data/repositories/culturas_repository_impl.dart';
// Domain
import '../domain/repositories/i_culturas_repository.dart';
import '../domain/usecases/get_culturas_usecase.dart';
// Presentation
import '../presentation/providers/culturas_notifier.dart';

/// Configuração de injeção de dependências para o módulo Culturas
/// Segue padrão Clean Architecture + GetIt para DI
void configureCulturasDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<ICulturasRepository>(
    () => CulturasRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetCulturasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCulturasByGrupoUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchCulturasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetGruposCulturasUseCase(getIt()));

  // Provider
  getIt.registerFactory(() => CulturasProvider(
    getCulturasUseCase: getIt(),
    getCulturasByGrupoUseCase: getIt(),
    searchCulturasUseCase: getIt(),
    getGruposCulturasUseCase: getIt(),
  ));
}