import '../../../core/di/injection_container.dart';
import '../data/repositories/defensivo_details_repository_impl.dart';
import '../domain/repositories/i_defensivo_details_repository.dart';
import '../domain/usecases/get_defensivo_details_usecase.dart';
import '../domain/usecases/get_diagnosticos_usecase.dart';
import '../domain/usecases/toggle_favorite_usecase.dart';
import '../presentation/providers/defensivo_details_provider.dart';
import '../presentation/providers/diagnosticos_provider.dart';
import '../presentation/providers/tab_controller_provider.dart';

/// Configuração de injeção de dependência para DetalheDefensivos
/// Registra todas as dependências seguindo Clean Architecture
void initDefensivoDetailsDI() {
  // Repository
  sl.registerLazySingleton<IDefensivoDetailsRepository>(
    () => DefensivoDetailsRepositoryImpl(),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDefensivoDetailsUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetDiagnosticosUsecase(repository: sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUsecase(repository: sl()));

  // Providers
  sl.registerFactory(() => DefensivoDetailsProvider(
        getDefensivoDetailsUsecase: sl(),
        toggleFavoriteUsecase: sl(),
      ));

  sl.registerFactory(() => DiagnosticosProvider(
        getDiagnosticosUsecase: sl(),
      ));

  sl.registerFactory(() => TabControllerProvider());
}