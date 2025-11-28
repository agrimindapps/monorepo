import 'package:drift/drift.dart';

@DataClassName('Animal')
class Animals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text()();
  RealColumn get weight => real().nullable()();
  TextColumn get photo => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get microchipNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // Health fields
  BoolColumn get isCastrated => boolean().withDefault(const Constant(false))();
  TextColumn get allergies => text().nullable()(); // JSON string list
  TextColumn get bloodType => text().nullable()();
  TextColumn get preferredVeterinarian => text().nullable()();
  TextColumn get insuranceInfo => text().nullable()();
}
