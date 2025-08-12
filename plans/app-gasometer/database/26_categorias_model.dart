// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '26_categorias_model.g.dart';

@HiveType(typeId: 26)
class CategoriaCar extends BaseModel {
  @HiveField(7)
  int categoria;

  @HiveField(8)
  final String descricao;

  CategoriaCar({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.categoria,
    required this.descricao,
  });

  factory CategoriaCar.fromJson(Map<String, dynamic> json) {
    return CategoriaCar(
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDeleted: json['isDeleted'] ?? false,
      needsSync: json['needsSync'] ?? true,
      lastSyncAt: json['lastSyncAt'],
      version: json['version'] ?? 1,
      categoria: json['categoria'] ?? 0,
      descricao: json['descricao'] ?? '',
    );
  }

  factory CategoriaCar.fromMap(Map<String, dynamic> map) {
    return CategoriaCar(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      categoria: map['categoria'] ?? 0,
      descricao: map['descricao'] ?? '',
    );
  }

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({'categoria': categoria, 'descricao': descricao});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'needsSync': needsSync,
      'lastSyncAt': lastSyncAt,
      'version': version,
      'categoria': categoria,
      'descricao': descricao,
    };
  }
}
