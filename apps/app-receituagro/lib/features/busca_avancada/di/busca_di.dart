
// Data
// Domain
// Presentation

/// Configuração de injeção de dependências para o módulo Busca Avançada
/// Segue padrão Clean Architecture + GetIt para DI
/// 
/// TODO: Temporariamente desabilitado - removendo sistema de cache complexo
/// Focando em simplificar o acesso direto ao Hive
void configureBuscaDependencies() {
  // final getIt = GetIt.instance;

  // // Repository
  // getIt.registerLazySingleton<IBuscaRepository>(
  //   () => BuscaRepositoryImpl(
  //     getIt(), // DiagnosticoHiveRepository (simplified)
  //     getIt(), // PragasHiveRepository
  //     getIt(), // FitossanitarioHiveRepository  
  //     getIt(), // CulturaHiveRepository
  //     getIt(), // DiagnosticoIntegrationService
  //   ),
  // );

  // // Use Cases
  // getIt.registerLazySingleton(() => BuscarComFiltrosUseCase(getIt()));
  // getIt.registerLazySingleton(() => BuscarPorTextoUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetBuscaMetadosUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetSugestoesUseCase(getIt()));
  // getIt.registerLazySingleton(() => BuscarDiagnosticosUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetHistoricoBuscaUseCase(getIt()));
  // getIt.registerLazySingleton(() => LimparCacheUseCase(getIt()));

  // // Provider (usando o construtor atual sem parâmetros)
  // getIt.registerFactory(() => BuscaAvancadaProvider());
}