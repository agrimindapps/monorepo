import 'package:hive_flutter/hive_flutter.dart';
import '../../features/lists/data/models/list_model.dart';
import '../../features/items/data/models/item_master_model.dart';
import '../../features/items/data/models/list_item_model.dart';

/// Hive boxes setup and initialization
/// Registers all TypeAdapters and opens boxes
class BoxesSetup {
  BoxesSetup._();

  /// Initialize Hive and register all type adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register type adapters
    _registerAdapters();

    // Open boxes
    await _openBoxes();
  }

  /// Register all Hive type adapters
  static void _registerAdapters() {
    // Register your model adapters here
    // The typeId should be unique for each model

    // Lists feature (typeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ListModelAdapter());
    }

    // Items feature - ItemMaster (typeId: 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ItemMasterModelAdapter());
    }

    // Items feature - ListItem (typeId: 2)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ListItemModelAdapter());
    }
  }

  /// Open all required Hive boxes
  static Future<void> _openBoxes() async {
    // Lists feature
    await Hive.openBox<ListModel>('lists');

    // Items feature
    await Hive.openBox<ItemMasterModel>('item_masters');
    await Hive.openBox<ListItemModel>('list_items');
  }

  /// Get a specific box by name
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Close all boxes (for cleanup)
  static Future<void> closeAll() async {
    await Hive.close();
  }

  /// Clear all boxes (for logout/reset)
  static Future<void> clearAll() async {
    // Clear all boxes
    await Hive.box<ListModel>('lists').clear();
    await Hive.box<ItemMasterModel>('item_masters').clear();
    await Hive.box<ListItemModel>('list_items').clear();
  }

  /// Delete all boxes (complete wipe)
  static Future<void> deleteAll() async {
    // Delete all boxes
    await Hive.deleteBoxFromDisk('lists');
    await Hive.deleteBoxFromDisk('item_masters');
    await Hive.deleteBoxFromDisk('list_items');
  }
}
