import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 3;

  @override
  TaskStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return TaskStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}