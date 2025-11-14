import 'package:injectable/injectable.dart';

import '../drift_database/nutrituti_database.dart';
import '../drift_database/daos/comentario_dao.dart';
import '../drift_database/tables/comentarios_table.dart';
import 'package:drift/drift.dart' as drift;

@injectable
class ComentariosRepository {
  final NutitutiDatabase _database;
  
  ComentariosRepository(this._database);

  ComentarioDao get _dao => _database.comentarioDao;

  Future<void> addComentario(ComentariosCompanion comentario) async {
    await _dao.addComentario(comentario);
  }

  Future<List<Comentario>> getAllComentarios() async {
    return await _dao.getAllComentarios();
  }

  Future<Comentario?> getComentarioById(String id) async {
    return await _dao.getComentarioById(id);
  }

  Future<List<Comentario>> getComentariosByFerramenta(String ferramenta) async {
    return await _dao.getComentariosByFerramenta(ferramenta);
  }

  Future<void> updateComentario(String id, ComentariosCompanion comentario) async {
    await _dao.updateComentario(id, comentario);
  }

  Future<void> deleteComentario(String id) async {
    await _dao.deleteComentario(id);
  }

  Future<void> deleteAllComentarios() async {
    await _dao.deleteAll();
  }

  Stream<List<Comentario>> watchAllComentarios() {
    return _dao.watchAllComentarios();
  }

  Future<List<Comentario>> searchComentarios(String query) async {
    return await _dao.searchComentarios(query);
  }
}
