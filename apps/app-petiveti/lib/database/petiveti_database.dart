import 'package:drift/drift.dart';
import 'package:core/core.dart';

// Tables
import 'tables/animals_table.dart';
import 'tables/medications_table.dart';
import 'tables/vaccines_table.dart';
import 'tables/appointments_table.dart';
import 'tables/weight_records_table.dart';
import 'tables/expenses_table.dart';
import 'tables/reminders_table.dart';
import 'tables/calculation_history_table.dart';
import 'tables/promo_content_table.dart';

// DAOs
import 'daos/animal_dao.dart';
import 'daos/medication_dao.dart';
import 'daos/vaccine_dao.dart';
import 'daos/appointment_dao.dart';
import 'daos/weight_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/calculator_dao.dart';
import 'daos/promo_dao.dart';

part 'petiveti_database.g.dart';

/// ============================================================================
/// PETIVETI DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-petiveti usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (9 total):**
/// 1. Animals - Cadastro de pets
/// 2. Medications - Medicamentos e tratamentos
/// 3. Vaccines - Vacinação
/// 4. Appointments - Consultas veterinárias
/// 5. WeightRecords - Histórico de peso
/// 6. Expenses - Despesas com pets
/// 7. Reminders - Lembretes e notificações
/// 8. CalculationHistory - Histórico de calculadoras
/// 9. PromoContent - Conteúdo promocional
///
/// **SCHEMA VERSION:** 1 (inicial)
/// ============================================================================

@DriftDatabase(
  tables: [
    Animals,
    Medications,
    Vaccines,
    Appointments,
    WeightRecords,
    Expenses,
    Reminders,
    CalculationHistory,
    PromoContent,
  ],
  daos: [
    AnimalDao,
    MedicationDao,
    VaccineDao,
    AppointmentDao,
    WeightDao,
    ExpenseDao,
    ReminderDao,
    CalculatorDao,
    PromoDao,
  ],
)
class PetivetiDatabase extends _$PetivetiDatabase with BaseDriftDatabase {
  PetivetiDatabase(QueryExecutor e) : super(e);

  /// Versão do schema do banco de dados
  ///
  /// Incrementar quando houver mudanças estruturais nas tabelas
  @override
  int get schemaVersion => 1;

  /// Factory constructor para injeção de dependência via Riverpod
  ///
  /// Retorna a instância de produção.
  // @factoryMethod
  factory PetivetiDatabase.injectable() {
    return PetivetiDatabase.production();
  }

  /// Factory constructor para ambiente de produção
  ///
  /// Usa configuração padrão do DriftDatabaseConfig:
  /// - Nome: petiveti_drift.db
  /// - logStatements: false (performance)
  /// - Funciona em Web (WASM) e Mobile (Native)
  factory PetivetiDatabase.production() {
    return PetivetiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'petiveti_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  ///
  /// Diferenças vs production:
  /// - Nome: petiveti_drift_dev.db (isolado)
  /// - logStatements: true (debugging)
  factory PetivetiDatabase.development() {
    return PetivetiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'petiveti_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  ///
  /// Características:
  /// - In-memory database (não persiste no disco)
  /// - logStatements: true (debugging de testes)
  /// - Rápido e isolado
  factory PetivetiDatabase.test() {
    return PetivetiDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory constructor com path customizado
  ///
  /// Útil para backup/restore ou testes específicos
  factory PetivetiDatabase.withPath(String path) {
    return PetivetiDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'petiveti_drift.db',
        customPath: path,
        logStatements: false,
      ),
    );
  }

  /// Estratégia de migração do banco de dados
  ///
  /// - onCreate: Cria todas as tabelas na primeira inicialização
  /// - beforeOpen: Habilita foreign keys (integridade referencial)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Habilita foreign keys para integridade referencial
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future schema migrations will go here
      // Example:
      // if (from < 2) {
      //   await m.addColumn(animals, animals.newColumn);
      // }
    },
  );
}
