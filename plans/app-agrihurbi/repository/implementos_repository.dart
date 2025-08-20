// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import '../models/implementos_class.dart';

/// Repository for managing agricultural implements data in Firestore
class ImplementosRepository {
  // Singleton pattern implementation
  static final ImplementosRepository _instance =
      ImplementosRepository._internal();

  factory ImplementosRepository() {
    return _instance;
  }

  ImplementosRepository._internal();

  // Firebase and collection configuration
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'implementos';

  /// Fetches all implements from Firestore
  Future<List<ImplementosClass>> getAll() async {
    try {
      final QuerySnapshot reg = await _firestore.collection(_collection).get();

      final implements = reg.docs
          .map((doc) => ImplementosClass().documentToClass(doc))
          .toList()
        ..sort((a, b) => a.descricao.compareTo(b.descricao));

      return implements;
    } catch (e) {
      throw Exception('Falha ao carregar implementos: $e');
    }
  }

  /// Fetches a single implement by ID
  Future<ImplementosClass> get(String idReg) async {
    if (idReg.isEmpty) {
      throw Exception('ID do implemento não informado');
    }

    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(idReg).get();

      if (!doc.exists) {
        throw Exception('Implemento não encontrado');
      }

      return ImplementosClass().documentToClass(doc);
    } catch (e) {
      throw Exception('Falha ao carregar implemento: $e');
    }
  }

  /// Creates a new implement instance
  ImplementosClass newInsert() {
    return ImplementosClass();
  }

  /// Saves or updates an implement
  Future<bool> saveUpdate(ImplementosClass implement) async {
    try {
      if (implement.idReg.isEmpty) {
        // New implement
        await _firestore
            .collection(_collection)
            .add(implement.toMap(implement));
      } else {
        // Update existing implement
        await _firestore
            .collection(_collection)
            .doc(implement.idReg)
            .update(implement.toMap(implement));
      }
      return true;
    } catch (e) {
      throw Exception('Falha ao salvar implemento: $e');
    }
  }

  /// Soft deletes an implement by setting its status to inactive
  Future<bool> remove(String idReg) async {
    if (idReg.isEmpty) {
      throw Exception('ID do implemento não informado');
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(idReg)
          .update({'status': true});
      return true;
    } catch (e) {
      throw Exception('Falha ao remover implemento: $e');
    }
  }
}
