import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/exercicios_table.dart';

part 'exercicio_dao.g.dart';

@DriftAccessor(tables: [Exercicios])
class ExercicioDao extends DatabaseAccessor<NutritutiDatabase>
    with _$ExercicioDaoMixin {
  ExercicioDao(super.db);

  /// Get all exercicios
  Future<List<Exercicio>> getAllExercicios() {
    return (select(
      exercicios,
    )..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)])).get();
  }

  /// Get exercicio by ID
  Future<Exercicio?> getExercicioById(String id) {
    return (select(
      exercicios,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get exercicios by date range
  Future<List<Exercicio>> getExerciciosByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(exercicios)
          ..where(
            (tbl) =>
                tbl.dataRegistro.isBiggerOrEqualValue(start) &
                tbl.dataRegistro.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dataRegistro)]))
        .get();
  }

  /// Get pending sync exercicios
  Future<List<Exercicio>> getPendingSyncExercicios() {
    return (select(exercicios)
          ..where(
            (tbl) => tbl.isPending.equals(true) & tbl.isSynced.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Watch all exercicios
  Stream<List<Exercicio>> watchAllExercicios() {
    return (select(
      exercicios,
    )..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)])).watch();
  }

  /// Add exercicio
  Future<int> addExercicio(ExerciciosCompanion exercicio) {
    return into(exercicios).insert(exercicio);
  }

  /// Update exercicio
  Future<int> updateExercicio(String id, ExerciciosCompanion exercicio) {
    return (update(exercicios)..where((tbl) => tbl.id.equals(id))).write(
      exercicio.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Mark as synced
  Future<int> markAsSynced(String id) {
    return (update(exercicios)..where((tbl) => tbl.id.equals(id))).write(
      ExerciciosCompanion(
        isSynced: const Value(true),
        isPending: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark as pending
  Future<int> markAsPending(String id) {
    return (update(exercicios)..where((tbl) => tbl.id.equals(id))).write(
      ExerciciosCompanion(
        isPending: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete exercicio
  Future<int> deleteExercicio(String id) {
    return (delete(exercicios)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all exercicios
  Future<int> deleteAll() {
    return delete(exercicios).go();
  }

  /// Get total calorias by date range
  Future<double> getTotalCaloriasByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final exerciciosList = await getExerciciosByDateRange(start, end);
    return exerciciosList.fold<double>(
      0.0,
      (sum, e) => sum + e.caloriasQueimadas,
    );
  }

  /// Get exercicios by categoria
  Future<List<Exercicio>> getExerciciosByCategoria(String categoria) {
    return (select(exercicios)
          ..where((tbl) => tbl.categoria.equals(categoria))
          ..orderBy([(t) => OrderingTerm.desc(t.dataRegistro)]))
        .get();
  }
}
