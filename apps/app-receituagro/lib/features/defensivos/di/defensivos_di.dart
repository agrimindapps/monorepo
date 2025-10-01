import 'package:core/core.dart';

// Core Repository (Hive implementation)
import '../../../core/data/repositories/fitossanitario_hive_repository.dart';
// Data
import '../data/repositories/defensivos_repository_impl.dart';
// Domain
import '../domain/repositories/i_defensivos_repository.dart';
import '../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../domain/usecases/get_defensivos_completos_usecase.dart';
import '../domain/usecases/get_defensivos_usecase.dart';
// Presentation
import '../presentation/providers/defensivos_provider.dart';
import '../presentation/providers/defensivos_unificado_provider.dart';
import '../presentation/providers/home_defensivos_provider.dart';

/// Configuração de injeção de dependências para o módulo Defensivos
/// Segue padrão Clean Architecture + GetIt para DI
void configureDefensivosDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<IDefensivosRepository>(
    () => DefensivosRepositoryImpl(getIt<FitossanitarioHiveRepository>()),
  );

  // Use Cases - Básicos
  getIt.registerLazySingleton(() => GetDefensivosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosByClasseUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchDefensivosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosRecentesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosStatsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClassesAgronomicasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFabricantesUseCase(getIt()));
  
  // Use Cases - Agrupamentos (Novos)
  getIt.registerLazySingleton(() => GetDefensivosAgrupadosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosCompletosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosComFiltrosUseCase(getIt()));

  // Providers
  getIt.registerFactory(() => DefensivosProvider(
    getDefensivosUseCase: getIt(),
    getDefensivosByClasseUseCase: getIt(),
    searchDefensivosUseCase: getIt(),
    getClassesAgronomicasUseCase: getIt(),
    getFabricantesUseCase: getIt(),
  ));

  getIt.registerFactory(() => HomeDefensivosProvider(
    repository: getIt(),
  ));
  
  // Provider Unificado (Novo)
  getIt.registerFactory(() => DefensivosUnificadoProvider(
    getDefensivosAgrupadosUseCase: getIt(),
    getDefensivosCompletosUseCase: getIt(),
    getDefensivosComFiltrosUseCase: getIt(),
  ));
}