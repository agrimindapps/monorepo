import 'package:core/core.dart';
import 'package:drift/drift.dart';

// Tables
import 'tables/perfis_table.dart';
import 'tables/pesos_table.dart';
import 'tables/agua_registros_table.dart';
import 'tables/water_records_table.dart';
import 'tables/water_achievements_table.dart';
import 'tables/water_goals_table.dart';
import 'tables/water_streaks_table.dart';
import 'tables/water_custom_cups_table.dart';
import 'tables/water_reminders_table.dart';
import 'tables/water_daily_progress_table.dart';
import 'tables/exercicios_table.dart';
import 'tables/comentarios_table.dart';
// FitQuest Gamification Tables
import 'tables/fitness_profiles_table.dart';
import 'tables/fitness_achievements_table.dart';
import 'tables/weekly_challenges_table.dart';
import 'tables/workout_sessions_table.dart';
// Weight Tracker Tables
import 'tables/weight_records_table.dart';
import 'tables/weight_achievements_table.dart';
import 'tables/weight_goals_table.dart';
import 'tables/weight_milestones_table.dart';
import 'tables/weight_reminders_table.dart';
import 'tables/weight_daily_stats_table.dart';

// DAOs
import 'daos/perfil_dao.dart';
import 'daos/peso_dao.dart';
import 'daos/agua_dao.dart';
import 'daos/water_dao.dart';
import 'daos/water_tracker_dao.dart';
import 'daos/exercicio_dao.dart';
import 'daos/comentario_dao.dart';
import 'daos/gamification_dao.dart';
import 'daos/weight_tracker_dao.dart';

part 'nutrituti_database.g.dart';

/// ============================================================================
/// NUTRITUTI DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-nutrituti usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (16 total):**
/// 1. Perfis - Perfis de usuários
/// 2. Pesos - Registro de peso
/// 3. AguaRegistros - Registros de consumo de água (legacy)
/// 4. WaterRecords - Registros de água
/// 5. WaterAchievements - Conquistas de hidratação
/// 6. WaterGoals - Metas de hidratação
/// 7. WaterStreaks - Sequências de hidratação
/// 8. WaterCustomCups - Copos personalizados
/// 9. WaterReminders - Lembretes de água
/// 10. WaterDailyProgressTable - Progresso diário
/// 11. Exercicios - Exercícios físicos
/// 12. Comentarios - Comentários e notas
/// 13. FitnessProfiles - Perfis de gamificação FitQuest
/// 14. FitnessAchievements - Conquistas FitQuest
/// 15. WeeklyChallenges - Desafios semanais FitQuest
/// 16. WorkoutSessions - Sessões de treino FitQuest
///
/// **SCHEMA VERSION:** 3 (FitQuest Gamification)
/// ============================================================================

@DriftDatabase(
  tables: [
    Perfis,
    Pesos,
    AguaRegistros,
    WaterRecords,
    WaterAchievements,
    WaterGoals,
    WaterStreaks,
    WaterCustomCups,
    WaterReminders,
    WaterDailyProgressTable,
    Exercicios,
    Comentarios,
    // FitQuest Gamification
    FitnessProfiles,
    FitnessAchievements,
    WeeklyChallenges,
    WorkoutSessions,
    // Weight Tracker
    WeightRecords,
    WeightAchievements,
    WeightGoals,
    WeightMilestones,
    WeightReminders,
    WeightDailyStats,
  ],
  daos: [
    PerfilDao,
    PesoDao,
    AguaDao,
    WaterDao,
    WaterTrackerDao,
    ExercicioDao,
    ComentarioDao,
    GamificationDao,
    WeightTrackerDao,
  ],
)
class NutritutiDatabase extends _$NutritutiDatabase with BaseDriftDatabase {
  NutritutiDatabase(super.e);

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 4;

  /// Factory constructor para ambiente de produção
  factory NutritutiDatabase.production() {
    return NutritutiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nutrituti_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory NutritutiDatabase.development() {
    return NutritutiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nutrituti_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  factory NutritutiDatabase.test() {
    return NutritutiDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory constructor com path customizado
  factory NutritutiDatabase.withPath(String path) {
    return NutritutiDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'nutrituti_drift.db',
        customPath: path,
        logStatements: false,
      ),
    );
  }

  /// Estratégia de migração do banco de dados
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migration from version 1 to 2 (Water Tracker 2.0)
          if (from < 2) {
            await m.createTable(waterGoals);
            await m.createTable(waterStreaks);
            await m.createTable(waterCustomCups);
            await m.createTable(waterReminders);
            await m.createTable(waterDailyProgressTable);
            // Update water_achievements table with new columns
            await m.addColumn(waterAchievements, waterAchievements.isUnlocked);
            await m.addColumn(waterAchievements, waterAchievements.requiredValue);
            await m.addColumn(waterAchievements, waterAchievements.currentProgress);
            await m.addColumn(waterAchievements, waterAchievements.category);
          }
          // Migration from version 2 to 3 (FitQuest Gamification)
          if (from < 3) {
            await m.createTable(fitnessProfiles);
            await m.createTable(fitnessAchievements);
            await m.createTable(weeklyChallenges);
            await m.createTable(workoutSessions);
          }
          // Migration from version 3 to 4 (Weight Tracker)
          if (from < 4) {
            await m.createTable(weightRecords);
            await m.createTable(weightAchievements);
            await m.createTable(weightGoals);
            await m.createTable(weightMilestones);
            await m.createTable(weightReminders);
            await m.createTable(weightDailyStats);
          }
        },
      );
}
