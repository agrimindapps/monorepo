import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/comentarios_repository.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/repositories/i_comentarios_repository.dart';
import '../services/comentarios_mapper.dart';

/// Implementation of IComentariosRepository using Drift local storage.
/// This is the data layer implementation that handles actual data persistence.
///
/// SOLID Refactoring:
/// - Separated mapping logic to ComentariosMapper (SRP)
/// - Separated ID generation to ComentariosIdService (SRP)
/// - Separated search logic to ComentariosSearchService (SRP)
/// - Repository now focuses only on CRUD operations
/// - All dependencies injected to improve testability (DIP)
///
/// This follows the pattern established in diagnosticos feature.
@LazySingleton(as: IComentariosRepository)
class ComentariosRepositoryImpl implements IComentariosRepository {
  final ComentariosRepository _repository;
  final IComentariosMapper _mapper;

  ComentariosRepositoryImpl(this._repository, this._mapper);

  @override
  Future<List<ComentarioEntity>> getAllComentarios() async {
    final data = await _repository.findAll();
    return _mapper.driftToEntities(data);
  }

  @override
  Future<List<ComentarioEntity>> getComentariosByContext(
    String pkIdentificador,
  ) async {
    final data = await _repository.findByContext(pkIdentificador);
    return _mapper.driftToEntities(data);
  }

  @override
  Future<List<ComentarioEntity>> getComentariosByTool(String ferramenta) async {
    final data = await _repository.findByTool(ferramenta);
    return _mapper.driftToEntities(data);
  }

  @override
  Future<ComentarioEntity?> getComentarioById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;

    final data = await _repository.findById(intId);
    if (data == null) return null;
    return _mapper.driftToEntity(data);
  }

  @override
  Future<void> addComentario(ComentarioEntity comentario) async {
    final data = _mapper.entityToDrift(comentario);
    await _repository.insert(data);
  }

  @override
  Future<void> updateComentario(ComentarioEntity comentario) async {
    final data = _mapper.entityToDrift(comentario);
    await _repository.update(data);
  }

  @override
  Future<void> deleteComentario(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return;
    await _repository.delete(intId);
  }

  @override
  Future<void> cleanupOldComments() async {
    await _repository.cleanupOld();
  }

  @override
  Future<Map<String, int>> getUserCommentStats() async {
    // TODO: Get current user ID from auth service
    return await _repository.getUserStats('current-user-id');
  }

  @override
  Future<List<ComentarioEntity>> searchComentarios(String query) async {
    // Note: Search logic should be delegated to ComentariosSearchService
    // This is a temporary implementation for backward compatibility
    final allComentarios = await getAllComentarios();

    if (query.trim().isEmpty) {
      return allComentarios;
    }

    final queryLower = query.toLowerCase();
    return allComentarios.where((comentario) {
      return comentario.conteudo.toLowerCase().contains(queryLower) ||
          comentario.titulo.toLowerCase().contains(queryLower) ||
          comentario.ferramenta.toLowerCase().contains(queryLower);
    }).toList();
  }

  @override
  Future<List<ComentarioEntity>> getByContext(String pkIdentificador) async {
    return getComentariosByContext(pkIdentificador);
  }

  @override
  Future<List<ComentarioEntity>> getCommentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allComentarios = await getAllComentarios();

    return allComentarios.where((comentario) {
      return comentario.createdAt.isAfter(start) &&
          comentario.createdAt.isBefore(end);
    }).toList();
  }
}
