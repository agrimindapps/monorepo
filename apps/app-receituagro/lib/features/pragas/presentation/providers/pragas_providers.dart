import 'package:core/core.dart';

import '../../../../core/services/access_history_service.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/diagnosticos_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../data/repositories/pragas_repository_impl.dart';
import '../../data/services/pragas_error_message_service.dart';
import '../../data/services/pragas_query_service.dart';
import '../../data/services/pragas_search_service.dart';
import '../../data/services/pragas_stats_service.dart';
import '../../data/services/pragas_type_service.dart';
import '../../domain/repositories/i_pragas_repository.dart';
import '../../domain/services/i_pragas_error_message_service.dart';
import '../../domain/services/i_pragas_query_service.dart';
import '../../domain/services/i_pragas_search_service.dart';
import '../../domain/services/i_pragas_stats_service.dart';
import '../../domain/services/i_pragas_type_service.dart';

part 'pragas_providers.g.dart';

@riverpod
IPragasQueryService pragasQueryService(Ref ref) {
  return PragasQueryService();
}

@riverpod
IPragasSearchService pragasSearchService(Ref ref) {
  return PragasSearchService();
}

@riverpod
IPragasStatsService pragasStatsService(Ref ref) {
  return PragasStatsService();
}

@riverpod
IPragasTypeService pragasTypeService(Ref ref) {
  return PragasTypeService();
}

@riverpod
IPragasErrorMessageService pragasErrorMessageService(Ref ref) {
  return PragasErrorMessageService();
}

@riverpod
PragasRepository pragasRepository(Ref ref) {
  return ref.watch(pragasRepositoryProvider);
}

@riverpod
IPragasRepository iPragasRepository(Ref ref) {
  return PragasRepositoryImpl(
    ref.watch(pragasRepositoryProvider),
    ref.watch(pragasQueryServiceProvider),
    ref.watch(pragasSearchServiceProvider),
    ref.watch(pragasStatsServiceProvider),
    ref.watch(pragasErrorMessageServiceProvider),
  );
}

@riverpod
AccessHistoryService accessHistoryService(Ref ref) {
  return AccessHistoryService();
}

@riverpod
CulturasRepository culturasRepository(Ref ref) {
  return ref.watch(culturasRepositoryProvider);
}

@riverpod
ComentariosService comentariosService(Ref ref) {
  return ref.watch(comentariosServiceProvider);
}

@riverpod
IDiagnosticosRepository iDiagnosticosRepository(Ref ref) {
  final baseRepo = ref.watch(diagnosticoRepositoryProvider);
  final wrapperRepo = DiagnosticosRepository(baseRepo);

  return DiagnosticosRepositoryImpl(
    wrapperRepo,
    ref.watch(fitossanitariosRepositoryProvider),
    ref.watch(culturasRepositoryProvider),
    ref.watch(pragasRepositoryProvider),
  );
}

@riverpod
FitossanitariosRepository fitossanitariosRepository(Ref ref) {
  return ref.watch(fitossanitariosRepositoryProvider);
}

@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(Ref ref) {
  return ref.watch(favoritosRepositorySimplifiedProvider);
}
