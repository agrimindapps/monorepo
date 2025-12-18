import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/nebulalist_database.dart';
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

/// Local data source implementation using Drift
/// Stores lists offline for offline-first functionality
class ListLocalDataSourceImpl implements IListLocalDataSource {
  ListLocalDataSourceImpl(this._db);

  final NebulalistDatabase _db;

  @override
  Future<void> saveList(ListModel list) async {
    try {
      await _db.into(_db.lists).insertOnConflictUpdate(
            ListsCompanion(
              id: Value(list.id),
              name: Value(list.name),
              ownerId: Value(list.ownerId),
              description: Value(list.description),
              tags: Value(jsonEncode(list.tags)),
              category: Value(list.category),
              isFavorite: Value(list.isFavorite),
              isArchived: Value(list.isArchived),
              createdAt: Value(list.createdAt),
              updatedAt: Value(list.updatedAt),
              shareToken: Value(list.shareToken),
              isShared: Value(list.isShared),
              archivedAt: Value(list.archivedAt),
              itemCount: Value(list.itemCount),
              completedCount: Value(list.completedCount),
            ),
          );
    } catch (e) {
      throw CacheException('Failed to save list: $e');
    }
  }

  @override
  Future<ListModel?> getList(String id) async {
    try {
      final record = await (_db.select(_db.lists)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (record == null) return null;

      return _recordToModel(record);
    } catch (e) {
      throw CacheException('Failed to get list: $e');
    }
  }

  @override
  Future<List<ListModel>> getAllLists(String userId) async {
    try {
      final records = await (_db.select(_db.lists)
            ..where((tbl) => tbl.ownerId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

      return records.map(_recordToModel).toList();
    } catch (e) {
      throw CacheException('Failed to get all lists: $e');
    }
  }

  @override
  Future<List<ListModel>> getActiveLists(String userId) async {
    try {
      final records = await (_db.select(_db.lists)
            ..where(
              (tbl) =>
                  tbl.ownerId.equals(userId) & tbl.isArchived.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

      return records.map(_recordToModel).toList();
    } catch (e) {
      throw CacheException('Failed to get active lists: $e');
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await (_db.delete(_db.lists)..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw CacheException('Failed to delete list: $e');
    }
  }

  @override
  Future<int> getActiveListsCount(String userId) async {
    try {
      final count = _db.lists.id.count();
      final query = _db.selectOnly(_db.lists)
        ..addColumns([count])
        ..where(
          _db.lists.ownerId.equals(userId) & _db.lists.isArchived.equals(false),
        );

      final result = await query.getSingle();
      return result.read(count) ?? 0;
    } catch (e) {
      throw CacheException('Failed to get active lists count: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _db.delete(_db.lists).go();
    } catch (e) {
      throw CacheException('Failed to clear lists: $e');
    }
  }

  /// Converte ListRecord do Drift para ListModel
  ListModel _recordToModel(ListRecord record) {
    List<String> tags = [];
    try {
      final decoded = jsonDecode(record.tags);
      if (decoded is List) {
        tags = decoded.cast<String>();
      }
    } catch (_) {}

    return ListModel(
      id: record.id,
      name: record.name,
      ownerId: record.ownerId,
      description: record.description,
      tags: tags,
      category: record.category,
      isFavorite: record.isFavorite,
      isArchived: record.isArchived,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      shareToken: record.shareToken,
      isShared: record.isShared,
      archivedAt: record.archivedAt,
      itemCount: record.itemCount,
      completedCount: record.completedCount,
    );
  }
}

/// Custom exception for cache operations
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
