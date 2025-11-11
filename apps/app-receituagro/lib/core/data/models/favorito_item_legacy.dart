import 'package:core/core.dart' hide Column;

// part 'favorito_item_hive.g.dart';

@HiveType(typeId: 110)
class FavoritoItemHive extends HiveObject {
  @HiveField(0)
  String sync_objectId;

  @HiveField(1)
  int sync_createdAt;

  @HiveField(2)
  int sync_updatedAt;

  @HiveField(3)
  String tipo; // 'defensivos', 'pragas', 'diagnosticos', 'culturas'

  @HiveField(4)
  String itemId; // ID do item original

  @HiveField(5)
  String itemData; // JSON string com dados do item para cache

  FavoritoItemHive({
    required this.sync_objectId,
    required this.sync_createdAt,
    required this.sync_updatedAt,
    required this.tipo,
    required this.itemId,
    required this.itemData,
  });

  factory FavoritoItemHive.fromJson(Map<String, dynamic> json) {
    return FavoritoItemHive(
      sync_objectId: (json['sync_objectId'] as String?) ?? '',
      sync_createdAt: json['sync_createdAt'] != null
          ? int.tryParse(json['sync_createdAt'].toString()) ?? 0
          : 0,
      sync_updatedAt: json['sync_updatedAt'] != null
          ? int.tryParse(json['sync_updatedAt'].toString()) ?? 0
          : 0,
      tipo: (json['tipo'] as String?) ?? '',
      itemId: (json['itemId'] as String?) ?? '',
      itemData: (json['itemData'] as String?) ?? '{}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sync_objectId': sync_objectId,
      'sync_createdAt': sync_createdAt,
      'sync_updatedAt': sync_updatedAt,
      'tipo': tipo,
      'itemId': itemId,
      'itemData': itemData,
    };
  }

  @override
  String toString() {
    return 'FavoritoItemHive{sync_objectId: $sync_objectId, tipo: $tipo, itemId: $itemId}';
  }
}
