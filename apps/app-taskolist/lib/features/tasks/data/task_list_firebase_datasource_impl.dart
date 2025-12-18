import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

import '../domain/task_list_entity.dart';
import 'task_list_firebase_datasource.dart';
import 'task_list_model.dart';

class TaskListFirebaseDatasourceImpl implements TaskListFirebaseDatasource {
  final FirebaseFirestore _firestore;
  final String _userId;

  TaskListFirebaseDatasourceImpl({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  CollectionReference get _collection =>
      _firestore.collection('task_lists');

  @override
  Future<String> createTaskList(TaskListEntity taskList) async {
    try {
      final model = TaskListModel.fromEntity(taskList);
      final docRef = await _collection.add(model.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar lista: ${e.toString()}');
    }
  }

  @override
  Future<TaskListEntity> getTaskList(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Lista não encontrada');
      }
      return TaskListModel.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TaskListEntity>> getTaskLists({
    String? userId,
    bool? isArchived,
  }) async {
    try {
      Query query = _collection;

      // Filtra por listas onde o usuário é owner ou membro
      final uid = userId ?? _userId;
      query = query.where(
        Filter.or(
          Filter('ownerId', isEqualTo: uid),
          Filter('memberIds', arrayContains: uid),
        ),
      );

      // Filtra por arquivadas
      if (isArchived != null) {
        query = query.where('isArchived', isEqualTo: isArchived);
      }

      // Ordena por posição
      query = query.orderBy('position');
      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TaskListModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar listas: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTaskList(TaskListEntity taskList) async {
    try {
      final model = TaskListModel.fromEntity(taskList);
      await _collection.doc(taskList.id).update(model.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar lista: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTaskList(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar lista: ${e.toString()}');
    }
  }

  @override
  Future<void> shareTaskList(String id, List<String> memberIds) async {
    try {
      await _collection.doc(id).update({
        'memberIds': memberIds,
        'isShared': memberIds.isNotEmpty,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao compartilhar lista: ${e.toString()}');
    }
  }

  @override
  Future<void> archiveTaskList(String id) async {
    try {
      await _collection.doc(id).update({
        'isArchived': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao arquivar lista: ${e.toString()}');
    }
  }

  @override
  Stream<List<TaskListEntity>> watchTaskLists({
    String? userId,
    bool? isArchived,
  }) {
    try {
      Query query = _collection;

      final uid = userId ?? _userId;
      query = query.where(
        Filter.or(
          Filter('ownerId', isEqualTo: uid),
          Filter('memberIds', arrayContains: uid),
        ),
      );

      if (isArchived != null) {
        query = query.where('isArchived', isEqualTo: isArchived);
      }

      query = query.orderBy('position');
      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => TaskListModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw Exception('Erro ao observar listas: ${e.toString()}');
    }
  }
}
