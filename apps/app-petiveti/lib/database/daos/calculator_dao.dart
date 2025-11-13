import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/calculation_history_table.dart';

part 'calculator_dao.g.dart';

@DriftAccessor(tables: [CalculationHistory])
class CalculatorDao extends DatabaseAccessor<PetivetiDatabase> with _$CalculatorDaoMixin {
  CalculatorDao(PetivetiDatabase db) : super(db);

  /// Get all calculation history for a user
  Future<List<CalculationHistoryEntry>> getAllHistory(String userId) {
    return (select(calculationHistory)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Get history by calculator type
  Future<List<CalculationHistoryEntry>> getHistoryByType(String userId, String calculatorType) {
    return (select(calculationHistory)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.calculatorType.equals(calculatorType))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Create history entry
  Future<int> createHistoryEntry(CalculationHistoryCompanion entry) {
    return into(calculationHistory).insert(entry);
  }

  /// Delete history entry
  Future<bool> deleteHistoryEntry(int id) async {
    return (update(calculationHistory)..where((tbl) => tbl.id.equals(id)))
      .write(const CalculationHistoryCompanion(isDeleted: Value(true)));
  }

  /// Clear all history for a user
  Future<int> clearAllHistory(String userId) {
    return (update(calculationHistory)..where((tbl) => tbl.userId.equals(userId)))
      .write(const CalculationHistoryCompanion(isDeleted: Value(true)));
  }
}
