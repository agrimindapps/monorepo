import 'package:drift/drift.dart';

@DataClassName('WeightMilestone')
class WeightMilestones extends Table {
  TextColumn get id => text()();
  RealColumn get targetWeight => real()();
  TextColumn get title => text()();
  BoolColumn get isAchieved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
