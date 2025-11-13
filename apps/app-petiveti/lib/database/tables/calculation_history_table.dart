import 'package:drift/drift.dart';

@DataClassName('CalculationHistoryEntry')
class CalculationHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get calculatorType => text()();
  TextColumn get inputData => text()(); // JSON serialized input
  TextColumn get result => text()(); // JSON serialized result
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
