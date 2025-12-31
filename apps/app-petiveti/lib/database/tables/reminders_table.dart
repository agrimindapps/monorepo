import 'package:drift/drift.dart';

@DataClassName('ReminderRecord')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Firebase reference
  TextColumn get firebaseId => text().nullable()();

  // User reference
  TextColumn get userId => text()();

  IntColumn get animalId => integer().nullable()();

  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get reminderDateTime => dateTime()();
  TextColumn get type => text().withDefault(const Constant('general'))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  IntColumn get recurringDays => integer().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get snoozeUntil => dateTime().nullable()();
  
  // Legacy fields (for backward compatibility)
  TextColumn get frequency => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationEnabled =>
      boolean().withDefault(const Constant(true))();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Sync fields
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}
