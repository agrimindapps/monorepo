import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
class PetivetiDatabase extends _$PetivetiDatabase {
  PetivetiDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future schema migrations will go here
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Web support - use in-memory or IndexedDB
      return NativeDatabase.memory();
    } else {
      // Mobile/Desktop - use SQLite file
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'petiveti_database.db'));
      return NativeDatabase(file);
    }
  });
}
