import 'package:drift/drift.dart';

import '../../../../core/database/nebulalist_database.dart';
import '../models/list_item_model.dart';

/// Local data source for ListItem using Drift
class ListItemLocalDataSource {
  ListItemLocalDataSource(this._db);

  final NebulalistDatabase _db;

  /// Get all ListItems for a specific list
  Future<List<ListItemModel>> getListItems(String listId) async {
    final records = await (_db.select(_db.items)
          ..where((tbl) => tbl.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    return records.map(_recordToModel).toList();
  }

  /// Get a specific ListItem by ID
  Future<ListItemModel?> getListItemById(String id) async {
    final record = await (_db.select(_db.items)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (record == null) return null;
    return _recordToModel(record);
  }

  /// Save a ListItem to local storage
  Future<void> saveListItem(ListItemModel listItem) async {
    await _db.into(_db.items).insertOnConflictUpdate(
          ItemsCompanion(
            id: Value(listItem.id),
            listId: Value(listItem.listId),
            name: Value(listItem.itemMasterId), // Using itemMasterId as name reference
            isCompleted: Value(listItem.isCompleted),
            position: Value(listItem.order),
            note: Value(listItem.notes ?? ''),
            quantity: Value(int.tryParse(listItem.quantity) ?? 1),
            createdAt: Value(listItem.createdAt),
            updatedAt: Value(listItem.updatedAt),
            completedAt: Value(listItem.completedAt),
          ),
        );
  }

  /// Delete a ListItem from local storage
  Future<void> deleteListItem(String id) async {
    await (_db.delete(_db.items)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get count of items in a list
  Future<int> getListItemsCount(String listId) async {
    final count = _db.items.id.count();
    final query = _db.selectOnly(_db.items)
      ..addColumns([count])
      ..where(_db.items.listId.equals(listId));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get count of completed items in a list
  Future<int> getCompletedItemsCount(String listId) async {
    final count = _db.items.id.count();
    final query = _db.selectOnly(_db.items)
      ..addColumns([count])
      ..where(
        _db.items.listId.equals(listId) & _db.items.isCompleted.equals(true),
      );

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Delete all items for a specific list
  Future<void> deleteAllItemsForList(String listId) async {
    await (_db.delete(_db.items)..where((tbl) => tbl.listId.equals(listId)))
        .go();
  }

  /// Clear all ListItems (for logout)
  Future<void> clearAll() async {
    await _db.delete(_db.items).go();
  }

  /// Converte ItemRecord do Drift para ListItemModel
  ListItemModel _recordToModel(ItemRecord record) {
    return ListItemModel(
      id: record.id,
      listId: record.listId,
      itemMasterId: record.name, // name field stores itemMasterId reference
      quantity: record.quantity.toString(),
      priorityIndex: 1, // Default priority
      isCompleted: record.isCompleted,
      completedAt: record.completedAt,
      notes: record.note.isEmpty ? null : record.note,
      order: record.position,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
