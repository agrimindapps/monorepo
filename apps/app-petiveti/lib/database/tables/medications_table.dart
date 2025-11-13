import 'package:drift/drift.dart';

@DataClassName('Medication')
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get veterinarian => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
