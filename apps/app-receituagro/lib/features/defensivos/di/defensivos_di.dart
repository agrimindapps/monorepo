import 'package:get_it/get_it.dart';

// Domain
import '../domain/repositories/i_defensivos_repository.dart';
import '../domain/usecases/get_defensivos_usecase.dart';

// Data
import '../data/repositories/defensivos_repository_impl.dart';

// Presentation
import '../presentation/providers/defensivos_provider.dart';
import '../presentation/providers/home_defensivos_provider.dart';

/// Configuração de injeção de dependências para o módulo Defensivos
/// Segue padrão Clean Architecture + GetIt para DI
void configureDefensivosDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<IDefensivosRepository>(
    () => DefensivosRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetDefensivosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosByClasseUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchDefensivosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosRecentesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosStatsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClassesAgronomicasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFabricantesUseCase(getIt()));

  // Providers
  getIt.registerFactory(() => DefensivosProvider(
    getDefensivosUseCase: getIt(),
    getDefensivosByClasseUseCase: getIt(),
    searchDefensivosUseCase: getIt(),
    getClassesAgronomicasUseCase: getIt(),
    getFabricantesUseCase: getIt(),
  ));

  getIt.registerFactory(() => HomeDefensivosProvider(
    getDefensivosRecentesUseCase: getIt(),
    getDefensivosStatsUseCase: getIt(),
    searchDefensivosUseCase: getIt(),
  ));
}