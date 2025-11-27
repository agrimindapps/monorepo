import 'package:drift/drift.dart';

@DataClassName('WaterDailyProgress')
class WaterDailyProgressTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalMl => integer().withDefault(const Constant(0))();
  IntColumn get goalMl => integer()();
  BoolColumn get goalAchieved => boolean().withDefault(const Constant(false))();
  IntColumn get recordCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get firstRecordTime => dateTime().nullable()();
  DateTimeColumn get lastRecordTime => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
