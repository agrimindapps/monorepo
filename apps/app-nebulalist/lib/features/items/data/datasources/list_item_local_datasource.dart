import 'package:hive/hive.dart';
import '../models/list_item_model.dart';

/// Local data source for ListItem using Hive
class ListItemLocalDataSource {
  static const String _boxName = 'list_items';

  Box<ListItemModel> get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError(
        'Box $_boxName is not open. Make sure BoxesSetup.init() is called before using this data source.',
      );
    }
    return Hive.box<ListItemModel>(_boxName);
  }

  /// Get all ListItems for a specific list
  List<ListItemModel> getListItems(String listId) {
    return _box.values.where((item) => item.listId == listId).toList();
  }

  /// Get a specific ListItem by ID
  ListItemModel? getListItemById(String id) {
    return _box.get(id);
  }

  /// Save a ListItem to local storage
  Future<void> saveListItem(ListItemModel listItem) async {
    await _box.put(listItem.id, listItem);
  }

  /// Delete a ListItem from local storage
  Future<void> deleteListItem(String id) async {
    await _box.delete(id);
  }

  /// Get count of items in a list
  int getListItemsCount(String listId) {
    return _box.values.where((item) => item.listId == listId).length;
  }

  /// Get count of completed items in a list
  int getCompletedItemsCount(String listId) {
    return _box.values
        .where((item) => item.listId == listId && item.isCompleted)
        .length;
  }

  /// Delete all items for a specific list
  Future<void> deleteAllItemsForList(String listId) async {
    final itemsToDelete = _box.values
        .where((item) => item.listId == listId)
        .map((item) => item.id)
        .toList();

    for (final id in itemsToDelete) {
      await _box.delete(id);
    }
  }

  /// Clear all ListItems (for logout)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
