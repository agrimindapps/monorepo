import 'package:drift/drift.dart';

@DataClassName('WaterAchievement')
class WaterAchievements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  TextColumn get iconName => text().nullable()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  IntColumn get requiredValue => integer().nullable()();
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  TextColumn get category => text().withDefault(const Constant('general'))();

  @override
  Set<Column> get primaryKey => {id};
}
