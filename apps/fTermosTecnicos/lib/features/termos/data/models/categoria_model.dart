import '../../domain/entities/categoria.dart';

/// Data model for Categoria extending the domain entity
/// Handles JSON serialization/deserialization
class CategoriaModel extends Categoria {
  const CategoriaModel({
    required super.id,
    required super.descricao,
    required super.keytermo,
    required super.keydecripy,
    required super.image,
  });

  /// Create CategoriaModel from JSON map
  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int? ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      keytermo: json['keytermo']?.toString() ?? '',
      keydecripy: json['keydecripy']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  /// Convert CategoriaModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'keytermo': keytermo,
      'keydecripy': keydecripy,
      'image': image,
    };
  }

  /// Create CategoriaModel from domain Categoria entity
  factory CategoriaModel.fromEntity(Categoria categoria) {
    return CategoriaModel(
      id: categoria.id,
      descricao: categoria.descricao,
      keytermo: categoria.keytermo,
      keydecripy: categoria.keydecripy,
      image: categoria.image,
    );
  }

  /// Convert CategoriaModel to domain Categoria entity
  Categoria toEntity() {
    return Categoria(
      id: id,
      descricao: descricao,
      keytermo: keytermo,
      keydecripy: keydecripy,
      image: image,
    );
  }
}
