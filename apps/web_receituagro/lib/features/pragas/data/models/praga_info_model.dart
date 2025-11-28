import '../../domain/entities/praga_info.dart';

/// PragaInfoModel - Data layer
/// Extends PragaInfo entity with JSON serialization for Supabase
/// 1:1 relationship with Praga - stores complementary information for insects/diseases
class PragaInfoModel extends PragaInfo {
  const PragaInfoModel({
    required super.id,
    required super.pragaId,
    super.descricao,
    super.sintomas,
    super.bioecologia,
    super.controle,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (Supabase format)
  factory PragaInfoModel.fromJson(Map<String, dynamic> json) {
    return PragaInfoModel(
      id: json['id']?.toString() ?? '',
      pragaId: json['praga_id']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      sintomas: json['sintomas']?.toString(),
      bioecologia: json['bioecologia']?.toString(),
      controle: json['controle']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert model to JSON (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'praga_id': pragaId,
      'descricao': descricao,
      'sintomas': sintomas,
      'bioecologia': bioecologia,
      'controle': controle,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from domain entity
  factory PragaInfoModel.fromEntity(PragaInfo entity) {
    return PragaInfoModel(
      id: entity.id,
      pragaId: entity.pragaId,
      descricao: entity.descricao,
      sintomas: entity.sintomas,
      bioecologia: entity.bioecologia,
      controle: entity.controle,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to domain entity
  PragaInfo toEntity() {
    return PragaInfo(
      id: id,
      pragaId: pragaId,
      descricao: descricao,
      sintomas: sintomas,
      bioecologia: bioecologia,
      controle: controle,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  PragaInfoModel copyWith({
    String? id,
    String? pragaId,
    String? descricao,
    String? sintomas,
    String? bioecologia,
    String? controle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PragaInfoModel(
      id: id ?? this.id,
      pragaId: pragaId ?? this.pragaId,
      descricao: descricao ?? this.descricao,
      sintomas: sintomas ?? this.sintomas,
      bioecologia: bioecologia ?? this.bioecologia,
      controle: controle ?? this.controle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
