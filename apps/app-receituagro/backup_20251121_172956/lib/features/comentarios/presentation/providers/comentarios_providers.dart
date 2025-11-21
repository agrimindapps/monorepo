import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';
import '../../services/comentarios_filter_service.dart';
import '../../services/comentarios_validation_service.dart';

part 'comentarios_providers.g.dart';

@riverpod
GetComentariosUseCase getComentariosUseCase(GetComentariosUseCaseRef ref) {
  return di.sl<GetComentariosUseCase>();
}

@riverpod
AddComentarioUseCase addComentarioUseCase(AddComentarioUseCaseRef ref) {
  return di.sl<AddComentarioUseCase>();
}

@riverpod
DeleteComentarioUseCase deleteComentarioUseCase(DeleteComentarioUseCaseRef ref) {
  return di.sl<DeleteComentarioUseCase>();
}

@riverpod
ComentariosFilterService comentariosFilterService(ComentariosFilterServiceRef ref) {
  return di.sl<ComentariosFilterService>();
}

@riverpod
ComentariosValidationService comentariosValidationService(ComentariosValidationServiceRef ref) {
  return di.sl<ComentariosValidationService>();
}
