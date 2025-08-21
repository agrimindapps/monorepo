import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/task.dart';
import '../../models/task_model.dart';

abstract class TasksRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getTasksByPlantId(String plantId);
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status);
  Future<List<TaskModel>> getOverdueTasks();
  Future<List<TaskModel>> getTodayTasks();
  Future<List<TaskModel>> getUpcomingTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'tasks';

  TasksRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('is_deleted', isEqualTo: false)
              .orderBy('due_date')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskModel.fromFirebaseMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas remotas: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPlantId(String plantId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('plant_id', isEqualTo: plantId)
              .where('is_deleted', isEqualTo: false)
              .orderBy('due_date')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskModel.fromFirebaseMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por planta: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: status.key)
              .where('is_deleted', isEqualTo: false)
              .orderBy('due_date')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskModel.fromFirebaseMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por status: $e');
    }
  }

  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final now = Timestamp.now();
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: TaskStatus.pending.key)
              .where('due_date', isLessThan: now)
              .where('is_deleted', isEqualTo: false)
              .orderBy('due_date')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskModel.fromFirebaseMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas atrasadas: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTodayTasks() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: TaskStatus.pending.key)
              .where(
                'due_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where(
                'due_date',
                isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
              )
              .where('is_deleted', isEqualTo: false)
              .orderBy('due_date')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskModel.fromFirebaseMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas de hoje: $e');
    }
  }

  @override
  Future<List<TaskModel>> getUpcomingTasks() async {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: TaskStatus.pending.key)
              .where('due_date', isGreaterThan: Timestamp.fromDate(now))
              .where(
                'due_date',
                isLessThanOrEqualTo: Timestamp.fromDate(nextWeek),
              )
              .where('is_deleted', isEqualTo: false)
              .orderBy('due_date')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskModel.fromFirebaseMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas próximas: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();

      if (!docSnapshot.exists) return null;

      return TaskModel.fromFirebaseMap({
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      });
    } catch (e) {
      throw Exception('Erro ao buscar tarefa por ID: $e');
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    try {
      final taskData = task.toFirebaseMap();
      taskData.remove('id'); // Remove ID pois será gerado pelo Firestore

      final docRef = await _firestore.collection(_collection).add(taskData);

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
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final taskData = task.toFirebaseMap();
      taskData['updated_at'] = Timestamp.now().toDate().toIso8601String();

      await _firestore.collection(_collection).doc(task.id).update(taskData);

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
  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'is_deleted': true,
        'updated_at': Timestamp.now().toDate().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao deletar tarefa remota: $e');
    }
  }
}
