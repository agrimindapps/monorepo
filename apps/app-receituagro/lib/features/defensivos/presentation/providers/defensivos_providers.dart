import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide Ref;
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../../core/providers/premium_providers.dart';
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

/// Bridge Provider for FitossanitariosRepository
@Riverpod(keepAlive: true)
FitossanitariosRepository fitossanitariosRepository(
    FitossanitariosRepositoryRef ref) {
  return ref.watch(fitossanitariosRepositoryProvider);
}

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
    FavoritosRepositorySimplifiedRef ref) {
  return FavoritosRepositorySimplified(
    service: ref.watch(favoritosServiceProvider),
  );
}

// --- Specialized Services ---

@Riverpod(keepAlive: true)
DefensivosGroupingService defensivosGroupingService(
    DefensivosGroupingServiceRef ref) {
  return DefensivosGroupingService();
}

@Riverpod(keepAlive: true)
IDefensivosQueryService defensivosQueryService(Ref ref) {
  return DefensivosQueryService();
}

@Riverpod(keepAlive: true)
IDefensivosSearchService defensivosSearchService(
    DefensivosSearchServiceRef ref) {
  return DefensivosSearchService();
}

@Riverpod(keepAlive: true)
IDefensivosStatsService defensivosStatsService(Ref ref) {
  return DefensivosStatsService();
}

@Riverpod(keepAlive: true)
IDefensivosFilterService defensivosFilterService(
    DefensivosFilterServiceRef ref) {
  return DefensivosFilterService();
}

// --- Repository ---

@Riverpod(keepAlive: true)
IDefensivosRepository defensivosRepository(Ref ref) {
  return DefensivosRepositoryImpl(
    ref.watch(fitossanitariosRepositoryProvider),
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
    GetDefensivosByClasseUseCaseRef ref) {
  return GetDefensivosByClasseUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
SearchDefensivosUseCase searchDefensivosUseCase(
    SearchDefensivosUseCaseRef ref) {
  return SearchDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosRecentesUseCase getDefensivosRecentesUseCase(
    GetDefensivosRecentesUseCaseRef ref) {
  return GetDefensivosRecentesUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosStatsUseCase getDefensivosStatsUseCase(
    GetDefensivosStatsUseCaseRef ref) {
  return GetDefensivosStatsUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetClassesAgronomicasUseCase getClassesAgronomicasUseCase(
    GetClassesAgronomicasUseCaseRef ref) {
  return GetClassesAgronomicasUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetFabricantesUseCase getFabricantesUseCase(Ref ref) {
  return GetFabricantesUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosAgrupadosUseCase getDefensivosAgrupadosUseCase(
    GetDefensivosAgrupadosUseCaseRef ref) {
  return GetDefensivosAgrupadosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosCompletosUseCase getDefensivosCompletosUseCase(
    GetDefensivosCompletosUseCaseRef ref) {
  return GetDefensivosCompletosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosComFiltrosUseCase getDefensivosComFiltrosUseCase(
    GetDefensivosComFiltrosUseCaseRef ref) {
  return GetDefensivosComFiltrosUseCase(
      ref.watch(defensivosRepositoryProvider));
}
