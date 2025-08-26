import '../../../core/repositories/comentarios_hive_repository.dart';
import '../models/comentario_model.dart';
import 'comentarios_service.dart';

/// Repositório real de comentários usando Hive
/// Substitui o MockComentariosRepository
class ComentariosRealRepository implements IComentariosRepository {
  final ComentariosHiveRepository _hiveRepository;

  ComentariosRealRepository(this._hiveRepository);

  @override
  Future<List<ComentarioModel>> getAllComentarios() async {
    return await _hiveRepository.getAllComentarios();
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    await _hiveRepository.addComentario(comentario);
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    await _hiveRepository.updateComentario(comentario);
  }

  @override
  Future<void> deleteComentario(String id) async {
    await _hiveRepository.deleteComentario(id);
  }

  /// Métodos adicionais específicos do Hive Repository
  Future<List<ComentarioModel>> getComentariosByContext(String pkIdentificador) async {
    return await _hiveRepository.getComentariosByContext(pkIdentificador);
  }

  Future<List<ComentarioModel>> getComentariosByTool(String ferramenta) async {
    return await _hiveRepository.getComentariosByTool(ferramenta);
  }

  Future<void> cleanupOldComments() async {
    await _hiveRepository.cleanupOldComments();
  }

  Future<Map<String, int>> getUserCommentStats() async {
    return await _hiveRepository.getUserCommentStats();
  }
}