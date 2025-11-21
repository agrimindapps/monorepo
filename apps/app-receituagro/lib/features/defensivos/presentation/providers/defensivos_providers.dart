import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/favoritos_di.dart';
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

part 'defensivos_providers.g.dart';

/// Bridge Provider for FitossanitariosRepository
@Riverpod(keepAlive: true)
FitossanitariosRepository fitossanitariosRepository(FitossanitariosRepositoryRef ref) {
  return di.sl<FitossanitariosRepository>();
}

/// Bridge Provider for ComentariosService
@Riverpod(keepAlive: true)
ComentariosService comentariosService(ComentariosServiceRef ref) {
  return di.sl<ComentariosService>();
}

/// Bridge Provider for FavoritosRepositorySimplified
@Riverpod(keepAlive: true)
FavoritosRepositorySimplified favoritosRepositorySimplified(FavoritosRepositorySimplifiedRef ref) {
  return FavoritosDI.get<FavoritosRepositorySimplified>();
}

/// Bridge Provider for FailureMessageService
@Riverpod(keepAlive: true)
FailureMessageService failureMessageService(FailureMessageServiceRef ref) {
  return di.sl<FailureMessageService>();
}

// --- Specialized Services ---

@Riverpod(keepAlive: true)
IDefensivosQueryService defensivosQueryService(DefensivosQueryServiceRef ref) {
  return DefensivosQueryService();
}

@Riverpod(keepAlive: true)
IDefensivosSearchService defensivosSearchService(DefensivosSearchServiceRef ref) {
  return DefensivosSearchService();
}

@Riverpod(keepAlive: true)
IDefensivosStatsService defensivosStatsService(DefensivosStatsServiceRef ref) {
  return DefensivosStatsService();
}

@Riverpod(keepAlive: true)
IDefensivosFilterService defensivosFilterService(DefensivosFilterServiceRef ref) {
  return DefensivosFilterService();
}

// --- Repository ---

@Riverpod(keepAlive: true)
IDefensivosRepository defensivosRepository(DefensivosRepositoryRef ref) {
  return DefensivosRepositoryImpl(
    ref.watch(fitossanitariosRepositoryProvider),
    ref.watch(defensivosQueryServiceProvider),
    ref.watch(defensivosSearchServiceProvider),
    ref.watch(defensivosStatsServiceProvider),
    ref.watch(defensivosFilterServiceProvider),
  );
}

// --- Use Cases ---

@Riverpod(keepAlive: true)
GetDefensivosUseCase getDefensivosUseCase(GetDefensivosUseCaseRef ref) {
  return GetDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosByClasseUseCase getDefensivosByClasseUseCase(GetDefensivosByClasseUseCaseRef ref) {
  return GetDefensivosByClasseUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
SearchDefensivosUseCase searchDefensivosUseCase(SearchDefensivosUseCaseRef ref) {
  return SearchDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosRecentesUseCase getDefensivosRecentesUseCase(GetDefensivosRecentesUseCaseRef ref) {
  return GetDefensivosRecentesUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosStatsUseCase getDefensivosStatsUseCase(GetDefensivosStatsUseCaseRef ref) {
  return GetDefensivosStatsUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetClassesAgronomicasUseCase getClassesAgronomicasUseCase(GetClassesAgronomicasUseCaseRef ref) {
  return GetClassesAgronomicasUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetFabricantesUseCase getFabricantesUseCase(GetFabricantesUseCaseRef ref) {
  return GetFabricantesUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosAgrupadosUseCase getDefensivosAgrupadosUseCase(GetDefensivosAgrupadosUseCaseRef ref) {
  return GetDefensivosAgrupadosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosCompletosUseCase getDefensivosCompletosUseCase(GetDefensivosCompletosUseCaseRef ref) {
  return GetDefensivosCompletosUseCase(ref.watch(defensivosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDefensivosComFiltrosUseCase getDefensivosComFiltrosUseCase(GetDefensivosComFiltrosUseCaseRef ref) {
  return GetDefensivosComFiltrosUseCase(ref.watch(defensivosRepositoryProvider));
}
