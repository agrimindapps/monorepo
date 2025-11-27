import 'package:drift/drift.dart';

@DataClassName('WeightReminder')
class WeightReminders extends Table {
  TextColumn get id => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get time => text().withDefault(const Constant('07:00'))(); // HH:mm format
  TextColumn get message => text().withDefault(const Constant('Hora de se pesar! 📊'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
