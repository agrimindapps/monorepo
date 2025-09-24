import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  // Getters para expor as funções no topo
  Future<int?> Function(String) get countDocuments => _countDocuments;
  Future<void> Function(String, List<dynamic>) get saveBatch => _saveBatch;
  Future<List<dynamic>> Function(String, String, String) get searchByField =>
      _searchByField;
  Future<List<dynamic>> Function(String) get getRandomDocuments =>
      _getRandomDocuments;
  Future<List<dynamic>> Function({
    required String collection,
    required int limit,
    DocumentSnapshot? lastDocument,
  }) get fetchDefensivosPaged => _fetchDefensivosPaged;

  Future<int?> _countDocuments(String collection) async {
    try {
      AggregateQuerySnapshot querySnapshot =
          await _firestore.collection(collection).count().get();
      debugPrint('querySnapshot.count: ${querySnapshot.count}');
      return querySnapshot.count;
    } catch (e) {
      debugPrint('Erro ao contar documentos: $e');
      return 0;
    }
  }

  // Função interna para salvar um lote de documentos
  Future<void> _saveBatch(String collection, List<dynamic> data) async {
    const int maxBatchSize = 200;
    WriteBatch batch = _firestore.batch();

    for (int i = 0; i < data.length; i += maxBatchSize) {
      final batchData = data.sublist(
          i, i + maxBatchSize > data.length ? data.length : i + maxBatchSize);

      for (var item in batchData) {
        DocumentReference docRef = _firestore.collection(collection).doc();
        batch.set(docRef, item);
      }

      await batch.commit();
      batch = _firestore.batch();
    }
  }

  // Função interna para buscar documentos por campo
  Future<List<dynamic>> _searchByField(
      String collection, String field, String searchTerm) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(collection)
        .where(field, isGreaterThanOrEqualTo: searchTerm)
        .where(field, isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get(const GetOptions(source: Source.server));

    final result = querySnapshot.docs.where((doc) {
      String nomeComum = doc[field].toString().toLowerCase();
      return nomeComum.contains(searchTerm.toLowerCase());
    }).toList();

    return result.map((doc) => doc.data() as dynamic).toList();
  }

  // Função interna para buscar documentos aleatórios
  Future<List<dynamic>> _getRandomDocuments(String collection) async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(collection).limit(12).get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<dynamic>> _fetchDefensivosPaged({
    required String collection,
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query =
          _firestore.collection(collection).orderBy('nomeComum').limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();
      List<dynamic> results =
          querySnapshot.docs.map((doc) => doc.data() as dynamic).toList();

      return results;
    } catch (e) {
      debugPrint('Erro ao buscar documentos paginados: $e');
      return [];
    }
  }
}
