import 'package:get_it/get_it.dart';

import 'data/repositories/favoritos_repository_impl.dart';
import 'data/services/favoritos_storage_service.dart';
import 'domain/repositories/i_favoritos_repository.dart';
import 'domain/usecases/favoritos_usecases.dart';
import 'presentation/providers/favoritos_provider.dart';

/// Configuração Simplificada de DI para Favoritos
/// Consolida services similares e remove complexidade desnecessária
class FavoritosDISimplified {
  static final GetIt _getIt = GetIt.instance;

  /// Registra dependências de forma simplificada
  static void registerDependencies() {
    _registerCoreServices();
    _registerRepositories();
    _registerUseCases();
    _registerProviders();
  }

  /// Registra apenas services essenciais
  static void _registerCoreServices() {
    // Storage consolidado (Hive + Cache interno)
    _getIt.registerLazySingleton<IFavoritosStorage>(
      () => FavoritosStorageService(),
    );

    // Cache integrado no storage
    _getIt.registerLazySingleton<IFavoritosCache>(
      () => FavoritosCacheService(),
    );

    // Data resolver consolidado
    _getIt.registerLazySingleton<IFavoritosDataResolver>(
      () => FavoritosDataResolverService(),
    );

    // Factory consolidado
    _getIt.registerLazySingleton<IFavoritosEntityFactory>(
      () => FavoritosEntityFactoryService(),
    );

    // Validator consolidado (opcional - pode ser removido)
    _getIt.registerLazySingleton<IFavoritosValidator>(
      () => FavoritosValidatorService(),
    );
  }

  /// Registra apenas repositórios essenciais
  static void _registerRepositories() {
    // Repositórios específicos (simplificados)
    _getIt.registerLazySingleton<IFavoritosDefensivosRepository>(
      () => FavoritosDefensivosRepositoryImpl(
        storage: _getIt<IFavoritosStorage>(),
        dataResolver: _getIt<IFavoritosDataResolver>(),
        entityFactory: _getIt<IFavoritosEntityFactory>(),
        cache: _getIt<IFavoritosCache>(),
      ),
    );

    _getIt.registerLazySingleton<IFavoritosPragasRepository>(
      () => FavoritosPragasRepositoryImpl(
        storage: _getIt<IFavoritosStorage>(),
        dataResolver: _getIt<IFavoritosDataResolver>(),
        entityFactory: _getIt<IFavoritosEntityFactory>(),
        cache: _getIt<IFavoritosCache>(),
      ),
    );

    _getIt.registerLazySingleton<IFavoritosDiagnosticosRepository>(
      () => FavoritosDiagnosticosRepositoryImpl(
        storage: _getIt<IFavoritosStorage>(),
        dataResolver: _getIt<IFavoritosDataResolver>(),
        entityFactory: _getIt<IFavoritosEntityFactory>(),
      ),
    );

    _getIt.registerLazySingleton<IFavoritosCulturasRepository>(
      () => FavoritosCulturasRepositoryImpl(
        storage: _getIt<IFavoritosStorage>(),
        dataResolver: _getIt<IFavoritosDataResolver>(),
        entityFactory: _getIt<IFavoritosEntityFactory>(),
      ),
    );

    // Repositório principal agregado
    _getIt.registerLazySingleton<IFavoritosRepository>(
      () => FavoritosRepositoryImpl(
        defensivosRepository: _getIt<IFavoritosDefensivosRepository>(),
        pragasRepository: _getIt<IFavoritosPragasRepository>(),
        diagnosticosRepository: _getIt<IFavoritosDiagnosticosRepository>(),
        culturasRepository: _getIt<IFavoritosCulturasRepository>(),
      ),
    );
  }

  /// Registra apenas Use Cases essenciais
  static void _registerUseCases() {
    // Use Cases de leitura
    _getIt.registerLazySingleton<GetAllFavoritosUseCase>(
      () => GetAllFavoritosUseCase(repository: _getIt<IFavoritosRepository>()),
    );

    _getIt.registerLazySingleton<GetDefensivosFavoritosUseCase>(
      () => GetDefensivosFavoritosUseCase(repository: _getIt<IFavoritosDefensivosRepository>()),
    );

    _getIt.registerLazySingleton<GetPragasFavoritosUseCase>(
      () => GetPragasFavoritosUseCase(repository: _getIt<IFavoritosPragasRepository>()),
    );

    _getIt.registerLazySingleton<GetDiagnosticosFavoritosUseCase>(
      () => GetDiagnosticosFavoritosUseCase(repository: _getIt<IFavoritosDiagnosticosRepository>()),
    );

    _getIt.registerLazySingleton<GetCulturasFavoritosUseCase>(
      () => GetCulturasFavoritosUseCase(repository: _getIt<IFavoritosCulturasRepository>()),
    );

    // Use Cases de ação consolidados
    _getIt.registerLazySingleton<ToggleFavoritoUseCase>(
      () => ToggleFavoritoUseCase(
        defensivosRepository: _getIt<IFavoritosDefensivosRepository>(),
        pragasRepository: _getIt<IFavoritosPragasRepository>(),
        diagnosticosRepository: _getIt<IFavoritosDiagnosticosRepository>(),
        culturasRepository: _getIt<IFavoritosCulturasRepository>(),
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    // Use Cases utilitários essenciais
    _getIt.registerLazySingleton<IsFavoritoUseCase>(
      () => IsFavoritoUseCase(repository: _getIt<IFavoritosRepository>()),
    );

    _getIt.registerLazySingleton<SearchFavoritosUseCase>(
      () => SearchFavoritosUseCase(repository: _getIt<IFavoritosRepository>()),
    );

    _getIt.registerLazySingleton<GetFavoritosStatsUseCase>(
      () => GetFavoritosStatsUseCase(repository: _getIt<IFavoritosRepository>()),
    );
  }

  /// Registra Provider (factory para evitar singletons de UI)
  static void _registerProviders() {
    _getIt.registerFactory<FavoritosProvider>(
      () => FavoritosProvider(
        getAllFavoritosUseCase: _getIt<GetAllFavoritosUseCase>(),
        getDefensivosFavoritosUseCase: _getIt<GetDefensivosFavoritosUseCase>(),
        getPragasFavoritosUseCase: _getIt<GetPragasFavoritosUseCase>(),
        getDiagnosticosFavoritosUseCase: _getIt<GetDiagnosticosFavoritosUseCase>(),
        getCulturasFavoritosUseCase: _getIt<GetCulturasFavoritosUseCase>(),
        isFavoritoUseCase: _getIt<IsFavoritoUseCase>(),
        toggleFavoritoUseCase: _getIt<ToggleFavoritoUseCase>(),
        searchFavoritosUseCase: _getIt<SearchFavoritosUseCase>(),
        getFavoritosStatsUseCase: _getIt<GetFavoritosStatsUseCase>(),
      ),
    );
  }

  /// Limpeza simplificada
  static void clearDependencies() {
    try {
      // Remove Provider
      _getIt.unregister<FavoritosProvider>();
      
      // Remove Use Cases
      _getIt.unregister<GetAllFavoritosUseCase>();
      _getIt.unregister<GetDefensivosFavoritosUseCase>();
      _getIt.unregister<GetPragasFavoritosUseCase>();
      _getIt.unregister<GetDiagnosticosFavoritosUseCase>();
      _getIt.unregister<GetCulturasFavoritosUseCase>();
      _getIt.unregister<ToggleFavoritoUseCase>();
      _getIt.unregister<IsFavoritoUseCase>();
      _getIt.unregister<SearchFavoritosUseCase>();
      _getIt.unregister<GetFavoritosStatsUseCase>();
      
      // Remove Repositories
      _getIt.unregister<IFavoritosRepository>();
      _getIt.unregister<IFavoritosDefensivosRepository>();
      _getIt.unregister<IFavoritosPragasRepository>();
      _getIt.unregister<IFavoritosDiagnosticosRepository>();
      _getIt.unregister<IFavoritosCulturasRepository>();
      
      // Remove Services
      _getIt.unregister<IFavoritosStorage>();
      _getIt.unregister<IFavoritosCache>();
      _getIt.unregister<IFavoritosDataResolver>();
      _getIt.unregister<IFavoritosEntityFactory>();
      _getIt.unregister<IFavoritosValidator>();
    } catch (e) {
      // Ignora erros de unregister (dependências já podem estar removidas)
    }
  }

  /// Getter simplificado
  static T get<T extends Object>() => _getIt.get<T>();

  /// Verificação de registro
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}

/// Extension para facilitar uso
extension FavoritosDISimplifiedExtension on GetIt {
  FavoritosProvider get favoritosProvider => get<FavoritosProvider>();
}