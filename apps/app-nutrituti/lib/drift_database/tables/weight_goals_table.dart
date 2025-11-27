import 'package:drift/drift.dart';

@DataClassName('WeightGoal')
class WeightGoals extends Table {
  TextColumn get id => text()();
  RealColumn get targetWeight => real()();
  RealColumn get initialWeight => real()();
  RealColumn get heightCm => real()(); // Height in centimeters for BMI calculation
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
