import 'package:drift/drift.dart';

@DataClassName('WeightAchievement')
class WeightAchievements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get emoji => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  IntColumn get requiredValue => integer().nullable()();
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  TextColumn get category => text().withDefault(const Constant('general'))();

  @override
  Set<Column> get primaryKey => {id};
}
