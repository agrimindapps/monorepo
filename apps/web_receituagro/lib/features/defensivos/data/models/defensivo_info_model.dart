import '../../domain/entities/defensivo_info.dart';

/// DefensivoInfoModel - Data layer
/// Extends DefensivoInfo entity with JSON serialization for Supabase
/// 1:1 relationship with Defensivo - stores long-text complementary information
class DefensivoInfoModel extends DefensivoInfo {
  const DefensivoInfoModel({
    required super.id,
    required super.defensivoId,
    super.embalagens,
    super.tecnologia,
    super.pHumanas,
    super.pAmbiental,
    super.manejoResistencia,
    super.compatibilidade,
    super.manejoIntegrado,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (Supabase format)
  factory DefensivoInfoModel.fromJson(Map<String, dynamic> json) {
    return DefensivoInfoModel(
      id: json['id']?.toString() ?? '',
      defensivoId: json['defensivo_id']?.toString() ?? '',
      embalagens: json['embalagens']?.toString(),
      tecnologia: json['tecnologia']?.toString(),
      pHumanas: json['p_humanas']?.toString(),
      pAmbiental: json['p_ambiental']?.toString(),
      manejoResistencia: json['manejo_resistencia']?.toString(),
      compatibilidade: json['compatibilidade']?.toString(),
      manejoIntegrado: json['manejo_integrado']?.toString(),
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
      'defensivo_id': defensivoId,
      'embalagens': embalagens,
      'tecnologia': tecnologia,
      'p_humanas': pHumanas,
      'p_ambiental': pAmbiental,
      'manejo_resistencia': manejoResistencia,
      'compatibilidade': compatibilidade,
      'manejo_integrado': manejoIntegrado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from domain entity
  factory DefensivoInfoModel.fromEntity(DefensivoInfo entity) {
    return DefensivoInfoModel(
      id: entity.id,
      defensivoId: entity.defensivoId,
      embalagens: entity.embalagens,
      tecnologia: entity.tecnologia,
      pHumanas: entity.pHumanas,
      pAmbiental: entity.pAmbiental,
      manejoResistencia: entity.manejoResistencia,
      compatibilidade: entity.compatibilidade,
      manejoIntegrado: entity.manejoIntegrado,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to domain entity
  DefensivoInfo toEntity() {
    return DefensivoInfo(
      id: id,
      defensivoId: defensivoId,
      embalagens: embalagens,
      tecnologia: tecnologia,
      pHumanas: pHumanas,
      pAmbiental: pAmbiental,
      manejoResistencia: manejoResistencia,
      compatibilidade: compatibilidade,
      manejoIntegrado: manejoIntegrado,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  DefensivoInfoModel copyWith({
    String? id,
    String? defensivoId,
    String? embalagens,
    String? tecnologia,
    String? pHumanas,
    String? pAmbiental,
    String? manejoResistencia,
    String? compatibilidade,
    String? manejoIntegrado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefensivoInfoModel(
      id: id ?? this.id,
      defensivoId: defensivoId ?? this.defensivoId,
      embalagens: embalagens ?? this.embalagens,
      tecnologia: tecnologia ?? this.tecnologia,
      pHumanas: pHumanas ?? this.pHumanas,
      pAmbiental: pAmbiental ?? this.pAmbiental,
      manejoResistencia: manejoResistencia ?? this.manejoResistencia,
      compatibilidade: compatibilidade ?? this.compatibilidade,
      manejoIntegrado: manejoIntegrado ?? this.manejoIntegrado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
