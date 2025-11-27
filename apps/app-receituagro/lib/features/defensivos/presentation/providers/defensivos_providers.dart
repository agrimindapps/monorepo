import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide Ref;
import '../../../../database/providers/database_providers.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../../core/providers/premium_providers.dart';
import '../../../../core/providers/core_providers.dart' as core_providers;
import '../../../comentarios/presentation/providers/comentarios_mapper_provider.dart';
import '../../../comentarios/presentation/providers/comentarios_providers.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/presentation/providers/favoritos_services_providers.dart';
import '../../data/repositories/defensivos_repository_impl.dart';
import '../../data/services/defensivos_filter_service.dart';
import '../../data/services/defensivos_query_service.dart';
import '../../data/services/defensivos_search_service.dart';
import '../../data/services/defensivos_stats_service.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../../domain/usecases/get_defensivos_completos_usecase.dart';
import '../../domain/usecases/get_defensivos_usecase.dart';
import '../../data/services/defensivos_grouping_service.dart';

part 'defensivos_providers.g.dart';

/// Bridge Provider for ComentariosService
@Riverpod(keepAlive: true)
ComentariosService comentariosService(Ref ref) {
  return ComentariosService(
    repository: ref.watch(iComentariosRepositoryProvider),
    premiumService: ref.watch(premiumServiceProvider),
    mapper: ref.watch(comentariosMapperProvider),
  );
}

/// Bridge Provider for FavoritosRepositorySimplified
@Riverpod(keepAlive: true)
FavoritosRepositorySimplified favoritosRepositorySimplified(
    Ref ref) {
  return FavoritosRepositorySimplified(
    service: ref.watch(favoritosServiceProvider),
  );
}

// --- Specialized Services ---

@Riverpod(keepAlive: true)
DefensivosGroupingService defensivosGroupingService(
    Ref ref) {
  return DefensivosGroupingService();
}

@Riverpod(keepAlive: true)
IDefensivosQueryService defensivosQueryService(Ref ref) {
  return DefensivosQueryService();
}

@Riverpod(keepAlive: true)
IDefensivosSearchService defensivosSearchService(
    Ref ref) {
  return DefensivosSearchService();
}

@Riverpod(keepAlive: true)
IDefensivosStatsService defensivosStatsService(Ref ref) {
  return DefensivosStatsService();
}

@Riverpod(keepAlive: true)
IDefensivosFilterService defensivosFilterService(
    Ref ref) {
  return DefensivosFilterService();
}

// --- Repository ---

@Riverpod(keepAlive: true)
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

@Riverpod(keepAlive: true)
GetDefensivosUseCase getDefensivosUseCase(Ref ref) {
  return GetDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosByClasseUseCase getDefensivosByClasseUseCase(
    Ref ref) {
  return GetDefensivosByClasseUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
SearchDefensivosUseCase searchDefensivosUseCase(
    Ref ref) {
  return SearchDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosRecentesUseCase getDefensivosRecentesUseCase(
    Ref ref) {
  return GetDefensivosRecentesUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosStatsUseCase getDefensivosStatsUseCase(
    Ref ref) {
  return GetDefensivosStatsUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetClassesAgronomicasUseCase getClassesAgronomicasUseCase(
    Ref ref) {
  return GetClassesAgronomicasUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetFabricantesUseCase getFabricantesUseCase(Ref ref) {
  return GetFabricantesUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosAgrupadosUseCase getDefensivosAgrupadosUseCase(
    Ref ref) {
  return GetDefensivosAgrupadosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosCompletosUseCase getDefensivosCompletosUseCase(
    Ref ref) {
  return GetDefensivosCompletosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosComFiltrosUseCase getDefensivosComFiltrosUseCase(
    Ref ref) {
  return GetDefensivosComFiltrosUseCase(
      ref.watch(defensivosRepositoryProvider));
}
