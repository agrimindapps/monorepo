import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/perfis_table.dart';

part 'perfil_dao.g.dart';

@DriftAccessor(tables: [Perfis])
class PerfilDao extends DatabaseAccessor<NutritutiDatabase>
    with _$PerfilDaoMixin {
  PerfilDao(super.db);

  /// Get perfil by ID
  Future<Perfil?> getPerfilById(String id) {
    return (select(
      perfis,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get first perfil (single user app)
  Future<Perfil?> getPerfil() {
    return select(perfis).getSingleOrNull();
  }

  /// Watch perfil changes
  Stream<Perfil?> watchPerfil() {
    return select(perfis).watchSingleOrNull();
  }

  /// Create or update perfil
  Future<int> savePerfil(PerfisCompanion perfil) {
    return into(perfis).insertOnConflictUpdate(perfil);
  }

  /// Update perfil
  Future<int> updatePerfil(String id, PerfisCompanion perfil) {
    return (update(perfis)..where((tbl) => tbl.id.equals(id))).write(
      perfil.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Delete perfil
  Future<int> deletePerfil(String id) {
    return (delete(perfis)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all perfis
  Future<int> deleteAll() {
    return delete(perfis).go();
  }
}
