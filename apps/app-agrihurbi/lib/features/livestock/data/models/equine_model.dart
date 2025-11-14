
import '../../domain/entities/equine_entity.dart';


/// Model de dados para equinos com suporte ao Hive
/// 
/// Implementa serialização local (Hive) e conversões para entidades do domínio
/// TypeId: 1 - Reservado para equinos no sistema Hive
class EquineModel extends EquineEntity {
  const EquineModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required super.isActive,
    required super.registrationId,
    required super.commonName,
    required super.originCountry,
    required super.imageUrls,
    super.thumbnailUrl,
    required super.history,
    required super.temperament,
    required super.coat,
    required super.primaryUse,
    required super.geneticInfluences,
    required super.height,
    required super.weight,
  });

  /// Converte o EquineModel para EquineEntity do domínio
  EquineEntity toEntity() {
    return EquineEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      registrationId: registrationId,
      commonName: commonName,
      originCountry: originCountry,
      imageUrls: imageUrls,
      thumbnailUrl: thumbnailUrl,
      history: history,
      temperament: temperament,
      coat: coat,
      primaryUse: primaryUse,
      geneticInfluences: geneticInfluences,
      height: height,
      weight: weight,
    );
  }

  /// Cria um EquineModel a partir de uma EquineEntity
  factory EquineModel.fromEntity(EquineEntity entity) {
    return EquineModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      registrationId: entity.registrationId,
      commonName: entity.commonName,
      originCountry: entity.originCountry,
      imageUrls: entity.imageUrls,
      thumbnailUrl: entity.thumbnailUrl,
      history: entity.history,
      temperament: entity.temperament,
      coat: entity.coat,
      primaryUse: entity.primaryUse,
      geneticInfluences: entity.geneticInfluences,
      height: entity.height,
      weight: entity.weight,
    );
  }

  /// Cria um EquineModel a partir de um JSON Map (Supabase/API)
  factory EquineModel.fromJson(Map<String, dynamic> json) {
    return EquineModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      registrationId: json['registration_id'] as String? ?? '',
      commonName: json['common_name'] as String,
      originCountry: json['origin_country'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      thumbnailUrl: json['thumbnail_url'] as String?,
      history: json['history'] as String,
      temperament: _parseTemperament(json['temperament'] as String?),
      coat: _parseCoatColor(json['coat'] as String?),
      primaryUse: _parsePrimaryUse(json['primary_use'] as String?),
      geneticInfluences: json['genetic_influences'] as String,
      height: json['height'] as String,
      weight: json['weight'] as String,
    );
  }

  /// Converte o EquineModel para um JSON Map (Supabase/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'registration_id': registrationId,
      'common_name': commonName,
      'origin_country': originCountry,
      'image_urls': imageUrls,
      'thumbnail_url': thumbnailUrl,
      'history': history,
      'temperament': temperament.name,
      'coat': coat.name,
      'primary_use': primaryUse.name,
      'genetic_influences': geneticInfluences,
      'height': height,
      'weight': weight,
    };
  }

  /// Parse string para EquineTemperament enum
  static EquineTemperament _parseTemperament(String? temperament) {
    if (temperament == null) return EquineTemperament.calm;
    
    switch (temperament.toLowerCase()) {
      case 'calm':
      case 'calmo':
        return EquineTemperament.calm;
      case 'spirited':
      case 'vivaz':
        return EquineTemperament.spirited;
      case 'gentle':
      case 'dócil':
      case 'docil':
        return EquineTemperament.gentle;
      case 'energetic':
      case 'energético':
      case 'energetico':
        return EquineTemperament.energetic;
      case 'docile':
      case 'manso':
        return EquineTemperament.docile;
      default:
        return EquineTemperament.calm;
    }
  }

  /// Parse string para CoatColor enum
  static CoatColor _parseCoatColor(String? coat) {
    if (coat == null) return CoatColor.bay;
    
    switch (coat.toLowerCase()) {
      case 'bay':
      case 'baio':
        return CoatColor.bay;
      case 'chestnut':
      case 'alazão':
      case 'alazao':
        return CoatColor.chestnut;
      case 'black':
      case 'preto':
        return CoatColor.black;
      case 'gray':
      case 'grey':
      case 'tordilho':
        return CoatColor.gray;
      case 'palomino':
        return CoatColor.palomino;
      case 'pinto':
      case 'pampa':
        return CoatColor.pinto;
      case 'roan':
      case 'rosilho':
        return CoatColor.roan;
      default:
        return CoatColor.bay;
    }
  }

  /// Parse string para EquinePrimaryUse enum
  static EquinePrimaryUse _parsePrimaryUse(String? use) {
    if (use == null) return EquinePrimaryUse.riding;
    
    switch (use.toLowerCase()) {
      case 'riding':
      case 'montaria':
        return EquinePrimaryUse.riding;
      case 'sport':
      case 'esporte':
        return EquinePrimaryUse.sport;
      case 'work':
      case 'trabalho':
        return EquinePrimaryUse.work;
      case 'breeding':
      case 'reprodução':
      case 'reproducao':
        return EquinePrimaryUse.breeding;
      case 'leisure':
      case 'lazer':
        return EquinePrimaryUse.leisure;
      default:
        return EquinePrimaryUse.riding;
    }
  }

  /// Cria uma cópia do EquineModel com campos opcionalmente modificados
  @override
  EquineModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? registrationId,
    String? commonName,
    String? originCountry,
    List<String>? imageUrls,
    String? thumbnailUrl,
    String? history,
    EquineTemperament? temperament,
    CoatColor? coat,
    EquinePrimaryUse? primaryUse,
    String? geneticInfluences,
    String? height,
    String? weight,
  }) {
    return EquineModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      registrationId: registrationId ?? this.registrationId,
      commonName: commonName ?? this.commonName,
      originCountry: originCountry ?? this.originCountry,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      history: history ?? this.history,
      temperament: temperament ?? this.temperament,
      coat: coat ?? this.coat,
      primaryUse: primaryUse ?? this.primaryUse,
      geneticInfluences: geneticInfluences ?? this.geneticInfluences,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  /// Factory para criar instância vazia para formulários
  factory EquineModel.empty() {
    return const EquineModel(
      id: '',
      isActive: true,
      registrationId: '',
      commonName: '',
      originCountry: '',
      imageUrls: <String>[],
      history: '',
      temperament: EquineTemperament.calm,
      coat: CoatColor.bay,
      primaryUse: EquinePrimaryUse.riding,
      geneticInfluences: '',
      height: '',
      weight: '',
    );
  }
}
