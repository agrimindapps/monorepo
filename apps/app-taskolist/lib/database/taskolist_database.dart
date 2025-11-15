import 'package:drift/drift.dart';

// Database Connection (Platform-specific)
import 'database_connection.dart';

// Tables
import 'tables/tasks_table.dart';
import 'tables/users_table.dart';

// DAOs
import 'daos/task_dao.dart';
import 'daos/user_dao.dart';

part 'taskolist_database.g.dart';

@DriftDatabase(
  tables: [
    Tasks,
    Users,
  ],
  daos: [
    TaskDao,
    UserDao,
  ],
)
class TaskolistDatabase extends _$TaskolistDatabase {
  TaskolistDatabase() : super(openConnection());

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
