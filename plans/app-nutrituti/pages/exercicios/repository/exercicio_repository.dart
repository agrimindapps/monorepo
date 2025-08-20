// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import '../models/exercicio_model.dart';

class ExercicioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<ExercicioModel>> getExercicios() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercicios')
          .orderBy('dataRegistro', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ExercicioModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar exercícios: $e');
    }
  }

  Future<ExercicioModel> saveExercicio(ExercicioModel exercicio) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final exercicioRef =
          _firestore.collection('users').doc(userId).collection('exercicios');

      if (exercicio.id == null) {
        // Adicionar novo exercício
        final docRef = await exercicioRef.add(exercicio.toJson());
        return exercicio.copyWith(id: docRef.id);
      } else {
        // Atualizar exercício existente
        await exercicioRef.doc(exercicio.id).update(exercicio.toJson());
        return exercicio;
      }
    } catch (e) {
      throw Exception('Erro ao salvar exercício: $e');
    }
  }

  Future<void> deleteExercicio(String exercicioId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercicios')
          .doc(exercicioId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao excluir exercício: $e');
    }
  }

  Future<Map<String, dynamic>> getMetasExercicios() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('metas')
          .doc('exercicios')
          .get();

      if (doc.exists) {
        return doc.data() ?? {};
      } else {
        return {};
      }
    } catch (e) {
      throw Exception('Erro ao buscar metas de exercícios: $e');
    }
  }

  Future<void> saveMetasExercicios(Map<String, dynamic> metas) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('metas')
          .doc('exercicios')
          .set(metas, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erro ao salvar metas de exercícios: $e');
    }
  }
}
