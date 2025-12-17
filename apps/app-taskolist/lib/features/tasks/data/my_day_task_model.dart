import 'package:core/core.dart';

class MyDayTaskModel extends Equatable {
  const MyDayTaskModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.addedAt,
  });

  final String id;
  final String taskId;
  final String userId;
  final DateTime addedAt;

  @override
  List<Object?> get props => [id, taskId, userId, addedAt];

  MyDayTaskModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    DateTime? addedAt,
  }) {
    return MyDayTaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
