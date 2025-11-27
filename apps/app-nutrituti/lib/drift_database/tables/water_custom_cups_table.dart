import 'package:drift/drift.dart';

@DataClassName('WaterCustomCup')
class WaterCustomCups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountMl => integer()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
