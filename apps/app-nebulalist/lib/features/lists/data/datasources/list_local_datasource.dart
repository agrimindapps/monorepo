import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/list_model.dart';

/// Interface for local data source
abstract class IListLocalDataSource {
  Future<void> saveList(ListModel list);
  Future<ListModel?> getList(String id);
  Future<List<ListModel>> getAllLists(String userId);
  Future<List<ListModel>> getActiveLists(String userId);
  Future<void> deleteList(String id);
  Future<int> getActiveListsCount(String userId);
  Future<void> clearAll();
}

/// Local data source implementation using Hive
/// Stores lists offline for offline-first functionality
@LazySingleton(as: IListLocalDataSource)
class ListLocalDataSourceImpl implements IListLocalDataSource {
  static const String _boxName = 'lists';

  Box<ListModel> get _box => Hive.box<ListModel>(_boxName);

  @override
  Future<void> saveList(ListModel list) async {
    try {
      await _box.put(list.id, list);
    } catch (e) {
      throw CacheException('Failed to save list: $e');
    }
  }

  @override
  Future<ListModel?> getList(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw CacheException('Failed to get list: $e');
    }
  }

  @override
  Future<List<ListModel>> getAllLists(String userId) async {
    try {
      final allLists = _box.values.where((list) => list.ownerId == userId);
      return allLists.toList();
    } catch (e) {
      throw CacheException('Failed to get all lists: $e');
    }
  }

  @override
  Future<List<ListModel>> getActiveLists(String userId) async {
    try {
      final activeLists = _box.values.where(
        (list) => list.ownerId == userId && !list.isArchived,
      );
      return activeLists.toList();
    } catch (e) {
      throw CacheException('Failed to get active lists: $e');
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete list: $e');
    }
  }

  @override
  Future<int> getActiveListsCount(String userId) async {
    try {
      final count = _box.values
          .where((list) => list.ownerId == userId && !list.isArchived)
          .length;
      return count;
    } catch (e) {
      throw CacheException('Failed to get active lists count: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException('Failed to clear lists: $e');
    }
  }
}

/// Custom exception for cache operations
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
