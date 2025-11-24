import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple wrapper around FirebaseFirestore
/// TODO: Implement full service methods as needed
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  /// Get a reference to a collection
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a reference to a document
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  /// Get Firestore instance
  FirebaseFirestore get instance => _firestore;

  /// Create a new record in a collection
  Future<void> createRecord(
      String collectionPath, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).add(data);
  }

  /// Update an existing record
  Future<void> updateRecord(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }
}
