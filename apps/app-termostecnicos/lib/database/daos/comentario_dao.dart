import 'package:drift/drift.dart';

import '../tables/comentarios_table.dart';
import '../termostecnicos_database.dart';

part 'comentario_dao.g.dart';

/// Data Access Object for Comentarios table
/// Provides CRUD operations and queries
@DriftAccessor(tables: [Comentarios])
class ComentarioDao extends DatabaseAccessor<TermosTecnicosDatabase>
    with _$ComentarioDaoMixin {
  ComentarioDao(super.db);

  /// Get all comentarios for a user (excluding deleted)
  Future<List<Comentario>> getAllComentarios(String userId) {
    return (select(comentarios)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get comentarios by ferramenta (tool/category)
  Future<List<Comentario>> getComentariosByFerramenta(
    String userId,
    String ferramenta,
  ) {
    return (select(comentarios)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.ferramenta.contains(ferramenta))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get comentario by ID
  Future<Comentario?> getComentarioById(int id) {
    return (select(comentarios)
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Create new comentario
  Future<int> createComentario(ComentariosCompanion comentario) {
    return into(comentarios).insert(comentario);
  }

  /// Update existing comentario
  Future<void> updateComentario(int id, ComentariosCompanion comentario) {
    return (update(comentarios)..where((tbl) => tbl.id.equals(id)))
        .write(comentario);
  }

  /// Soft delete comentario
  Future<void> deleteComentario(int id) {
    return (update(comentarios)..where((tbl) => tbl.id.equals(id))).write(
      const ComentariosCompanion(
        isDeleted: Value(true),
        updatedAt: Value.absentIfNull(null),
      ),
    );
  }

  /// Delete all comentarios for a user (soft delete)
  Future<void> deleteAllComentarios(String userId) {
    return (update(comentarios)..where((tbl) => tbl.userId.equals(userId)))
        .write(
      const ComentariosCompanion(
        isDeleted: Value(true),
        updatedAt: Value.absentIfNull(null),
      ),
    );
  }

  /// Get count of comentarios for a user
  Future<int> getComentariosCount(String userId) async {
    final count = comentarios.id.count();
    final query = selectOnly(comentarios)
      ..addColumns([count])
      ..where(comentarios.userId.equals(userId))
      ..where(comentarios.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Watch comentarios (stream)
  Stream<List<Comentario>> watchComentarios(String userId) {
    return (select(comentarios)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Watch comentarios by ferramenta (stream)
  Stream<List<Comentario>> watchComentariosByFerramenta(
    String userId,
    String ferramenta,
  ) {
    return (select(comentarios)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.ferramenta.contains(ferramenta))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
