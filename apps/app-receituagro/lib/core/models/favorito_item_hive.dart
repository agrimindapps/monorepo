import 'package:hive/hive.dart';

part 'favorito_item_hive.g.dart';

@HiveType(typeId: 110)
class FavoritoItemHive extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  String tipo; // 'defensivos', 'pragas', 'diagnosticos', 'culturas'

  @HiveField(4)
  String itemId; // ID do item original

  @HiveField(5)
  String itemData; // JSON string com dados do item para cache

  FavoritoItemHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.tipo,
    required this.itemId,
    required this.itemData,
  });

  factory FavoritoItemHive.fromJson(Map<String, dynamic> json) {
    return FavoritoItemHive(
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null 
          ? int.tryParse(json['createdAt'].toString()) ?? 0 
          : 0,
      updatedAt: json['updatedAt'] != null 
          ? int.tryParse(json['updatedAt'].toString()) ?? 0 
          : 0,
      tipo: (json['tipo'] as String?) ?? '',
      itemId: (json['itemId'] as String?) ?? '',
      itemData: (json['itemData'] as String?) ?? '{}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tipo': tipo,
      'itemId': itemId,
      'itemData': itemData,
    };
  }

  @override
  String toString() {
    return 'FavoritoItemHive{objectId: $objectId, tipo: $tipo, itemId: $itemId}';
  }
}