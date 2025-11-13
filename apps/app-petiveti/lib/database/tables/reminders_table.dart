import 'package:drift/drift.dart';

@DataClassName('Reminder')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id).nullable()();
  
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dateTime => dateTime()();
  TextColumn get frequency => text().nullable()(); // once, daily, weekly, monthly
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationEnabled => boolean().withDefault(const Constant(true))();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
