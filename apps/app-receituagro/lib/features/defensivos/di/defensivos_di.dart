import 'package:core/core.dart';

import '../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../data/repositories/defensivos_repository_impl.dart';
import '../data/services/defensivos_filter_service.dart';
import '../data/services/defensivos_query_service.dart';
import '../data/services/defensivos_search_service.dart';
import '../data/services/defensivos_stats_service.dart';
import '../domain/repositories/i_defensivos_repository.dart';
import '../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../domain/usecases/get_defensivos_completos_usecase.dart';
import '../domain/usecases/get_defensivos_usecase.dart';

/// Configuração de injeção de dependências para o módulo Defensivos
///
/// SOLID Refactoring:
/// - Registers specialized services (Query, Search, Stats, Filter)
/// - Follows the pattern established in diagnosticos and comentarios features
/// - Improves testability through dependency injection
///
/// Segue padrão Clean Architecture + GetIt para DI
void configureDefensivosDependencies() {
  final getIt = GetIt.instance;

  // Register specialized services
  if (!getIt.isRegistered<IDefensivosQueryService>()) {
    getIt.registerSingleton<IDefensivosQueryService>(
      DefensivosQueryService(),
    );
  }

  if (!getIt.isRegistered<IDefensivosSearchService>()) {
    getIt.registerSingleton<IDefensivosSearchService>(
      DefensivosSearchService(),
    );
  }

  if (!getIt.isRegistered<IDefensivosStatsService>()) {
    getIt.registerSingleton<IDefensivosStatsService>(
      DefensivosStatsService(),
    );
  }

  if (!getIt.isRegistered<IDefensivosFilterService>()) {
    getIt.registerSingleton<IDefensivosFilterService>(
      DefensivosFilterService(),
    );
  }

  // Register repository with service dependencies
  getIt.registerLazySingleton<IDefensivosRepository>(
    () => DefensivosRepositoryImpl(
      getIt<FitossanitarioHiveRepository>(),
      getIt<IDefensivosQueryService>(),
      getIt<IDefensivosSearchService>(),
      getIt<IDefensivosStatsService>(),
      getIt<IDefensivosFilterService>(),
    ),
  );
  getIt.registerLazySingleton(() => GetDefensivosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosByClasseUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchDefensivosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosRecentesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosStatsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClassesAgronomicasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFabricantesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosAgrupadosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosCompletosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDefensivosComFiltrosUseCase(getIt()));
}
