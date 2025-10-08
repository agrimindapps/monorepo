import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import '../../models/task_history_model.dart';

abstract class TaskHistoryRemoteDataSource {
  Future<List<TaskHistoryModel>> getHistoryByPlantId(
    String plantId,
    String userId,
  );
  Future<List<TaskHistoryModel>> getHistoryByTaskId(
    String taskId,
    String userId,
  );
  Future<List<TaskHistoryModel>> getHistoryByUserId(String userId);
  Future<List<TaskHistoryModel>> getHistoryInDateRange(
    DateTime startDate,
    DateTime endDate,
    String userId,
  );
  Future<TaskHistoryModel?> getHistoryById(String id, String userId);
  Future<TaskHistoryModel> saveHistory(TaskHistoryModel history, String userId);
  Future<void> deleteHistory(String id, String userId);
  Future<void> deleteHistoryByTaskId(String taskId, String userId);
  Future<void> deleteHistoryByPlantId(String plantId, String userId);
}

class TaskHistoryRemoteDataSourceImpl implements TaskHistoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskHistoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gets the user-specific task history collection path
  String _getUserTaskHistoryPath(String userId) => 'users/$userId/task_history';

  /// Gets the user-specific task history collection reference
  CollectionReference _getTaskHistoryCollection(String userId) {
    return _firestore.collection(_getUserTaskHistoryPath(userId));
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryByPlantId(
    String plantId,
    String userId,
  ) async {
    try {
      final querySnapshot =
          await _getTaskHistoryCollection(userId)
              .where('plantId', isEqualTo: plantId)
              .orderBy('completedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskHistoryModel.fromFirebaseMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por planta: $e');
    }
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryByTaskId(
    String taskId,
    String userId,
  ) async {
    try {
      final querySnapshot =
          await _getTaskHistoryCollection(userId)
              .where('taskId', isEqualTo: taskId)
              .orderBy('completedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskHistoryModel.fromFirebaseMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por tarefa: $e');
    }
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryByUserId(String userId) async {
    try {
      final querySnapshot =
          await _getTaskHistoryCollection(
            userId,
          ).orderBy('completedAt', descending: true).get();

      return querySnapshot.docs
          .map(
            (doc) => TaskHistoryModel.fromFirebaseMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por usuário: $e');
    }
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryInDateRange(
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    try {
      final querySnapshot =
          await _getTaskHistoryCollection(userId)
              .where('completedAt', isGreaterThanOrEqualTo: startDate)
              .where('completedAt', isLessThanOrEqualTo: endDate)
              .orderBy('completedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TaskHistoryModel.fromFirebaseMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por período: $e');
    }
  }

  @override
  Future<TaskHistoryModel?> getHistoryById(String id, String userId) async {
    try {
      final docSnapshot = await _getTaskHistoryCollection(userId).doc(id).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return TaskHistoryModel.fromFirebaseMap({
        'id': docSnapshot.id,
        ...docSnapshot.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Erro ao buscar histórico por ID: $e');
    }
  }

  @override
  Future<TaskHistoryModel> saveHistory(
    TaskHistoryModel history,
    String userId,
  ) async {
    try {
      final historyData = history.toFirebaseMap();
      // Remove id from data as it's the document ID
      historyData.remove('id');

      final docRef = await _getTaskHistoryCollection(userId).add(historyData);
      final savedHistory = history.copyWith(id: docRef.id);

      return TaskHistoryModel.fromEntity(savedHistory);
    } catch (e) {
      throw Exception('Erro ao salvar histórico: $e');
    }
  }

  @override
  Future<void> deleteHistory(String id, String userId) async {
    try {
      await _getTaskHistoryCollection(userId).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar histórico: $e');
    }
  }

  @override
  Future<void> deleteHistoryByTaskId(String taskId, String userId) async {
    try {
      final querySnapshot =
          await _getTaskHistoryCollection(
            userId,
          ).where('taskId', isEqualTo: taskId).get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar histórico por tarefa: $e');
    }
  }

  @override
  Future<void> deleteHistoryByPlantId(String plantId, String userId) async {
    try {
      final querySnapshot =
          await _getTaskHistoryCollection(
            userId,
          ).where('plantId', isEqualTo: plantId).get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar histórico por planta: $e');
    }
  }
}
