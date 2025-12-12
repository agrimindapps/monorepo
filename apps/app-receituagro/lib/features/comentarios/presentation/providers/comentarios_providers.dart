import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/premium_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/comentarios_repository.dart';
import '../../data/repositories/comentarios_repository_impl.dart';
import '../../domain/comentarios_service.dart';
import '../../domain/repositories/i_comentarios_repository.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';
import '../../services/comentarios_filter_service.dart';
import '../../services/comentarios_validation_service.dart';
import '../providers/comentarios_mapper_provider.dart';

part 'comentarios_providers.g.dart';

@riverpod
IComentariosRepository iComentariosRepository(Ref ref) {
  // Note: ComentarioRepository from database_providers is the Drift wrapper
  // We need to wrap it in ComentariosRepositoryImpl which implements IComentariosRepository
  // But ComentariosRepositoryImpl expects ComentariosRepository (Drift wrapper)
  // Wait, database_providers provides ComentarioRepository (Drift repo)
  // But ComentariosRepositoryImpl expects ComentariosRepository (Drift wrapper)
  // Let's check database_providers again.
  // It provides ComentarioRepository (Drift repo).
  // And ComentariosRepository (Drift wrapper) wraps ComentarioRepository.
  // We need to create ComentariosRepository (Drift wrapper) first?
  // No, database_providers provides ComentarioRepository (Drift repo).
  // ComentariosRepositoryImpl expects ComentariosRepository (Drift wrapper).
  // I need to check imports in ComentariosRepositoryImpl.
  // import '../../../../database/repositories/comentarios_repository.dart';
  // This is the wrapper.
  
  // So I need to instantiate ComentariosRepository (wrapper) using ComentarioRepository (Drift repo).
  // Or maybe database_providers provides the wrapper?
  // @riverpod ComentarioRepository comentarioRepository(Ref ref) { ... return ComentarioRepository(db); }
  // This returns ComentarioRepository (Drift repo).
  
  // I need to instantiate ComentariosRepository (wrapper) here.
  // import '../../../../database/repositories/comentarios_repository.dart';
  
  final driftRepo = ref.watch(comentarioRepositoryProvider);
  final wrapperRepo = ComentariosRepository(driftRepo);
  final mapper = ref.watch(comentariosMapperProvider);
  
  return ComentariosRepositoryImpl(wrapperRepo, mapper);
}

@riverpod
ComentariosService comentariosService(Ref ref) {
  final repo = ref.watch(iComentariosRepositoryProvider);
  return ComentariosService(
    readRepository: repo,
    writeRepository: repo,
    premiumService: ref.watch(premiumServiceProvider),
    mapper: ref.watch(comentariosMapperProvider),
  );
}

@riverpod
GetComentariosUseCase getComentariosUseCase(Ref ref) {
  return GetComentariosUseCase(ref.watch(iComentariosRepositoryProvider));
}

@riverpod
AddComentarioUseCase addComentarioUseCase(Ref ref) {
  final repo = ref.watch(iComentariosRepositoryProvider);
  return AddComentarioUseCase(repo, repo);
}

@riverpod
DeleteComentarioUseCase deleteComentarioUseCase(Ref ref) {
  final repo = ref.watch(iComentariosRepositoryProvider);
  return DeleteComentarioUseCase(repo, repo);
}

@riverpod
ComentariosFilterService comentariosFilterService(Ref ref) {
  return ComentariosFilterService();
}

@riverpod
ComentariosValidationService comentariosValidationService(Ref ref) {
  return ComentariosValidationService();
}
