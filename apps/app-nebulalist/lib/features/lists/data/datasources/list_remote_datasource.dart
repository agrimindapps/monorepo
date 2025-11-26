import 'package:core/core.dart';
import '../models/list_model.dart';

/// Interface for remote data source
abstract class IListRemoteDataSource {
  Future<void> saveList(ListModel list);
  Future<ListModel?> getList(String id);
  Future<List<ListModel>> getLists(String userId);
  Future<void> deleteList(String id);
  Future<void> syncLists(String userId, List<ListModel> localLists);
}

/// Remote data source implementation using Firestore
/// Handles cloud synchronization (optional for MVP)
class ListRemoteDataSourceImpl implements IListRemoteDataSource {
  final FirebaseFirestore _firestore;

  ListRemoteDataSourceImpl(this._firestore);

  static const String _collection = 'lists';

  @override
  Future<void> saveList(ListModel list) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(list.id)
          .set(list.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw RemoteException('Failed to save list: ${e.message}');
    } catch (e) {
      throw RemoteException('Failed to save list: $e');
    }
  }

  @override
  Future<ListModel?> getList(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) return null;

      return ListModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw RemoteException('Failed to get list: ${e.message}');
    } catch (e) {
      throw RemoteException('Failed to get list: $e');
    }
  }

  @override
  Future<List<ListModel>> getLists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ListModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw RemoteException('Failed to get lists: ${e.message}');
    } catch (e) {
      throw RemoteException('Failed to get lists: $e');
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw RemoteException('Failed to delete list: ${e.message}');
    } catch (e) {
      throw RemoteException('Failed to delete list: $e');
    }
  }

  @override
  Future<void> syncLists(String userId, List<ListModel> localLists) async {
    try {
      // Get remote lists
      final remoteLists = await getLists(userId);
      final remoteMap = {for (var list in remoteLists) list.id: list};

      // Sync logic: Last Write Wins (LWW)
      for (final localList in localLists) {
        final remoteList = remoteMap[localList.id];

        if (remoteList == null) {
          // Local list doesn't exist remotely, push it
          await saveList(localList);
        } else if (localList.updatedAt.isAfter(remoteList.updatedAt)) {
          // Local is newer, push it
          await saveList(localList);
        }
        // If remote is newer, it will be pulled by the repository
      }
    } on FirebaseException catch (e) {
      throw RemoteException('Failed to sync lists: ${e.message}');
    } catch (e) {
      throw RemoteException('Failed to sync lists: $e');
    }
  }
}

/// Custom exception for remote operations
class RemoteException implements Exception {
  final String message;

  RemoteException(this.message);

  @override
  String toString() => 'RemoteException: $message';
}
