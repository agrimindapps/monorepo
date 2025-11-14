import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/agua_registros_table.dart';

part 'agua_dao.g.dart';

@DriftAccessor(tables: [AguaRegistros])
class AguaDao extends DatabaseAccessor<NutitutiDatabase> with _$AguaDaoMixin {
  AguaDao(NutitutiDatabase db) : super(db);

  /// Get all registros for a perfil
  Future<List<AguaRegistro>> getAllRegistros(String perfilId) {
    return (select(aguaRegistros)
      ..where((tbl) => tbl.fkIdPerfil.equals(perfilId))
      ..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)]))
      .get();
  }

  /// Get registros by date
  Future<List<AguaRegistro>> getRegistrosByDate(String perfilId, int date) {
    return (select(aguaRegistros)
      ..where((tbl) => tbl.fkIdPerfil.equals(perfilId) & tbl.dataRegistro.equals(date)))
      .get();
  }

  /// Get registro by ID
  Future<AguaRegistro?> getRegistroById(String id) {
    return (select(aguaRegistros)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Watch all registros
  Stream<List<AguaRegistro>> watchAllRegistros(String perfilId) {
    return (select(aguaRegistros)
      ..where((tbl) => tbl.fkIdPerfil.equals(perfilId))
      ..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)]))
      .watch();
  }

  /// Create registro
  Future<int> createRegistro(AguaRegistrosCompanion registro) {
    return into(aguaRegistros).insert(registro);
  }

  /// Update registro
  Future<int> updateRegistro(String id, AguaRegistrosCompanion registro) {
    return (update(aguaRegistros)..where((tbl) => tbl.id.equals(id)))
        .write(registro.copyWith(updatedAt: Value(DateTime.now())));
  }

  /// Delete registro
  Future<int> deleteRegistro(String id) {
    return (delete(aguaRegistros)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get total quantidade by date
  Future<int> getTotalQuantidadeByDate(String perfilId, int date) async {
    final registros = await getRegistrosByDate(perfilId, date);
    return registros.fold<int>(0, (sum, r) => sum + r.quantidade);
  }

  /// Delete all registros
  Future<int> deleteAll() {
    return delete(aguaRegistros).go();
  }
}
