import 'package:drift/drift.dart';

class Calculations extends Table {
  TextColumn get id => text()();
  TextColumn get calculatorType => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get calculatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
