import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';
import '../../services/comentarios_filter_service.dart';
import '../../services/comentarios_validation_service.dart';

import '../../../../core/providers/premium_providers.dart';
import '../../domain/comentarios_service.dart';
import '../providers/comentarios_mapper_provider.dart';

part 'comentarios_providers.g.dart';

@riverpod
ComentariosService comentariosService(ComentariosServiceRef ref) {
  return ComentariosService(
    repository: ref.watch(comentarioRepositoryProvider),
    premiumService: ref.watch(premiumServiceProvider),
    mapper: ref.watch(comentariosMapperProvider),
  );
}

@riverpod
GetComentariosUseCase getComentariosUseCase(GetComentariosUseCaseRef ref) {
  return GetComentariosUseCase(ref.watch(comentarioRepositoryProvider));
}

@riverpod
AddComentarioUseCase addComentarioUseCase(AddComentarioUseCaseRef ref) {
  return AddComentarioUseCase(ref.watch(comentarioRepositoryProvider));
}

@riverpod
DeleteComentarioUseCase deleteComentarioUseCase(DeleteComentarioUseCaseRef ref) {
  return DeleteComentarioUseCase(ref.watch(comentarioRepositoryProvider));
}

@riverpod
ComentariosFilterService comentariosFilterService(ComentariosFilterServiceRef ref) {
  return ComentariosFilterService();
}

@riverpod
ComentariosValidationService comentariosValidationService(ComentariosValidationServiceRef ref) {
  return ComentariosValidationService();
}
