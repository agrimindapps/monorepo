import 'package:core/core.dart';
import '../../../domain/entities/task.dart';
import '../../models/task_model.dart';

abstract class TasksRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<List<TaskModel>> getTasksByPlantId(String plantId, String userId);
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status, String userId);
  Future<List<TaskModel>> getOverdueTasks(String userId);
  Future<List<TaskModel>> getTodayTasks(String userId);
  Future<List<TaskModel>> getUpcomingTasks(String userId);
  Future<TaskModel?> getTaskById(String id, String userId);
  Future<TaskModel> addTask(TaskModel task, String userId);
  Future<TaskModel> updateTask(TaskModel task, String userId);
  Future<void> deleteTask(String id, String userId);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final FirebaseFirestore _firestore;

  TasksRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gets the user-specific tasks collection path
  String _getUserTasksPath(String userId) => 'users/$userId/tasks';

  /// Gets the user-specific tasks collection reference
  CollectionReference _getTasksCollection(String userId) {
    return _firestore.collection(_getUserTasksPath(userId));
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      // Using simple query to avoid composite index requirement
      final querySnapshot =
          await _getTasksCollection(
            userId,
          ).where('is_deleted', isEqualTo: false).get();

      final tasks =
          querySnapshot.docs
              .map(
                (doc) => TaskModel.fromFirebaseMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Apply sorting on client-side to avoid composite index
      tasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // ascending order
      });

      return tasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas remotas: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPlantId(
    String plantId,
    String userId,
  ) async {
    try {
      // Using simple query to avoid composite index requirement
      final querySnapshot =
          await _getTasksCollection(userId)
              .where('plant_id', isEqualTo: plantId)
              .where('is_deleted', isEqualTo: false)
              .get();

      final tasks =
          querySnapshot.docs
              .map(
                (doc) => TaskModel.fromFirebaseMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Apply sorting on client-side to avoid composite index
      tasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // ascending order
      });

      return tasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por planta: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(
    TaskStatus status,
    String userId,
  ) async {
    try {
      // Using simple query to avoid composite index requirement
      final querySnapshot =
          await _getTasksCollection(userId)
              .where('status', isEqualTo: status.key)
              .where('is_deleted', isEqualTo: false)
              .get();

      final tasks =
          querySnapshot.docs
              .map(
                (doc) => TaskModel.fromFirebaseMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Apply sorting on client-side to avoid composite index
      tasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // ascending order
      });

      return tasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por status: $e');
    }
  }

  @override
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();
      // Using simple query to avoid composite index requirement
      final querySnapshot =
          await _getTasksCollection(
            userId,
          ).where('is_deleted', isEqualTo: false).get();

      final tasks =
          querySnapshot.docs
              .map(
                (doc) => TaskModel.fromFirebaseMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Apply filtering and sorting on client-side to avoid composite index
      final filteredTasks =
          tasks.where((task) {
            return task.status == TaskStatus.pending &&
                task.dueDate.isBefore(now);
          }).toList();

      filteredTasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // ascending order
      });

      return filteredTasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas atrasadas: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTodayTasks(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Using simple query to avoid composite index requirement
      final querySnapshot =
          await _getTasksCollection(
            userId,
          ).where('is_deleted', isEqualTo: false).get();

      final tasks =
          querySnapshot.docs
              .map(
                (doc) => TaskModel.fromFirebaseMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Apply filtering and sorting on client-side to avoid composite index
      final filteredTasks =
          tasks.where((task) {
            return task.status == TaskStatus.pending &&
                task.dueDate.isAfter(
                  startOfDay.subtract(const Duration(seconds: 1)),
                ) &&
                task.dueDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
          }).toList();

      filteredTasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // ascending order
      });

      return filteredTasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas de hoje: $e');
    }
  }

  @override
  Future<List<TaskModel>> getUpcomingTasks(String userId) async {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      // Using simple query to avoid composite index requirement
      final querySnapshot =
          await _getTasksCollection(
            userId,
          ).where('is_deleted', isEqualTo: false).get();

      final tasks =
          querySnapshot.docs
              .map(
                (doc) => TaskModel.fromFirebaseMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Apply filtering and sorting on client-side to avoid composite index
      final filteredTasks =
          tasks.where((task) {
            return task.status == TaskStatus.pending &&
                task.dueDate.isAfter(now) &&
                task.dueDate.isBefore(nextWeek.add(const Duration(seconds: 1)));
          }).toList();

      filteredTasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // ascending order
      });

      return filteredTasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas próximas: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id, String userId) async {
    try {
      final docSnapshot = await _getTasksCollection(userId).doc(id).get();

      if (!docSnapshot.exists) return null;

      return TaskModel.fromFirebaseMap({
        'id': docSnapshot.id,
        ...docSnapshot.data()! as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Erro ao buscar tarefa por ID: $e');
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task, String userId) async {
    try {
      final taskData = task.toFirebaseMap();
      taskData.remove('id'); // Remove ID as it will be generated by Firestore

      final docRef = await _getTasksCollection(userId).add(taskData);

      final createdTask = task.copyWith(
        id: docRef.id,
        lastSyncAt: DateTime.now(),
        isDirty: false,
      );

      return createdTask;
    } catch (e) {
      throw Exception('Erro ao adicionar tarefa remota: $e');
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task, String userId) async {
    try {
      final taskData = task.toFirebaseMap();
      taskData['updated_at'] = Timestamp.now().toDate().toIso8601String();

      await _getTasksCollection(userId).doc(task.id).update(taskData);

      return task.copyWith(
        lastSyncAt: DateTime.now(),
        isDirty: false,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa remota: $e');
    }
  }

  @override
  Future<void> deleteTask(String id, String userId) async {
    try {
      await _getTasksCollection(userId).doc(id).update({
        'is_deleted': true,
        'updated_at': Timestamp.now().toDate().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao deletar tarefa remota: $e');
    }
  }
}
