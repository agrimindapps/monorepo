import 'package:drift/drift.dart';

/// Tabela de sessões de treino para o sistema FitQuest
@DataClassName('WorkoutSessionEntity')
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get exerciseType => text()();
  TextColumn get categoria => text()(); // ExercicioCategoria.name
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get pausedDurationMs => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  IntColumn get estimatedCalories => integer().withDefault(const Constant(0))();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
