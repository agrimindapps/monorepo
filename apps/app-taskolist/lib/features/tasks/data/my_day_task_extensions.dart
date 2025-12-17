import '../../../database/taskolist_database.dart';
import '../domain/my_day_task_entity.dart';

/// Extension para converter MyDayTaskData (Drift) para MyDayTaskEntity (Domain)
extension MyDayTaskDataX on MyDayTaskData {
  MyDayTaskEntity toEntity() {
    return MyDayTaskEntity(
      id: id,
      taskId: taskId,
      dayDate: dayDate,
      addedAt: addedAt,
      wasCompleted: wasCompleted,
      completedAt: completedAt,
      wasRemoved: wasRemoved,
      removedAt: removedAt,
      isArchived: isArchived,
    );
  }
}

/// Extension para converter MyDayTaskEntity (Domain) para Drift Companion
extension MyDayTaskEntityX on MyDayTaskEntity {
  MyDayTasksCompanion toCompanion() {
    return MyDayTasksCompanion.insert(
      id: id,
      taskId: taskId,
      dayDate: dayDate,
      addedAt: addedAt,
      wasCompleted: wasCompleted,
      completedAt: completedAt,
      wasRemoved: wasRemoved,
      removedAt: removedAt,
      isArchived: isArchived,
    );
  }
}
