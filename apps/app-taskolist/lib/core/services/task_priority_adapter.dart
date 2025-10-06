import 'package:core/core.dart';

import '../../features/tasks/domain/task_entity.dart';

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 4;

  @override
  TaskPriority read(BinaryReader reader) {
    final index = reader.readByte();
    return TaskPriority.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeByte(obj.index);
  }
}
