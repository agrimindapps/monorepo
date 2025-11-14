import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/comentarios_table.dart';

part 'comentario_dao.g.dart';

@DriftAccessor(tables: [Comentarios])
class ComentarioDao extends DatabaseAccessor<NutitutiDatabase> with _$ComentarioDaoMixin {
  ComentarioDao(NutitutiDatabase db) : super(db);

  /// Get all comentarios
  Future<List<Comentario>> getAllComentarios() {
    return (select(comentarios)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  /// Get comentario by ID
  Future<Comentario?> getComentarioById(String id) {
    return (select(comentarios)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get comentarios by ferramenta
  Future<List<Comentario>> getComentariosByFerramenta(String ferramenta) {
    return (select(comentarios)
      ..where((tbl) => tbl.ferramenta.equals(ferramenta))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  /// Get comentarios by identificador
  Future<List<Comentario>> getComentariosByIdentificador(String identificador) {
    return (select(comentarios)
      ..where((tbl) => tbl.pkIdentificador.equals(identificador))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  /// Watch all comentarios
  Stream<List<Comentario>> watchAllComentarios() {
    return (select(comentarios)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
  }

  /// Add comentario
  Future<int> addComentario(ComentariosCompanion comentario) {
    return into(comentarios).insert(comentario);
  }

  /// Update comentario
  Future<int> updateComentario(String id, ComentariosCompanion comentario) {
    return (update(comentarios)..where((tbl) => tbl.id.equals(id)))
        .write(comentario.copyWith(updatedAt: Value(DateTime.now())));
  }

  /// Delete comentario
  Future<int> deleteComentario(String id) {
    return (delete(comentarios)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all comentarios
  Future<int> deleteAll() {
    return delete(comentarios).go();
  }

  /// Search comentarios
  Future<List<Comentario>> searchComentarios(String query) {
    return (select(comentarios)
      ..where((tbl) => 
        tbl.titulo.like('%$query%') |
        tbl.conteudo.like('%$query%'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }
}
