import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/pesos_table.dart';

part 'peso_dao.g.dart';

@DriftAccessor(tables: [Pesos])
class PesoDao extends DatabaseAccessor<NutritutiDatabase> with _$PesoDaoMixin {
  PesoDao(NutritutiDatabase db) : super(db);

  /// Get all pesos for a perfil (not deleted)
  Future<List<Peso>> getAllPesos(String perfilId) {
    return (select(pesos)
          ..where(
            (tbl) =>
                tbl.fkIdPerfil.equals(perfilId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)]))
        .get();
  }

  /// Get peso by ID
  Future<Peso?> getPesoById(String id) {
    return (select(pesos)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Watch all pesos
  Stream<List<Peso>> watchAllPesos(String perfilId) {
    return (select(pesos)
          ..where(
            (tbl) =>
                tbl.fkIdPerfil.equals(perfilId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)]))
        .watch();
  }

  /// Create peso
  Future<int> createPeso(PesosCompanion peso) {
    return into(pesos).insert(peso);
  }

  /// Update peso
  Future<int> updatePeso(String id, PesosCompanion peso) {
    return (update(pesos)..where((tbl) => tbl.id.equals(id))).write(
      peso.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Soft delete peso
  Future<int> softDeletePeso(String id) {
    return (update(pesos)..where((tbl) => tbl.id.equals(id))).write(
      PesosCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete peso
  Future<int> deletePeso(String id) {
    return (delete(pesos)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get pesos by date range
  Future<List<Peso>> getPesosByDateRange(
    String perfilId,
    int startDate,
    int endDate,
  ) {
    return (select(pesos)
          ..where(
            (tbl) =>
                tbl.fkIdPerfil.equals(perfilId) &
                tbl.isDeleted.equals(false) &
                tbl.dataRegistro.isBiggerOrEqualValue(startDate) &
                tbl.dataRegistro.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dataRegistro)]))
        .get();
  }

  /// Delete all pesos
  Future<int> deleteAll() {
    return delete(pesos).go();
  }
}
