import 'package:core/core.dart';

import '../../../../core/data/repositories/comentarios_hive_repository.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/repositories/i_comentarios_repository.dart';
import '../services/comentarios_mapper.dart';

/// Implementation of IComentariosRepository using Hive local storage.
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
  final ComentariosHiveRepository _hiveRepository;
  final IComentariosMapper _mapper;

  ComentariosRepositoryImpl(
    this._hiveRepository,
    this._mapper,
  );

  @override
  Future<List<ComentarioEntity>> getAllComentarios() async {
    final models = await _hiveRepository.getAllComentarios();
    return _mapper.modelsToEntities(models);
  }

  @override
  Future<List<ComentarioEntity>> getComentariosByContext(
    String pkIdentificador,
  ) async {
    final models = await _hiveRepository.getComentariosByContext(
      pkIdentificador,
    );
    return _mapper.modelsToEntities(models);
  }

  @override
  Future<List<ComentarioEntity>> getComentariosByTool(String ferramenta) async {
    final models = await _hiveRepository.getComentariosByTool(ferramenta);
    return _mapper.modelsToEntities(models);
  }

  @override
  Future<ComentarioEntity?> getComentarioById(String id) async {
    final model = await _hiveRepository.getComentarioById(id);
    if (model == null) return null;
    return _mapper.modelToEntity(model);
  }

  @override
  Future<void> addComentario(ComentarioEntity comentario) async {
    final model = _mapper.entityToModel(comentario);
    await _hiveRepository.addComentario(model);
  }

  @override
  Future<void> updateComentario(ComentarioEntity comentario) async {
    final model = _mapper.entityToModel(comentario);
    await _hiveRepository.updateComentario(model);
  }

  @override
  Future<void> deleteComentario(String id) async {
    await _hiveRepository.deleteComentario(id);
  }

  @override
  Future<void> cleanupOldComments() async {
    await _hiveRepository.cleanupOldComments();
  }

  @override
  Future<Map<String, int>> getUserCommentStats() async {
    return await _hiveRepository.getUserCommentStats();
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
