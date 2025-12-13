import 'package:drift/drift.dart';

@DataClassName('CalculationHistoryEntry')
class CalculationHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Firebase reference
  TextColumn get firebaseId => text().nullable()();

  // User reference
  TextColumn get userId => text()();

  TextColumn get calculatorType => text()();
  TextColumn get inputData => text()(); // JSON serialized input
  TextColumn get result => text()(); // JSON serialized result
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  // Metadata
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Sync fields
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}
