import 'package:get_it/get_it.dart';

import 'data/repositories/favoritos_repository_impl.dart';
import 'data/services/favoritos_storage_service.dart';
import 'domain/repositories/i_favoritos_repository.dart';
import 'domain/usecases/favoritos_usecases.dart';
import 'presentation/providers/favoritos_provider.dart';

/// Configuração de Dependency Injection para o módulo de Favoritos
/// Princípio: Dependency Inversion - Inversão de controle através de DI
class FavoritosDI {
  static final GetIt _getIt = GetIt.instance;

  /// Registra todas as dependências do módulo de favoritos
  static void registerDependencies() {
    _registerServices();
    _registerRepositories();
    _registerUseCases();
    _registerProviders();
  }

  /// Registra os serviços (Data Layer)
  static void _registerServices() {
    // Storage Service
    _getIt.registerLazySingleton<IFavoritosStorage>(
      () => FavoritosStorageService(),
    );

    // Cache Service
    _getIt.registerLazySingleton<IFavoritosCache>(
      () => FavoritosCacheService(),
    );

    // Data Resolver Service
    _getIt.registerLazySingleton<IFavoritosDataResolver>(
      () => FavoritosDataResolverService(),
    );

    // Entity Factory Service
    _getIt.registerLazySingleton<IFavoritosEntityFactory>(
      () => FavoritosEntityFactoryService(),
    );

    // Validator Service
    _getIt.registerLazySingleton<IFavoritosValidator>(
      () => FavoritosValidatorService(),
    );
  }

  /// Registra os repositórios (Data Layer)
  static void _registerRepositories() {
    // Repositórios específicos por tipo
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
        cache: _getIt<IFavoritosCache>(),
      ),
    );

    _getIt.registerLazySingleton<IFavoritosCulturasRepository>(
      () => FavoritosCulturasRepositoryImpl(
        storage: _getIt<IFavoritosStorage>(),
        dataResolver: _getIt<IFavoritosDataResolver>(),
        entityFactory: _getIt<IFavoritosEntityFactory>(),
      ),
    );

    // Repositório principal (agrega todos os tipos)
    _getIt.registerLazySingleton<IFavoritosRepository>(
      () => FavoritosRepositoryImpl(
        defensivosRepository: _getIt<IFavoritosDefensivosRepository>(),
        pragasRepository: _getIt<IFavoritosPragasRepository>(),
        diagnosticosRepository: _getIt<IFavoritosDiagnosticosRepository>(),
        culturasRepository: _getIt<IFavoritosCulturasRepository>(),
      ),
    );
  }

  /// Registra os Use Cases (Domain Layer)
  static void _registerUseCases() {
    // Use Cases de consulta
    _getIt.registerLazySingleton<GetAllFavoritosUseCase>(
      () => GetAllFavoritosUseCase(
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<GetFavoritosByTipoUseCase>(
      () => GetFavoritosByTipoUseCase(
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<GetDefensivosFavoritosUseCase>(
      () => GetDefensivosFavoritosUseCase(
        repository: _getIt<IFavoritosDefensivosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<GetPragasFavoritosUseCase>(
      () => GetPragasFavoritosUseCase(
        repository: _getIt<IFavoritosPragasRepository>(),
      ),
    );

    _getIt.registerLazySingleton<GetDiagnosticosFavoritosUseCase>(
      () => GetDiagnosticosFavoritosUseCase(
        repository: _getIt<IFavoritosDiagnosticosRepository>(),
      ),
    );

    // Use Cases de modificação
    _getIt.registerLazySingleton<AddDefensivoFavoritoUseCase>(
      () => AddDefensivoFavoritoUseCase(
        repository: _getIt<IFavoritosDefensivosRepository>(),
        validator: _getIt<IFavoritosValidator>(),
      ),
    );

    _getIt.registerLazySingleton<RemoveDefensivoFavoritoUseCase>(
      () => RemoveDefensivoFavoritoUseCase(
        repository: _getIt<IFavoritosDefensivosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<AddPragaFavoritoUseCase>(
      () => AddPragaFavoritoUseCase(
        repository: _getIt<IFavoritosPragasRepository>(),
        validator: _getIt<IFavoritosValidator>(),
      ),
    );

    _getIt.registerLazySingleton<RemovePragaFavoritoUseCase>(
      () => RemovePragaFavoritoUseCase(
        repository: _getIt<IFavoritosPragasRepository>(),
      ),
    );

    // Use Cases utilitários
    _getIt.registerLazySingleton<IsFavoritoUseCase>(
      () => IsFavoritoUseCase(
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<ToggleFavoritoUseCase>(
      () => ToggleFavoritoUseCase(
        defensivosRepository: _getIt<IFavoritosDefensivosRepository>(),
        pragasRepository: _getIt<IFavoritosPragasRepository>(),
        diagnosticosRepository: _getIt<IFavoritosDiagnosticosRepository>(),
        culturasRepository: _getIt<IFavoritosCulturasRepository>(),
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<SearchFavoritosUseCase>(
      () => SearchFavoritosUseCase(
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<GetFavoritosStatsUseCase>(
      () => GetFavoritosStatsUseCase(
        repository: _getIt<IFavoritosRepository>(),
      ),
    );

    _getIt.registerLazySingleton<ClearFavoritosByTipoUseCase>(
      () => ClearFavoritosByTipoUseCase(
        storage: _getIt<IFavoritosStorage>(),
      ),
    );

    _getIt.registerLazySingleton<SyncFavoritosUseCase>(
      () => SyncFavoritosUseCase(
        storage: _getIt<IFavoritosStorage>(),
      ),
    );
  }

  /// Registra os Providers (Presentation Layer)
  static void _registerProviders() {
    _getIt.registerFactory<FavoritosProvider>(
      () => FavoritosProvider(
        getAllFavoritosUseCase: _getIt<GetAllFavoritosUseCase>(),
        getFavoritosByTipoUseCase: _getIt<GetFavoritosByTipoUseCase>(),
        getDefensivosFavoritosUseCase: _getIt<GetDefensivosFavoritosUseCase>(),
        getPragasFavoritosUseCase: _getIt<GetPragasFavoritosUseCase>(),
        getDiagnosticosFavoritosUseCase: _getIt<GetDiagnosticosFavoritosUseCase>(),
        isFavoritoUseCase: _getIt<IsFavoritoUseCase>(),
        toggleFavoritoUseCase: _getIt<ToggleFavoritoUseCase>(),
        searchFavoritosUseCase: _getIt<SearchFavoritosUseCase>(),
        getFavoritosStatsUseCase: _getIt<GetFavoritosStatsUseCase>(),
      ),
    );
  }

  /// Limpa todas as dependências registradas
  static void clearDependencies() {
    // Remove apenas as dependências do módulo de favoritos
    _getIt.unregister<FavoritosProvider>();
    
    // Use Cases
    _getIt.unregister<GetAllFavoritosUseCase>();
    _getIt.unregister<GetFavoritosByTipoUseCase>();
    _getIt.unregister<GetDefensivosFavoritosUseCase>();
    _getIt.unregister<GetPragasFavoritosUseCase>();
    _getIt.unregister<GetDiagnosticosFavoritosUseCase>();
    _getIt.unregister<AddDefensivoFavoritoUseCase>();
    _getIt.unregister<RemoveDefensivoFavoritoUseCase>();
    _getIt.unregister<AddPragaFavoritoUseCase>();
    _getIt.unregister<RemovePragaFavoritoUseCase>();
    _getIt.unregister<IsFavoritoUseCase>();
    _getIt.unregister<ToggleFavoritoUseCase>();
    _getIt.unregister<SearchFavoritosUseCase>();
    _getIt.unregister<GetFavoritosStatsUseCase>();
    _getIt.unregister<ClearFavoritosByTipoUseCase>();
    _getIt.unregister<SyncFavoritosUseCase>();
    
    // Repositories
    _getIt.unregister<IFavoritosRepository>();
    _getIt.unregister<IFavoritosDefensivosRepository>();
    _getIt.unregister<IFavoritosPragasRepository>();
    _getIt.unregister<IFavoritosDiagnosticosRepository>();
    _getIt.unregister<IFavoritosCulturasRepository>();
    
    // Services
    _getIt.unregister<IFavoritosStorage>();
    _getIt.unregister<IFavoritosCache>();
    _getIt.unregister<IFavoritosDataResolver>();
    _getIt.unregister<IFavoritosEntityFactory>();
    _getIt.unregister<IFavoritosValidator>();
  }

  /// Getter para acessar instâncias via DI
  static T get<T extends Object>() => _getIt.get<T>();

  /// Getter para verificar se uma dependência está registrada
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}

/// Extension para facilitar uso na UI
extension FavoritosDIExtension on GetIt {
  /// Acesso rápido ao provider de favoritos
  FavoritosProvider get favoritosProvider => get<FavoritosProvider>();
}