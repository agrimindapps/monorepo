import 'package:drift/drift.dart';

/// Tabela de perfis fitness para o sistema FitQuest
@DataClassName('FitnessProfile')
class FitnessProfiles extends Table {
  TextColumn get id => text()();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get currentLevel => integer().withDefault(const Constant(1))();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalWorkouts => integer().withDefault(const Constant(0))();
  IntColumn get totalMinutes => integer().withDefault(const Constant(0))();
  IntColumn get totalCalories => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWorkoutDate => dateTime().nullable()();
  
  // Contadores especiais
  IntColumn get earlyBirdCount => integer().withDefault(const Constant(0))();
  IntColumn get nightOwlCount => integer().withDefault(const Constant(0))();
  IntColumn get weekendWarriorCount => integer().withDefault(const Constant(0))();
  
  // Categorias usadas (JSON array como string)
  TextColumn get categoriesUsed => text().withDefault(const Constant('[]'))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
