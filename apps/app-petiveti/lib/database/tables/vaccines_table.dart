import 'package:drift/drift.dart';

@DataClassName('Vaccine')
class Vaccines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer()();
  
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
