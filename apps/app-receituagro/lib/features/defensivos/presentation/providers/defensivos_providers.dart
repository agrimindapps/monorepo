import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart' as core_providers;
import '../../../../core/providers/premium_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../comentarios/presentation/providers/comentarios_mapper_provider.dart';
import '../../../comentarios/presentation/providers/comentarios_providers.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/presentation/providers/favoritos_services_providers.dart';
import '../../data/repositories/defensivos_repository_impl.dart';
import '../../data/services/defensivos_filter_service.dart';
import '../../data/services/defensivos_grouping_service.dart';
import '../../data/services/defensivos_query_service.dart';
import '../../data/services/defensivos_search_service.dart';
import '../../data/services/defensivos_stats_service.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../../domain/usecases/get_defensivos_completos_usecase.dart';
import '../../domain/usecases/get_defensivos_usecase.dart';

part 'defensivos_providers.g.dart';

/// Bridge Provider for ComentariosService
@riverpod
ComentariosService comentariosService(Ref ref) {
  return ComentariosService(
    repository: ref.watch(iComentariosRepositoryProvider),
    premiumService: ref.watch(premiumServiceProvider),
    mapper: ref.watch(comentariosMapperProvider),
  );
}

/// Bridge Provider for FavoritosRepositorySimplified
@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(
    Ref ref) {
  return FavoritosRepositorySimplified(
    service: ref.watch(favoritosServiceProvider),
  );
}

// --- Specialized Services ---

@riverpod
DefensivosGroupingService defensivosGroupingService(
    Ref ref) {
  return DefensivosGroupingService();
}

@riverpod
IDefensivosQueryService defensivosQueryService(Ref ref) {
  return DefensivosQueryService();
}

@riverpod
IDefensivosSearchService defensivosSearchService(
    Ref ref) {
  return DefensivosSearchService();
}

@riverpod
IDefensivosStatsService defensivosStatsService(Ref ref) {
  return DefensivosStatsService();
}

@riverpod
IDefensivosFilterService defensivosFilterService(
    Ref ref) {
  return DefensivosFilterService();
}

// --- Repository ---

@riverpod
IDefensivosRepository defensivosRepository(Ref ref) {
  return DefensivosRepositoryImpl(
    ref.watch(core_providers.fitossanitariosRepositoryProvider),
    ref.watch(fitossanitariosInfoRepositoryProvider),
    ref.watch(defensivosQueryServiceProvider),
    ref.watch(defensivosSearchServiceProvider),
    ref.watch(defensivosStatsServiceProvider),
    ref.watch(defensivosFilterServiceProvider),
  );
}

// --- Use Cases ---

@riverpod
GetDefensivosUseCase getDefensivosUseCase(Ref ref) {
  return GetDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
}

@riverpod
GetDefensivosAgrupadosUseCase getDefensivosAgrupadosUseCase(
    Ref ref) {
  return GetDefensivosAgrupadosUseCase(ref.watch(defensivosRepositoryProvider));
}

@riverpod
GetDefensivosCompletosUseCase getDefensivosCompletosUseCase(
    Ref ref) {
  return GetDefensivosCompletosUseCase(ref.watch(defensivosRepositoryProvider));
}

@riverpod
GetDefensivosComFiltrosUseCase getDefensivosComFiltrosUseCase(
    Ref ref) {
  return GetDefensivosComFiltrosUseCase(
      ref.watch(defensivosRepositoryProvider));
}
