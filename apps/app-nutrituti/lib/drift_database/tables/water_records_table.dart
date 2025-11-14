import 'package:drift/drift.dart';

@DataClassName('WaterRecord')
class WaterRecords extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
