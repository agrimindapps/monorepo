import 'package:drift/drift.dart';

@DataClassName('WaterReminder')
class WaterReminders extends Table {
  TextColumn get id => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get intervalMinutes => integer().withDefault(const Constant(60))();
  TextColumn get startTime => text().withDefault(const Constant('08:00'))();
  TextColumn get endTime => text().withDefault(const Constant('22:00'))();
  BoolColumn get adaptiveReminders => boolean().withDefault(const Constant(true))();
  IntColumn get adaptiveThresholdMinutes => integer().withDefault(const Constant(120))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
