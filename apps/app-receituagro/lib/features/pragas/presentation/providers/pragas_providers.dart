import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/access_history_service.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../domain/repositories/i_pragas_repository.dart';
import '../../domain/services/i_pragas_error_message_service.dart';
import '../../domain/services/i_pragas_type_service.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../comentarios/presentation/providers/comentarios_providers.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/presentation/providers/favoritos_providers.dart';
import '../../data/services/pragas_error_message_service.dart';
import '../../data/services/pragas_type_service.dart';

part 'pragas_providers.g.dart';

@riverpod
PragasRepository pragasRepository(Ref ref) {
  return ref.watch(pragasRepositoryProvider);
}

@riverpod
IPragasRepository iPragasRepository(Ref ref) {
  return ref.watch(pragasRepositoryProvider);
}

@riverpod
IPragasErrorMessageService pragasErrorMessageService(Ref ref) {
  return PragasErrorMessageService();
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
IPragasTypeService pragasTypeService(Ref ref) {
  return PragasTypeService();
}

@riverpod
ComentariosService comentariosService(Ref ref) {
  return ref.watch(comentariosServiceProvider);
}

@riverpod
IDiagnosticosRepository iDiagnosticosRepository(Ref ref) {
  return ref.watch(diagnosticoRepositoryProvider);
}

@riverpod
FitossanitariosRepository fitossanitariosRepository(Ref ref) {
  return ref.watch(fitossanitariosRepositoryProvider);
}

@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(Ref ref) {
  return ref.watch(favoritosRepositorySimplifiedProvider);
}
