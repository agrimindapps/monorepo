import 'package:drift/drift.dart';

@DataClassName('Vaccine')
class Vaccines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer()();
  
  TextColumn get name => text()();
  TextColumn get veterinarian => text()();
  IntColumn get dateTimestamp => integer()();
  IntColumn get nextDueDateTimestamp => integer().nullable()();
  TextColumn get batch => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get dosage => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  BoolColumn get isRequired => boolean().withDefault(const Constant(true))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get reminderDateTimestamp => integer().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  IntColumn get createdAtTimestamp => integer()();
  IntColumn get updatedAtTimestamp => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}