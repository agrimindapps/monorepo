import 'package:hive/hive.dart';

part 'base_model.g.dart';

// Classe Base
@HiveType(typeId: 0)
class BaseModel extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  bool active;

  @HiveField(4)
  String id;

  BaseModel({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.id,
  });

  /// Converte o objeto em um Map
  Map<String, dynamic> toMap() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'active': active,
      'id': id,
    };
  }

  /// Converte um Map em um objeto BaseModel
  factory BaseModel.fromMap(Map<String, dynamic> map) {
    return BaseModel(
      objectId: map['objectId'] ?? '',
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      active: map['active'] ?? true,
      id: map['id'] ?? '',
    );
  }

  /// Atualiza as informações do modelo base
  void updateBase({
    int? updatedAt,
    bool? active,
    String? id,
  }) {
    if (updatedAt != null) this.updatedAt = updatedAt;
    if (active != null) this.active = active;
    if (id != null) this.id = id;
  }
}
