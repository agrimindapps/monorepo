import 'package:drift/drift.dart';

/// Tabela de desafios semanais para o sistema FitQuest
@DataClassName('WeeklyChallengeEntity')
class WeeklyChallenges extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text()(); // ChallengeType.name
  IntColumn get target => integer()();
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  IntColumn get xpReward => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
