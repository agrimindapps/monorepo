import 'package:core/core.dart';

import '../../../../core/repositories/comentarios_hive_repository.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/repositories/i_comentarios_repository.dart';
import '../../models/comentario_model.dart';

/// Implementation of IComentariosRepository using Hive local storage.
/// This is the data layer implementation that handles actual data persistence.
class ComentariosRepositoryImpl implements IComentariosRepository {
  final ComentariosHiveRepository _hiveRepository;

  ComentariosRepositoryImpl(this._hiveRepository);

  @override
  Future<List<ComentarioEntity>> getAllComentarios() async {
    final models = await _hiveRepository.getAllComentarios();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<List<ComentarioEntity>> getComentariosByContext(String pkIdentificador) async {
    final models = await _hiveRepository.getComentariosByContext(pkIdentificador);
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<List<ComentarioEntity>> getComentariosByTool(String ferramenta) async {
    final models = await _hiveRepository.getComentariosByTool(ferramenta);
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<ComentarioEntity?> getComentarioById(String id) async {
    final result = await _hiveRepository.getByKey(id);
    if (result.isFailure || result.data == null) return null;
    
    final hiveItem = result.data!;
    final model = hiveItem.toComentarioModel();
    return _modelToEntity(model);
  }

  @override
  Future<void> addComentario(ComentarioEntity comentario) async {
    final model = _entityToModel(comentario);
    await _hiveRepository.addComentario(model);
  }

  @override
  Future<void> updateComentario(ComentarioEntity comentario) async {
    final model = _entityToModel(comentario);
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
    // Get all comentarios and filter by search query
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
  Future<List<ComentarioEntity>> getCommentsByDateRange(DateTime start, DateTime end) async {
    final allComentarios = await getAllComentarios();
    
    return allComentarios.where((comentario) {
      return comentario.createdAt.isAfter(start) && 
             comentario.createdAt.isBefore(end);
    }).toList();
  }

  /// Convert ComentarioModel to ComentarioEntity
  ComentarioEntity _modelToEntity(ComentarioModel model) {
    return ComentarioEntity(
      id: model.id,
      idReg: model.idReg,
      titulo: model.titulo,
      conteudo: model.conteudo,
      ferramenta: model.ferramenta,
      pkIdentificador: model.pkIdentificador,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert ComentarioEntity to ComentarioModel
  ComentarioModel _entityToModel(ComentarioEntity entity) {
    return ComentarioModel(
      id: entity.id,
      idReg: entity.idReg,
      titulo: entity.titulo,
      conteudo: entity.conteudo,
      ferramenta: entity.ferramenta,
      pkIdentificador: entity.pkIdentificador,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Generate unique ID for new comentarios
  String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final user = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return 'COMMENT_${user}_$timestamp';
  }

  /// Generate unique registration ID
  String generateUniqueIdReg() {
    return 'REG_${DateTime.now().millisecondsSinceEpoch}';
  }
}