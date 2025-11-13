import 'package:drift/drift.dart';

@DataClassName('WeightRecord')
class WeightRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  
  RealColumn get weight => real()();
  TextColumn get unit => text().withDefault(const Constant('kg'))();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
