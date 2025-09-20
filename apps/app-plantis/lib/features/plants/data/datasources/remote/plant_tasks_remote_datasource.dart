import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/plant_task_model.dart';

abstract class PlantTasksRemoteDatasource {
  Future<List<PlantTaskModel>> getPlantTasks(String userId);
  Future<List<PlantTaskModel>> getPlantTasksByPlantId(String plantId, String userId);
  Future<PlantTaskModel?> getPlantTaskById(String id, String userId);
  Future<PlantTaskModel> addPlantTask(PlantTaskModel task, String userId);
  Future<List<PlantTaskModel>> addPlantTasks(List<PlantTaskModel> tasks, String userId);
  Future<PlantTaskModel> updatePlantTask(PlantTaskModel task, String userId);
  Future<void> deletePlantTask(String id, String userId);
  Future<void> deletePlantTasksByPlantId(String plantId, String userId);
  Future<void> syncPlantTasks(List<PlantTaskModel> tasks, String userId);
}

class PlantTasksRemoteDatasourceImpl implements PlantTasksRemoteDatasource {
  final FirebaseFirestore _firestore;

  PlantTasksRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get collection reference for user's plant tasks
  CollectionReference _getUserPlantTasksCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('plant_tasks');
  }

  @override
  Future<List<PlantTaskModel>> getPlantTasks(String userId) async {
    try {
      if (kDebugMode) {
        print('🔄 PlantTasksRemoteDataSource: Buscando plant tasks do Firebase para user $userId');
      }

      final querySnapshot = await _getUserPlantTasksCollection(userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('scheduledDate')
          .get();

      final tasks = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlantTaskModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: ${tasks.length} plant tasks encontradas no Firebase');
      }

      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao buscar plant tasks: $e');
      }
      throw Exception('Erro ao buscar tarefas remotamente: $e');
    }
  }

  @override
  Future<List<PlantTaskModel>> getPlantTasksByPlantId(String plantId, String userId) async {
    try {
      if (kDebugMode) {
        print('🔄 PlantTasksRemoteDataSource: Buscando plant tasks para planta $plantId');
      }

      final querySnapshot = await _getUserPlantTasksCollection(userId)
          .where('plantId', isEqualTo: plantId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('scheduledDate')
          .get();

      final tasks = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlantTaskModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: ${tasks.length} plant tasks encontradas para planta $plantId');
      }

      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao buscar plant tasks por plantId: $e');
      }
      throw Exception('Erro ao buscar tarefas da planta remotamente: $e');
    }
  }

  @override
  Future<PlantTaskModel?> getPlantTaskById(String id, String userId) async {
    try {
      final docSnapshot = await _getUserPlantTasksCollection(userId).doc(id).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      final task = PlantTaskModel.fromJson({
        ...data,
        'id': docSnapshot.id,
      });

      return task.isDeleted ? null : task;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao buscar plant task por ID: $e');
      }
      throw Exception('Erro ao buscar tarefa remotamente: $e');
    }
  }

  @override
  Future<PlantTaskModel> addPlantTask(PlantTaskModel task, String userId) async {
    try {
      if (kDebugMode) {
        print('💾 PlantTasksRemoteDataSource: Salvando plant task ${task.id} no Firebase');
      }

      final taskData = task.toJson();
      taskData.remove('id'); // Remove ID from data, will be set by Firestore

      final docRef = await _getUserPlantTasksCollection(userId).add({
        ...taskData,
        'isDirty': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return task with Firebase-generated ID
      final savedTask = task.copyWith(
        id: docRef.id,
        isDirty: false,
        updatedAt: DateTime.now(),
      );

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: Plant task salva com ID ${docRef.id}');
      }

      return savedTask;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao salvar plant task: $e');
      }
      throw Exception('Erro ao salvar tarefa remotamente: $e');
    }
  }

  @override
  Future<List<PlantTaskModel>> addPlantTasks(List<PlantTaskModel> tasks, String userId) async {
    try {
      if (kDebugMode) {
        print('💾 PlantTasksRemoteDataSource: Salvando ${tasks.length} plant tasks em lote no Firebase');
      }

      final batch = _firestore.batch();
      final savedTasks = <PlantTaskModel>[];

      for (final task in tasks) {
        final docRef = _getUserPlantTasksCollection(userId).doc();
        final taskData = task.toJson();
        taskData.remove('id');

        batch.set(docRef, {
          ...taskData,
          'isDirty': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        savedTasks.add(task.copyWith(
          id: docRef.id,
          isDirty: false,
          updatedAt: DateTime.now(),
        ));
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: ${tasks.length} plant tasks salvas em lote');
      }

      return savedTasks;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao salvar plant tasks em lote: $e');
      }
      throw Exception('Erro ao salvar tarefas em lote remotamente: $e');
    }
  }

  @override
  Future<PlantTaskModel> updatePlantTask(PlantTaskModel task, String userId) async {
    try {
      if (kDebugMode) {
        print('🔄 PlantTasksRemoteDataSource: Atualizando plant task ${task.id} no Firebase');
      }

      final taskData = task.toJson();
      taskData.remove('id');

      await _getUserPlantTasksCollection(userId).doc(task.id).update({
        ...taskData,
        'isDirty': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedTask = task.copyWith(
        isDirty: false,
        updatedAt: DateTime.now(),
      );

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: Plant task ${task.id} atualizada');
      }

      return updatedTask;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao atualizar plant task: $e');
      }
      throw Exception('Erro ao atualizar tarefa remotamente: $e');
    }
  }

  @override
  Future<void> deletePlantTask(String id, String userId) async {
    try {
      if (kDebugMode) {
        print('🗑️ PlantTasksRemoteDataSource: Deletando plant task $id do Firebase');
      }

      // Soft delete - mark as deleted
      await _getUserPlantTasksCollection(userId).doc(id).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: Plant task $id marcada como deletada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao deletar plant task: $e');
      }
      throw Exception('Erro ao deletar tarefa remotamente: $e');
    }
  }

  @override
  Future<void> deletePlantTasksByPlantId(String plantId, String userId) async {
    try {
      if (kDebugMode) {
        print('🗑️ PlantTasksRemoteDataSource: Deletando todas as plant tasks da planta $plantId');
      }

      final querySnapshot = await _getUserPlantTasksCollection(userId)
          .where('plantId', isEqualTo: plantId)
          .get();

      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: ${querySnapshot.docs.length} plant tasks da planta $plantId deletadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao deletar plant tasks por plantId: $e');
      }
      throw Exception('Erro ao deletar tarefas da planta remotamente: $e');
    }
  }

  @override
  Future<void> syncPlantTasks(List<PlantTaskModel> tasks, String userId) async {
    try {
      if (kDebugMode) {
        print('🔄 PlantTasksRemoteDataSource: Sincronizando ${tasks.length} plant tasks');
      }

      final batch = _firestore.batch();

      for (final task in tasks) {
        if (task.isDirty) {
          final taskData = task.toJson();
          taskData.remove('id');

          final docRef = _getUserPlantTasksCollection(userId).doc(task.id);

          batch.set(docRef, {
            ...taskData,
            'isDirty': false,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ PlantTasksRemoteDataSource: Plant tasks sincronizadas com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRemoteDataSource: Erro ao sincronizar plant tasks: $e');
      }
      throw Exception('Erro ao sincronizar tarefas: $e');
    }
  }
}