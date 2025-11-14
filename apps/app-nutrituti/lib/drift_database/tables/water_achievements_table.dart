import 'package:drift/drift.dart';

@DataClassName('WaterAchievement')
class WaterAchievements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get unlockedAt => dateTime()();
  TextColumn get iconName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
