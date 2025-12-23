import 'package:core/core.dart';
import 'package:drift/drift.dart';

// DAOs
import 'daos/animal_dao.dart';
import 'daos/appointment_dao.dart';
import 'daos/calculator_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/medication_dao.dart';
import 'daos/promo_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/vaccine_dao.dart';
import 'daos/weight_dao.dart';
// Tables
import 'tables/animal_images_table.dart';
import 'tables/animals_table.dart';
import 'tables/appointments_table.dart';
import 'tables/calculation_history_table.dart';
import 'tables/expenses_table.dart';
import 'tables/medications_table.dart';
import 'tables/promo_content_table.dart';
import 'tables/reminders_table.dart';
import 'tables/user_subscriptions_table.dart';
import 'tables/vaccines_table.dart';
import 'tables/weight_records_table.dart';

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
/// **TABELAS (11 total):**
/// 1. Animals - Cadastro de pets
/// 2. AnimalImages - Fotos dos animais (Base64)
/// 3. Medications - Medicamentos e tratamentos
/// 4. Vaccines - Vacinação
/// 5. Appointments - Consultas veterinárias
/// 6. WeightRecords - Histórico de peso
/// 7. Expenses - Despesas com pets
/// 8. Reminders - Lembretes e notificações
/// 9. CalculationHistory - Histórico de calculadoras
/// 10. PromoContent - Conteúdo promocional
/// 11. UserSubscriptions - Assinaturas premium (cache local)
///
/// **SCHEMA VERSION:** 3 (v3: Adicionada tabela AnimalImages)
/// ============================================================================

@DriftDatabase(
  tables: [
    Animals,
    AnimalImages,
    Medications,
    Vaccines,
    Appointments,
    WeightRecords,
    Expenses,
    Reminders,
    CalculationHistory,
    UserSubscriptions,
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
  PetivetiDatabase(super.e);

  /// Versão do schema do banco de dados
  ///
  /// Incrementar quando houver mudanças estruturais nas tabelas
  /// v1: Schema inicial
  /// v2: Adicionados campos de sync (firebaseId, isDirty, lastSyncAt, version)
  /// v3: Adicionada tabela AnimalImages (imagens em Base64)
  @override
  int get schemaVersion => 3;

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
  /// - onUpgrade: Migrations para mudanças de schema
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
      // Migration v1 -> v2: Adicionar campos de sync
      if (from < 2) {
        // Animals
        await m.addColumn(animals, animals.firebaseId);
        await m.addColumn(animals, animals.lastSyncAt);
        await m.addColumn(animals, animals.isDirty);
        await m.addColumn(animals, animals.version);

        // Medications
        await m.addColumn(medications, medications.firebaseId);
        await m.addColumn(medications, medications.lastSyncAt);
        await m.addColumn(medications, medications.isDirty);
        await m.addColumn(medications, medications.version);

        // Vaccines
        await m.addColumn(vaccines, vaccines.firebaseId);
        await m.addColumn(vaccines, vaccines.lastSyncAtTimestamp);
        await m.addColumn(vaccines, vaccines.isDirty);
        await m.addColumn(vaccines, vaccines.version);

        // Appointments
        await m.addColumn(appointments, appointments.firebaseId);
        await m.addColumn(appointments, appointments.lastSyncAt);
        await m.addColumn(appointments, appointments.isDirty);
        await m.addColumn(appointments, appointments.version);

        // WeightRecords
        await m.addColumn(weightRecords, weightRecords.firebaseId);
        await m.addColumn(weightRecords, weightRecords.lastSyncAt);
        await m.addColumn(weightRecords, weightRecords.isDirty);
        await m.addColumn(weightRecords, weightRecords.version);

        // Expenses
        await m.addColumn(expenses, expenses.firebaseId);
        await m.addColumn(expenses, expenses.lastSyncAt);
        await m.addColumn(expenses, expenses.isDirty);
        await m.addColumn(expenses, expenses.version);

        // Reminders
        await m.addColumn(reminders, reminders.firebaseId);
        await m.addColumn(reminders, reminders.lastSyncAt);
        await m.addColumn(reminders, reminders.isDirty);
        await m.addColumn(reminders, reminders.version);

        // CalculationHistory
        await m.addColumn(calculationHistory, calculationHistory.firebaseId);
        await m.addColumn(calculationHistory, calculationHistory.lastSyncAt);
        await m.addColumn(calculationHistory, calculationHistory.isDirty);
        await m.addColumn(calculationHistory, calculationHistory.version);

        // PromoContent
        await m.addColumn(promoContent, promoContent.firebaseId);
        await m.addColumn(promoContent, promoContent.lastSyncAt);
        await m.addColumn(promoContent, promoContent.isDirty);
        await m.addColumn(promoContent, promoContent.version);
      }

      // ========== MIGRAÇÃO v2 → v3: Tabela AnimalImages ==========
      if (from < 3) {
        // Cria tabela de imagens dos animais com Base64
        await m.createTable(animalImages);
      }
    },
  );
}
