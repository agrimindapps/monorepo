import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/list_item_model.dart';

/// Remote data source for ListItem using Firestore
/// Optional sync - offline-first with Drift is primary
class ListItemRemoteDataSource {
  final FirebaseFirestore _firestore;

  ListItemRemoteDataSource(this._firestore);

  static const String _collectionName = 'list_items';

  /// Get all ListItems for a specific list from Firestore
  Future<List<ListItemModel>> getListItems(String listId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('listId', isEqualTo: listId)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => ListItemModel.fromJson(doc.data()))
        .toList();
  }

  /// Get a specific ListItem by ID
  Future<ListItemModel?> getListItemById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();

    if (!doc.exists) return null;

    return ListItemModel.fromJson(doc.data()!);
  }

  /// Save a ListItem to Firestore
  Future<void> saveListItem(ListItemModel listItem) async {
    await _firestore
        .collection(_collectionName)
        .doc(listItem.id)
        .set(listItem.toJson());
  }

  /// Delete a ListItem from Firestore
  Future<void> deleteListItem(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  /// Delete all items for a specific list
  Future<void> deleteAllItemsForList(String listId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('listId', isEqualTo: listId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Stream ListItems for real-time updates (optional)
  Stream<List<ListItemModel>> watchListItems(String listId) {
    return _firestore
        .collection(_collectionName)
        .where('listId', isEqualTo: listId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListItemModel.fromJson(doc.data()))
            .toList());
  }
}
