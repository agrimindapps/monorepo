import 'package:drift/drift.dart';

@DataClassName('WeightRecord')
class WeightRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Firebase reference
  TextColumn get firebaseId => text().nullable()();

  // User reference
  TextColumn get userId => text()();

  IntColumn get animalId => integer()();

  RealColumn get weight => real()();
  TextColumn get unit => text().withDefault(const Constant('kg'))();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Sync fields
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}
