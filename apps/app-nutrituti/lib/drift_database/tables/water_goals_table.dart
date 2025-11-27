import 'package:drift/drift.dart';

@DataClassName('WaterGoal')
class WaterGoals extends Table {
  TextColumn get id => text()();
  IntColumn get dailyGoalMl => integer().withDefault(const Constant(2000))();
  RealColumn get weightKg => real().nullable()();
  IntColumn get calculatedGoalMl => integer().nullable()();
  BoolColumn get useCalculatedGoal => boolean().withDefault(const Constant(false))();
  IntColumn get activityAdjustmentMl => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
