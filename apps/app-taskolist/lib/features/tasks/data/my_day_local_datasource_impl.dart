import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../database/daos/my_day_task_dao.dart';
import '../../../database/taskolist_database.dart';
import 'my_day_local_datasource.dart';
import 'my_day_task_extensions.dart';
import 'my_day_task_model.dart';

class MyDayLocalDataSourceImpl implements MyDayLocalDataSource {
  final TaskolistDatabase _database;
  late final MyDayTaskDao _myDayDao;

  MyDayLocalDataSourceImpl(this._database) {
    _myDayDao = _database.myDayTaskDao;
  }

  @override
  Future<void> addTaskToMyDay({
    required String taskId,
    required String userId,
  }) async {
    final id = FirebaseFirestore.instance.collection('_').doc().id;
    final myDayTask = MyDayTaskModel(
      id: id,
      taskId: taskId,
      userId: userId,
      addedAt: DateTime.now(),
    );

    await _myDayDao.insertMyDayTask(myDayTask.toCompanion());
  }

  @override
  Future<void> removeTaskFromMyDay({required String taskId}) async {
    await _myDayDao.deleteByTaskId(taskId);
  }

  @override
  Future<List<MyDayTaskModel>> getMyDayTasks({required String userId}) async {
    final tableTasks = await _myDayDao.getMyDayTasks(userId);
    return tableTasks.map((t) => t.toModel()).toList();
  }

  @override
  Stream<List<MyDayTaskModel>> watchMyDayTasks({required String userId}) {
    return _myDayDao.watchMyDayTasks(userId).map(
          (tableTasks) => tableTasks.map((t) => t.toModel()).toList(),
        );
  }

  @override
  Future<void> clearMyDay({required String userId}) async {
    await _myDayDao.clearMyDay(userId);
  }

  @override
  Future<bool> isInMyDay({required String taskId}) async {
    return _myDayDao.isInMyDay(taskId);
  }
}
