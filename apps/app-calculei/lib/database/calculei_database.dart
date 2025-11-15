import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Tables
import 'tables/calculations_table.dart';

// DAOs
import 'daos/calculation_dao.dart';

part 'calculei_database.g.dart';

@DriftDatabase(
  tables: [Calculations],
  daos: [CalculationDao],
)
class CalculeiDatabase extends _$CalculeiDatabase {
  CalculeiDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations go here
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'calculei.db'));
      return NativeDatabase(file);
    });
  }
}
