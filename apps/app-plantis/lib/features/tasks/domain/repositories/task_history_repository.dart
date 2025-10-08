import 'package:core/core.dart';

import '../entities/task_history.dart';

abstract class TaskHistoryRepository {
  Future<Either<Failure, List<TaskHistory>>> getHistoryByPlantId(
    String plantId,
  );
  Future<Either<Failure, List<TaskHistory>>> getHistoryByTaskId(String taskId);
  Future<Either<Failure, List<TaskHistory>>> getHistoryByUserId(String userId);
  Future<Either<Failure, List<TaskHistory>>> getHistoryInDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, TaskHistory>> saveHistory(TaskHistory history);
  Future<Either<Failure, void>> deleteHistory(String id);
  Future<Either<Failure, void>> deleteHistoryByTaskId(String taskId);
  Future<Either<Failure, void>> deleteHistoryByPlantId(String plantId);
}
