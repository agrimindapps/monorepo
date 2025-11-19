import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/calculation_history_table.dart';

part 'calculator_dao.g.dart';

@DriftAccessor(tables: [CalculationHistory])
class CalculatorDao extends DatabaseAccessor<PetivetiDatabase>
    with _$CalculatorDaoMixin {
  CalculatorDao(PetivetiDatabase db) : super(db);

  /// Get all calculation history for a user
  Future<List<CalculationHistoryEntry>> getAllHistory(String userId) {
    return (select(calculationHistory)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Get history by calculator type
  Future<List<CalculationHistoryEntry>> getHistoryByType(
    String userId,
    String calculatorType,
  ) {
    return (select(calculationHistory)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.calculatorType.equals(calculatorType),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Get history entry by ID
  Future<CalculationHistoryEntry?> getHistoryById(int id) {
    return (select(calculationHistory)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Create history entry
  Future<int> createHistoryEntry({
    required String calculatorType,
    required String inputData,
    required String result,
    required String userId,
    DateTime? date,
  }) {
    return into(calculationHistory).insert(
      CalculationHistoryCompanion.insert(
        calculatorType: calculatorType,
        inputData: inputData,
        result: result,
        userId: userId,
        date: Value(date ?? DateTime.now()),
      ),
    );
  }

  /// Update history entry
  Future<bool> updateHistoryEntry(
    int id, {
    String? calculatorType,
    String? inputData,
    String? result,
  }) async {
    final updates = <String, Value<String>>{};
    if (calculatorType != null)
      updates['calculator_type'] = Value(calculatorType);
    if (inputData != null) updates['input_data'] = Value(inputData);
    if (result != null) updates['result'] = Value(result);

    if (updates.isEmpty) return false;

    final companion = CalculationHistoryCompanion(
      calculatorType: calculatorType != null
          ? Value(calculatorType)
          : const Value.absent(),
      inputData: inputData != null ? Value(inputData) : const Value.absent(),
      result: result != null ? Value(result) : const Value.absent(),
    );

    final rowsAffected = await (update(
      calculationHistory,
    )..where((tbl) => tbl.id.equals(id))).write(companion);

    return rowsAffected > 0;
  }

  /// Delete history entry
  Future<bool> deleteHistoryEntry(int id) async {
    final rowsAffected =
        await (update(calculationHistory)..where((tbl) => tbl.id.equals(id)))
            .write(const CalculationHistoryCompanion(isDeleted: Value(true)));
    return rowsAffected > 0;
  }

  /// Clear all history for a user
  Future<int> clearAllHistory(String userId) {
    return (update(calculationHistory)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(const CalculationHistoryCompanion(isDeleted: Value(true)));
  }
}
