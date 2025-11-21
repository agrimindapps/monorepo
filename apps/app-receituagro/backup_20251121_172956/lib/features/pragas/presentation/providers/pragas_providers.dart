import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/access_history_service.dart';
import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../domain/repositories/i_pragas_repository.dart';
import '../../domain/services/i_pragas_error_message_service.dart';
import '../../domain/services/i_pragas_type_service.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/favoritos_di.dart';

part 'pragas_providers.g.dart';

@riverpod
PragasRepository pragasRepository(Ref ref) {
  return di.sl<PragasRepository>();
}

@riverpod
IPragasRepository iPragasRepository(Ref ref) {
  return di.sl<IPragasRepository>();
}

@riverpod
IPragasErrorMessageService pragasErrorMessageService(Ref ref) {
  return di.sl<IPragasErrorMessageService>();
}

@riverpod
AccessHistoryService accessHistoryService(Ref ref) {
  return AccessHistoryService();
}

@riverpod
CulturasRepository culturasRepository(Ref ref) {
  return di.sl<CulturasRepository>();
}

@riverpod
IPragasTypeService pragasTypeService(Ref ref) {
  return di.sl<IPragasTypeService>();
}

@riverpod
ComentariosService comentariosService(Ref ref) {
  return di.sl<ComentariosService>();
}

@riverpod
IDiagnosticosRepository iDiagnosticosRepository(Ref ref) {
  return di.sl<IDiagnosticosRepository>();
}

@riverpod
FitossanitariosRepository fitossanitariosRepository(Ref ref) {
  return di.sl<FitossanitariosRepository>();
}

@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(Ref ref) {
  return FavoritosDI.get<FavoritosRepositorySimplified>();
}
