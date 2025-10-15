import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../models/item_master_model.dart';

/// Local data source for ItemMaster using Hive
@injectable
class ItemMasterLocalDataSource {
  static const String _boxName = 'item_masters';

  Box<ItemMasterModel> get _box => Hive.box<ItemMasterModel>(_boxName);

  /// Get all ItemMasters from local storage
  List<ItemMasterModel> getItemMasters() {
    return _box.values.toList();
  }

  /// Get a specific ItemMaster by ID
  ItemMasterModel? getItemMasterById(String id) {
    return _box.get(id);
  }

  /// Save an ItemMaster to local storage
  Future<void> saveItemMaster(ItemMasterModel itemMaster) async {
    await _box.put(itemMaster.id, itemMaster);
  }

  /// Delete an ItemMaster from local storage
  Future<void> deleteItemMaster(String id) async {
    await _box.delete(id);
  }

  /// Get count of ItemMasters
  int getItemMastersCount() {
    return _box.length;
  }

  /// Search ItemMasters by name (case insensitive)
  List<ItemMasterModel> searchItemMasters(String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _box.values.where((item) {
      return item.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Clear all ItemMasters (for logout)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
