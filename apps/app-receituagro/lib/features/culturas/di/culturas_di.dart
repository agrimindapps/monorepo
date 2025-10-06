import 'package:core/core.dart';
import '../data/repositories/culturas_repository_impl.dart';
import '../domain/repositories/i_culturas_repository.dart';
import '../domain/usecases/get_culturas_usecase.dart';

/// Configuração de injeção de dependências para o módulo Culturas
/// Segue padrão Clean Architecture + GetIt para DI
void configureCulturasDependencies() {
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<ICulturasRepository>(
    () => CulturasRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetCulturasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCulturasByGrupoUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchCulturasUseCase(getIt()));
  getIt.registerLazySingleton(() => GetGruposCulturasUseCase(getIt()));
}