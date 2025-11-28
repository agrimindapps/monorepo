import '../../domain/entities/planta_info.dart';

/// PlantaInfoModel - Data layer
/// Extends PlantaInfo entity with JSON serialization for Supabase
/// 1:1 relationship with Praga - stores complementary information for weeds
class PlantaInfoModel extends PlantaInfo {
  const PlantaInfoModel({
    required super.id,
    required super.pragaId,
    super.ciclo,
    super.reproducao,
    super.habitat,
    super.adaptacoes,
    super.altura,
    super.filotaxia,
    super.formaLimbo,
    super.superficie,
    super.consistencia,
    super.nervacao,
    super.nervacaoComprimento,
    super.inflorescencia,
    super.perianto,
    super.tipologiaFruto,
    super.observacoes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (Supabase format)
  factory PlantaInfoModel.fromJson(Map<String, dynamic> json) {
    return PlantaInfoModel(
      id: json['id']?.toString() ?? '',
      pragaId: json['praga_id']?.toString() ?? '',
      ciclo: json['ciclo']?.toString(),
      reproducao: json['reproducao']?.toString(),
      habitat: json['habitat']?.toString(),
      adaptacoes: json['adaptacoes']?.toString(),
      altura: json['altura']?.toString(),
      filotaxia: json['filotaxia']?.toString(),
      formaLimbo: json['forma_limbo']?.toString(),
      superficie: json['superficie']?.toString(),
      consistencia: json['consistencia']?.toString(),
      nervacao: json['nervacao']?.toString(),
      nervacaoComprimento: json['nervacao_comprimento']?.toString(),
      inflorescencia: json['inflorescencia']?.toString(),
      perianto: json['perianto']?.toString(),
      tipologiaFruto: json['tipologia_fruto']?.toString(),
      observacoes: json['observacoes']?.toString(),
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
      'ciclo': ciclo,
      'reproducao': reproducao,
      'habitat': habitat,
      'adaptacoes': adaptacoes,
      'altura': altura,
      'filotaxia': filotaxia,
      'forma_limbo': formaLimbo,
      'superficie': superficie,
      'consistencia': consistencia,
      'nervacao': nervacao,
      'nervacao_comprimento': nervacaoComprimento,
      'inflorescencia': inflorescencia,
      'perianto': perianto,
      'tipologia_fruto': tipologiaFruto,
      'observacoes': observacoes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from domain entity
  factory PlantaInfoModel.fromEntity(PlantaInfo entity) {
    return PlantaInfoModel(
      id: entity.id,
      pragaId: entity.pragaId,
      ciclo: entity.ciclo,
      reproducao: entity.reproducao,
      habitat: entity.habitat,
      adaptacoes: entity.adaptacoes,
      altura: entity.altura,
      filotaxia: entity.filotaxia,
      formaLimbo: entity.formaLimbo,
      superficie: entity.superficie,
      consistencia: entity.consistencia,
      nervacao: entity.nervacao,
      nervacaoComprimento: entity.nervacaoComprimento,
      inflorescencia: entity.inflorescencia,
      perianto: entity.perianto,
      tipologiaFruto: entity.tipologiaFruto,
      observacoes: entity.observacoes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to domain entity
  PlantaInfo toEntity() {
    return PlantaInfo(
      id: id,
      pragaId: pragaId,
      ciclo: ciclo,
      reproducao: reproducao,
      habitat: habitat,
      adaptacoes: adaptacoes,
      altura: altura,
      filotaxia: filotaxia,
      formaLimbo: formaLimbo,
      superficie: superficie,
      consistencia: consistencia,
      nervacao: nervacao,
      nervacaoComprimento: nervacaoComprimento,
      inflorescencia: inflorescencia,
      perianto: perianto,
      tipologiaFruto: tipologiaFruto,
      observacoes: observacoes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  PlantaInfoModel copyWith({
    String? id,
    String? pragaId,
    String? ciclo,
    String? reproducao,
    String? habitat,
    String? adaptacoes,
    String? altura,
    String? filotaxia,
    String? formaLimbo,
    String? superficie,
    String? consistencia,
    String? nervacao,
    String? nervacaoComprimento,
    String? inflorescencia,
    String? perianto,
    String? tipologiaFruto,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantaInfoModel(
      id: id ?? this.id,
      pragaId: pragaId ?? this.pragaId,
      ciclo: ciclo ?? this.ciclo,
      reproducao: reproducao ?? this.reproducao,
      habitat: habitat ?? this.habitat,
      adaptacoes: adaptacoes ?? this.adaptacoes,
      altura: altura ?? this.altura,
      filotaxia: filotaxia ?? this.filotaxia,
      formaLimbo: formaLimbo ?? this.formaLimbo,
      superficie: superficie ?? this.superficie,
      consistencia: consistencia ?? this.consistencia,
      nervacao: nervacao ?? this.nervacao,
      nervacaoComprimento: nervacaoComprimento ?? this.nervacaoComprimento,
      inflorescencia: inflorescencia ?? this.inflorescencia,
      perianto: perianto ?? this.perianto,
      tipologiaFruto: tipologiaFruto ?? this.tipologiaFruto,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
