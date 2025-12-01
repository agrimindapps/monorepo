import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/access_history_service.dart';
import '../../../../database/providers/database_providers.dart' as db;
import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/diagnosticos_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../../diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/presentation/providers/favoritos_services_providers.dart';
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

/// Provider de PragasRepository - usa o do database_providers
@riverpod
PragasRepository pragasRepository(Ref ref) {
  return ref.watch(db.pragasRepositoryProvider);
}

@riverpod
IPragasRepository iPragasRepository(Ref ref) {
  return PragasRepositoryImpl(
    ref.watch(db.pragasRepositoryProvider),
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

/// Provider de CulturasRepository - usa o do database_providers
@riverpod
CulturasRepository culturasRepository(Ref ref) {
  return ref.watch(db.culturasRepositoryProvider);
}

@riverpod
IDiagnosticosRepository iDiagnosticosRepository(Ref ref) {
  final baseRepo = ref.watch(db.diagnosticoRepositoryProvider);
  final wrapperRepo = DiagnosticosRepository(baseRepo);

  return DiagnosticosRepositoryImpl(
    wrapperRepo,
    ref.watch(db.fitossanitariosRepositoryProvider),
    ref.watch(db.culturasRepositoryProvider),
    ref.watch(db.pragasRepositoryProvider),
  );
}

/// Provider de FitossanitariosRepository - usa o do database_providers
@riverpod
FitossanitariosRepository fitossanitariosRepository(Ref ref) {
  return ref.watch(db.fitossanitariosRepositoryProvider);
}

@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(Ref ref) {
  return FavoritosRepositorySimplified(
    service: ref.watch(favoritosServiceProvider),
  );
}
