import 'package:drift/drift.dart';

@DataClassName('WeightRecord')
class WeightRecords extends Table {
  TextColumn get id => text()();
  RealColumn get weightKg => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get timeOfDay => text().withDefault(const Constant('morning'))(); // morning, afternoon, evening

  @override
  Set<Column> get primaryKey => {id};
}
