import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/example_model.dart';
import '../../../../../core/config/app_config.dart.template';

/// Remote data source for examples using Firebase Firestore
/// Handles all remote storage operations
@injectable
class ExampleRemoteDataSource {
  ExampleRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Get Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection(AppConfig.examplesCollection);
  }

  /// Get all examples from Firestore
  Future<List<ExampleModel>> getAll({String? userId}) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      // Filter by user if userId provided
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ExampleModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load examples from server: $e');
    }
  }

  /// Get example by ID from Firestore
  Future<ExampleModel?> getById(String id) async {
    try {
      final doc = await _collection.doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return ExampleModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load example from server: $e');
    }
  }

  /// Add example to Firestore
  Future<ExampleModel> add(ExampleModel model) async {
    try {
      await _collection.doc(model.id).set(model.toJson());
      return model;
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add example to server: $e');
    }
  }

  /// Update example in Firestore
  Future<ExampleModel> update(ExampleModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      return model;
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update example on server: $e');
    }
  }

  /// Delete example from Firestore
  Future<void> delete(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete example from server: $e');
    }
  }

  /// Listen to examples changes (real-time)
  Stream<List<ExampleModel>> watchAll({String? userId}) {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ExampleModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to watch examples: $e');
    }
  }

  /// Listen to single example changes (real-time)
  Stream<ExampleModel?> watchById(String id) {
    try {
      return _collection.doc(id).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return ExampleModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw Exception('Failed to watch example: $e');
    }
  }

  /// Batch update multiple examples
  Future<void> batchUpdate(List<ExampleModel> models) async {
    try {
      final batch = _firestore.batch();

      for (final model in models) {
        batch.update(_collection.doc(model.id), model.toJson());
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to batch update examples: $e');
    }
  }
}
