import 'package:core/core.dart';
import '../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../data/repositories/defensivos_repository_impl.dart';
import '../domain/repositories/i_defensivos_repository.dart';
import '../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../domain/usecases/get_defensivos_completos_usecase.dart';
import '../domain/usecases/get_defensivos_usecase.dart';

/// Configuração de injeção de dependências para o módulo Defensivos
/// Segue padrão Clean Architecture + GetIt para DI
void configureDefensivosDependencies() {
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<IDefensivosRepository>(
    () => DefensivosRepositoryImpl(getIt<FitossanitarioHiveRepository>()),
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