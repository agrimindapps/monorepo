import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/nebulalist_database.dart';
import '../models/item_master_model.dart';

/// Local data source for ItemMaster using Drift
class ItemMasterLocalDataSource {
  ItemMasterLocalDataSource(this._db);

  final NebulalistDatabase _db;

  /// Get all ItemMasters from local storage
  Future<List<ItemMasterModel>> getItemMasters(String ownerId) async {
    final records = await (_db.select(_db.itemMasters)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    return records.map(_recordToModel).toList();
  }

  /// Get a specific ItemMaster by ID
  Future<ItemMasterModel?> getItemMasterById(String id) async {
    final record = await (_db.select(_db.itemMasters)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (record == null) return null;
    return _recordToModel(record);
  }

  /// Save an ItemMaster to local storage
  Future<void> saveItemMaster(ItemMasterModel itemMaster) async {
    await _db.into(_db.itemMasters).insertOnConflictUpdate(
          ItemMastersCompanion(
            id: Value(itemMaster.id),
            ownerId: Value(itemMaster.ownerId),
            name: Value(itemMaster.name),
            description: Value(itemMaster.description),
            tags: Value(jsonEncode(itemMaster.tags)),
            category: Value(itemMaster.category),
            photoUrl: Value(itemMaster.photoUrl),
            estimatedPrice: Value(itemMaster.estimatedPrice),
            preferredBrand: Value(itemMaster.preferredBrand),
            notes: Value(itemMaster.notes),
            usageCount: Value(itemMaster.usageCount),
            createdAt: Value(itemMaster.createdAt),
            updatedAt: Value(itemMaster.updatedAt),
          ),
        );
  }

  /// Delete an ItemMaster from local storage
  Future<void> deleteItemMaster(String id) async {
    await (_db.delete(_db.itemMasters)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get count of ItemMasters for a specific owner
  Future<int> getItemMastersCount(String ownerId) async {
    final count = _db.itemMasters.id.count();
    final query = _db.selectOnly(_db.itemMasters)
      ..addColumns([count])
      ..where(_db.itemMasters.ownerId.equals(ownerId));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Search ItemMasters by name (case insensitive)
  Future<List<ItemMasterModel>> searchItemMasters(
    String ownerId,
    String query,
  ) async {
    if (query.trim().isEmpty) return [];

    final records = await (_db.select(_db.itemMasters)
          ..where(
            (tbl) =>
                tbl.ownerId.equals(ownerId) &
                tbl.name.lower().like('%${query.toLowerCase()}%'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    return records.map(_recordToModel).toList();
  }

  /// Clear all ItemMasters for a specific owner (for logout)
  Future<void> clearAll(String ownerId) async {
    await (_db.delete(_db.itemMasters)
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .go();
  }

  /// Clear ALL ItemMasters (for complete reset)
  Future<void> clearAllData() async {
    await _db.delete(_db.itemMasters).go();
  }

  /// Converte ItemMasterRecord do Drift para ItemMasterModel
  ItemMasterModel _recordToModel(ItemMasterRecord record) {
    List<String> tags = [];
    try {
      final decoded = jsonDecode(record.tags);
      if (decoded is List) {
        tags = decoded.cast<String>();
      }
    } catch (_) {}

    return ItemMasterModel(
      id: record.id,
      ownerId: record.ownerId,
      name: record.name,
      description: record.description,
      tags: tags,
      category: record.category,
      photoUrl: record.photoUrl,
      estimatedPrice: record.estimatedPrice,
      preferredBrand: record.preferredBrand,
      notes: record.notes,
      usageCount: record.usageCount,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
