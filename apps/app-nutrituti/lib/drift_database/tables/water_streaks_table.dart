import 'package:drift/drift.dart';

@DataClassName('WaterStreak')
class WaterStreaks extends Table {
  TextColumn get id => text()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastRecordDate => dateTime().nullable()();
  DateTimeColumn get streakStartDate => dateTime().nullable()();
  BoolColumn get canRecover => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
