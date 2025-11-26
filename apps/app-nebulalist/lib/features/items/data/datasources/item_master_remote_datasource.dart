import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_master_model.dart';

/// Remote data source for ItemMaster using Firestore
/// Optional sync - offline-first with Hive is primary
class ItemMasterRemoteDataSource {
  final FirebaseFirestore _firestore;

  ItemMasterRemoteDataSource(this._firestore);

  static const String _collectionName = 'item_masters';

  /// Get all ItemMasters for a user from Firestore
  Future<List<ItemMasterModel>> getItemMasters(String userId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => ItemMasterModel.fromJson(doc.data()))
        .toList();
  }

  /// Get a specific ItemMaster by ID
  Future<ItemMasterModel?> getItemMasterById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();

    if (!doc.exists) return null;

    return ItemMasterModel.fromJson(doc.data()!);
  }

  /// Save an ItemMaster to Firestore
  Future<void> saveItemMaster(ItemMasterModel itemMaster) async {
    await _firestore
        .collection(_collectionName)
        .doc(itemMaster.id)
        .set(itemMaster.toJson());
  }

  /// Delete an ItemMaster from Firestore
  Future<void> deleteItemMaster(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  /// Stream ItemMasters for real-time updates (optional)
  Stream<List<ItemMasterModel>> watchItemMasters(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemMasterModel.fromJson(doc.data()))
            .toList());
  }
}
