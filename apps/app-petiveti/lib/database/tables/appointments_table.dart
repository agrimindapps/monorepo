import 'package:drift/drift.dart';

@DataClassName('Appointment')
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer()();
  
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get appointmentDateTime => dateTime()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()(); // scheduled, completed, cancelled
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
