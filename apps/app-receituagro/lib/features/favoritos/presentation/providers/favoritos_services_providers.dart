import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart';
import '../../data/factories/favorito_entity_factory_registry.dart';
import '../../data/services/favoritos_cache_service_inline.dart';
import '../../data/services/favoritos_data_resolver_service.dart';
import '../../data/services/favoritos_data_resolver_strategy.dart';
import '../../data/services/favoritos_error_message_service.dart';
import '../../data/services/favoritos_service.dart';
import '../../data/services/favoritos_sync_service.dart';
import '../../data/services/favoritos_validator_service.dart';

part 'favoritos_services_providers.g.dart';

// --- Error Message Service ---
@riverpod
FavoritosErrorMessageService favoritosErrorMessageService(Ref ref) {
  return FavoritosErrorMessageService();
}

// --- Cache Service ---
@Riverpod(keepAlive: true)
FavoritosCacheServiceInline favoritosCacheService(Ref ref) {
  return FavoritosCacheServiceInline();
}

// --- Entity Factory Registry ---
@riverpod
IFavoritoEntityFactoryRegistry favoritoEntityFactoryRegistry(Ref ref) {
  return FavoritoEntityFactoryRegistry();
}

// --- Data Resolver Strategy Registry ---
@riverpod
FavoritosDataResolverStrategyRegistry favoritosDataResolverStrategyRegistry(Ref ref) {
  return FavoritosDataResolverStrategyRegistry(
    defensivoStrategy: DefensivoResolverStrategy(ref.watch(fitossanitariosRepositoryProvider)),
    pragaStrategy: PragaResolverStrategy(ref.watch(pragasRepositoryProvider)),
    diagnosticoStrategy: DiagnosticoResolverStrategy(
      ref.watch(diagnosticoRepositoryProvider),
      ref.watch(pragasRepositoryProvider),
      ref.watch(fitossanitariosRepositoryProvider),
      ref.watch(culturasRepositoryProvider),
    ),
    culturaStrategy: CulturaResolverStrategy(ref.watch(culturasRepositoryProvider)),
  );
}

// --- Data Resolver Service ---
@riverpod
FavoritosDataResolverService favoritosDataResolverService(Ref ref) {
  return FavoritosDataResolverService(
    registry: ref.watch(favoritosDataResolverStrategyRegistryProvider),
  );
}

// --- Validator Service ---
@riverpod
FavoritosValidatorService favoritosValidatorService(Ref ref) {
  return FavoritosValidatorService(
    dataResolver: ref.watch(favoritosDataResolverServiceProvider),
  );
}

// --- Sync Service ---
@riverpod
FavoritosSyncService favoritosSyncService(Ref ref) {
  return FavoritosSyncService(
    dataResolver: ref.watch(favoritosDataResolverServiceProvider),
  );
}

// --- Main Favoritos Service ---
@Riverpod(keepAlive: true)
FavoritosService favoritosService(Ref ref) {
  return FavoritosService(
    dataResolver: ref.watch(favoritosDataResolverServiceProvider),
    validator: ref.watch(favoritosValidatorServiceProvider),
    syncService: ref.watch(favoritosSyncServiceProvider),
    cache: ref.watch(favoritosCacheServiceProvider),
    factoryRegistry: ref.watch(favoritoEntityFactoryRegistryProvider),
    repository: ref.watch(favoritoRepositoryProvider),
  );
}
