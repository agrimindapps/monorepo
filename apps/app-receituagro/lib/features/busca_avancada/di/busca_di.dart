import 'package:get_it/get_it.dart';

// Domain
import '../domain/repositories/i_busca_repository.dart';
import '../domain/usecases/busca_usecase.dart';

// Data
import '../data/repositories/busca_repository_impl.dart';

// Presentation
import '../presentation/providers/busca_avancada_provider.dart';

/// Configuração de injeção de dependências para o módulo Busca Avançada
/// Segue padrão Clean Architecture + GetIt para DI
void configureBuscaDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<IBuscaRepository>(
    () => BuscaRepositoryImpl(
      getIt(), // DiagnosticoCoreRepository
      getIt(), // PragasCoreRepository
      getIt(), // FitossanitarioCoreRepository
      getIt(), // CulturaCoreRepository
      getIt(), // DiagnosticoIntegrationService
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => BuscarComFiltrosUseCase(getIt()));
  getIt.registerLazySingleton(() => BuscarPorTextoUseCase(getIt()));
  getIt.registerLazySingleton(() => GetBuscaMetadosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSugestoesUseCase(getIt()));
  getIt.registerLazySingleton(() => BuscarDiagnosticosUseCase(getIt()));
  getIt.registerLazySingleton(() => GetHistoricoBuscaUseCase(getIt()));
  getIt.registerLazySingleton(() => LimparCacheUseCase(getIt()));

  // Provider (mantém o existente mas com nova arquitetura)
  getIt.registerFactory(() => BuscaAvancadaProvider(
    buscarComFiltrosUseCase: getIt(),
    buscarPorTextoUseCase: getIt(),
    getMetadosUseCase: getIt(),
    getSugestoesUseCase: getIt(),
    getHistoricoUseCase: getIt(),
    limparCacheUseCase: getIt(),
  ));
}