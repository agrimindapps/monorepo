import 'package:drift/drift.dart';

/// Tabela de conquistas desbloqueadas para o sistema FitQuest
@DataClassName('FitnessAchievement')
class FitnessAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get achievementId => text()();
  TextColumn get profileId => text()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {achievementId, profileId},
  ];
}
