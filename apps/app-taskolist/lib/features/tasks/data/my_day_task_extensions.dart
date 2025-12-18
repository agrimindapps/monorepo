import '../../../database/taskolist_database.dart';
import '../domain/my_day_task_entity.dart';
import 'my_day_task_model.dart';

/// Extension para converter MyDayTaskData (Drift) para MyDayTaskModel
extension MyDayTaskDataX on MyDayTaskData {
  MyDayTaskModel toModel() {
    return MyDayTaskModel(
      id: id,
      taskId: taskId,
      userId: userId,
      addedAt: addedAt,
    );
  }
}

/// Extension para converter MyDayTaskModel para MyDayTaskEntity
extension MyDayTaskModelX on MyDayTaskModel {
  MyDayTaskEntity toEntity() {
    return MyDayTaskEntity(
      id: id,
      taskId: taskId,
      userId: userId,
      addedAt: addedAt,
    );
  }

  MyDayTasksCompanion toCompanion() {
    return MyDayTasksCompanion.insert(
      id: id,
      taskId: taskId,
      userId: userId,
      addedAt: addedAt,
    );
  }
}

/// Extension para converter MyDayTaskEntity (Domain) para Drift Companion
extension MyDayTaskEntityX on MyDayTaskEntity {
  MyDayTasksCompanion toCompanion() {
    return MyDayTasksCompanion.insert(
      id: id,
      taskId: taskId,
      userId: userId,
      addedAt: addedAt,
    );
  }
}
