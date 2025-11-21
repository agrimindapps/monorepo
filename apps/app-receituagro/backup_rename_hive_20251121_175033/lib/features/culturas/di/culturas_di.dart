import 'package:core/core.dart' hide Column;

import '../data/repositories/culturas_repository_impl.dart';
import '../data/services/culturas_query_service.dart';
import '../data/services/culturas_search_service.dart';
import '../domain/repositories/i_culturas_repository.dart';
import '../domain/usecases/get_culturas_usecase.dart';

/// Configuração de injeção de dependências para o módulo Culturas
///
/// SOLID Refactoring:
/// - Registers specialized services (Query, Search)
/// - Follows the pattern established in other features
/// - Improves testability through dependency injection
/// - Fixed getGruposCulturas() which was returning empty list
///
/// Segue padrão Clean Architecture + GetIt para DI
void configureCulturasDependencies() {
  final getIt = GetIt.instance;

  // Register specialized services
  if (!getIt.isRegistered<ICulturasQueryService>()) {
    getIt.registerSingleton<ICulturasQueryService>(CulturasQueryService());
  }

  if (!getIt.isRegistered<ICulturasSearchService>()) {
    getIt.registerSingleton<ICulturasSearchService>(CulturasSearchService());
  }

  // Register repository with service dependencies
  getIt.registerLazySingleton<ICulturasRepository>(
    () => CulturasRepositoryImpl(
      getIt(),
      getIt<ICulturasQueryService>(),
      getIt<ICulturasSearchService>(),
    ),
  );
  getIt.registerLazySingleton(() => GetCulturasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCulturasByGrupoUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchCulturasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetGruposCulturasUseCase(getIt()));
}
