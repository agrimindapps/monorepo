import 'dart:convert';
import 'package:drift/drift.dart';
import '../calculei_database.dart';
import '../tables/calculations_table.dart';

part 'calculation_dao.g.dart';

@DriftAccessor(tables: [Calculations])
class CalculationDao extends DatabaseAccessor<CalculeiDatabase>
    with _$CalculationDaoMixin {
  CalculationDao(super.db);

  /// Get all calculations for a specific calculator type
  Future<List<Calculation>> getCalculationsByType(
    String calculatorType, {
    int? limit,
  }) async {
    final query = select(calculations)
      ..where((t) => t.calculatorType.equals(calculatorType))
      ..orderBy([(t) => OrderingTerm.desc(t.calculatedAt)]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  /// Get calculation by ID
  Future<Calculation?> getCalculationById(String id) {
    return (select(
      calculations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Save calculation
  Future<int> saveCalculation(CalculationsCompanion calculation) {
    return into(
      calculations,
    ).insert(calculation, mode: InsertMode.insertOrReplace);
  }

  /// Delete calculation by ID
  Future<int> deleteCalculation(String id) {
    return (delete(calculations)..where((t) => t.id.equals(id))).go();
  }

  /// Clear all calculations for a specific type
  Future<int> clearCalculationsByType(String calculatorType) {
    return (delete(
      calculations,
    )..where((t) => t.calculatorType.equals(calculatorType))).go();
  }

  /// Save calculation with JSON encoding helper
  Future<void> saveCalculationJson({
    required String id,
    required String calculatorType,
    required Map<String, dynamic> data,
    required DateTime calculatedAt,
  }) async {
    await saveCalculation(
      CalculationsCompanion(
        id: Value(id),
        calculatorType: Value(calculatorType),
        dataJson: Value(jsonEncode(data)),
        calculatedAt: Value(calculatedAt),
      ),
    );
  }

  /// Get calculations by type and decode JSON helper
  Future<List<Map<String, dynamic>>> getCalculationsJsonByType(
    String calculatorType, {
    int? limit,
  }) async {
    final calcs = await getCalculationsByType(calculatorType, limit: limit);
    return calcs
        .map((c) => jsonDecode(c.dataJson) as Map<String, dynamic>)
        .toList();
  }
}
