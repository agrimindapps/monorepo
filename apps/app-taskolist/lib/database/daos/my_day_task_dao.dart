import 'package:drift/drift.dart';

import '../tables/my_day_tasks_table.dart';
import '../taskolist_database.dart';

part 'my_day_task_dao.g.dart';

@DriftAccessor(tables: [MyDayTasks])
class MyDayTaskDao extends DatabaseAccessor<TaskolistDatabase>
    with _$MyDayTaskDaoMixin {
  MyDayTaskDao(super.db);

  // ========================================================================
  // CREATE
  // ========================================================================

  Future<int> insertMyDayTask(MyDayTasksCompanion entry) =>
      into(myDayTasks).insert(entry);

  // ========================================================================
  // READ
  // ========================================================================

  Future<List<MyDayTaskData>> getMyDayTasks(String userId) =>
      (select(myDayTasks)..where((tbl) => tbl.userId.equals(userId))).get();

  Stream<List<MyDayTaskData>> watchMyDayTasks(String userId) =>
      (select(myDayTasks)..where((tbl) => tbl.userId.equals(userId))).watch();

  Future<MyDayTaskData?> getMyDayTaskByTaskId({
    required String taskId,
    required String userId,
  }) =>
      (select(myDayTasks)
            ..where(
              (tbl) =>
                  tbl.taskId.equals(taskId) & tbl.userId.equals(userId),
            ))
          .getSingleOrNull();

  Future<bool> isInMyDay(String taskId) async {
    final result = await (select(myDayTasks)
          ..where((tbl) => tbl.taskId.equals(taskId)))
        .getSingleOrNull();
    return result != null;
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  Future<int> deleteByTaskId(String taskId) =>
      (delete(myDayTasks)..where((tbl) => tbl.taskId.equals(taskId))).go();

  Future<int> clearMyDay(String userId) =>
      (delete(myDayTasks)..where((tbl) => tbl.userId.equals(userId))).go();
}
