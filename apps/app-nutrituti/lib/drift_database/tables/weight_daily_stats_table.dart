import 'package:drift/drift.dart';

@DataClassName('WeightDailyStat')
class WeightDailyStats extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();
  RealColumn get bmi => real().nullable()();
  TextColumn get bmiCategory => text().nullable()(); // underweight, normal, overweight, obese
  RealColumn get changeFromPrevious => real().nullable()();
  RealColumn get changeFromStart => real().nullable()();
  IntColumn get daysFromStart => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
