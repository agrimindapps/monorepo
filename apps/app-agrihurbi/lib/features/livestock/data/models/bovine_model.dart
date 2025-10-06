import 'package:core/core.dart';

import '../../domain/entities/bovine_entity.dart';

part 'bovine_model.g.dart';

/// Model de dados para bovinos com suporte ao Hive
/// 
/// Implementa serialização local (Hive) e conversões para entidades do domínio
/// TypeId: 0 - Reservado para bovinos no sistema Hive
@HiveType(typeId: 0)
class BovineModel extends BovineEntity {
  const BovineModel({
    @HiveField(0) required super.id,
    @HiveField(1) super.createdAt,
    @HiveField(2) super.updatedAt,
    @HiveField(3) required super.isActive,
    @HiveField(4) required super.registrationId,
    @HiveField(5) required super.commonName,
    @HiveField(6) required super.originCountry,
    @HiveField(7) required super.imageUrls,
    @HiveField(8) super.thumbnailUrl,
    @HiveField(9) required super.animalType,
    @HiveField(10) required super.origin,
    @HiveField(11) required super.characteristics,
    @HiveField(12) required super.breed,
    @HiveField(13) required super.aptitude,
    @HiveField(14) required super.tags,
    @HiveField(15) required super.breedingSystem,
    @HiveField(16) required super.purpose,
    @HiveField(17) super.notes,
  });

  /// Converte o BovineModel para BovineEntity do domínio
  BovineEntity toEntity() {
    return BovineEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      registrationId: registrationId,
      commonName: commonName,
      originCountry: originCountry,
      imageUrls: imageUrls,
      thumbnailUrl: thumbnailUrl,
      animalType: animalType,
      origin: origin,
      characteristics: characteristics,
      breed: breed,
      aptitude: aptitude,
      tags: tags,
      breedingSystem: breedingSystem,
      purpose: purpose,
      notes: notes,
    );
  }

  /// Cria um BovineModel a partir de uma BovineEntity
  factory BovineModel.fromEntity(BovineEntity entity) {
    return BovineModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      registrationId: entity.registrationId,
      commonName: entity.commonName,
      originCountry: entity.originCountry,
      imageUrls: entity.imageUrls,
      thumbnailUrl: entity.thumbnailUrl,
      animalType: entity.animalType,
      origin: entity.origin,
      characteristics: entity.characteristics,
      breed: entity.breed,
      aptitude: entity.aptitude,
      tags: entity.tags,
      breedingSystem: entity.breedingSystem,
      purpose: entity.purpose,
      notes: entity.notes,
    );
  }

  /// Cria um BovineModel a partir de um JSON Map (Supabase/API)
  factory BovineModel.fromJson(Map<String, dynamic> json) {
    return BovineModel(
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
      animalType: json['animal_type'] as String,
      origin: json['origin'] as String,
      characteristics: json['characteristics'] as String,
      breed: json['breed'] as String,
      aptitude: _parseAptitude(json['aptitude'] as String?),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      breedingSystem: _parseBreedingSystem(json['breeding_system'] as String?),
      purpose: json['purpose'] as String,
    );
  }

  /// Converte o BovineModel para um JSON Map (Supabase/API)
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
      'animal_type': animalType,
      'origin': origin,
      'characteristics': characteristics,
      'breed': breed,
      'aptitude': aptitude.name,
      'tags': tags,
      'breeding_system': breedingSystem.name,
      'purpose': purpose,
    };
  }

  /// Parse string para BovineAptitude enum
  static BovineAptitude _parseAptitude(String? aptitude) {
    if (aptitude == null) return BovineAptitude.mixed;
    
    switch (aptitude.toLowerCase()) {
      case 'dairy':
      case 'leiteira':
        return BovineAptitude.dairy;
      case 'beef':
      case 'corte':
        return BovineAptitude.beef;
      case 'mixed':
      case 'mista':
      default:
        return BovineAptitude.mixed;
    }
  }

  /// Parse string para BreedingSystem enum
  static BreedingSystem _parseBreedingSystem(String? system) {
    if (system == null) return BreedingSystem.extensive;
    
    switch (system.toLowerCase()) {
      case 'extensive':
      case 'extensivo':
        return BreedingSystem.extensive;
      case 'intensive':
      case 'intensivo':
        return BreedingSystem.intensive;
      case 'semiintensive':
      case 'semi-intensive':
      case 'semi_intensive':
      case 'semi-intensivo':
        return BreedingSystem.semiIntensive;
      default:
        return BreedingSystem.extensive;
    }
  }

  /// Cria uma cópia do BovineModel com campos opcionalmente modificados
  @override
  BovineModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? registrationId,
    String? commonName,
    String? originCountry,
    List<String>? imageUrls,
    String? thumbnailUrl,
    String? animalType,
    String? origin,
    String? characteristics,
    String? breed,
    BovineAptitude? aptitude,
    List<String>? tags,
    BreedingSystem? breedingSystem,
    String? purpose,
    String? notes,
  }) {
    return BovineModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      registrationId: registrationId ?? this.registrationId,
      commonName: commonName ?? this.commonName,
      originCountry: originCountry ?? this.originCountry,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      animalType: animalType ?? this.animalType,
      origin: origin ?? this.origin,
      characteristics: characteristics ?? this.characteristics,
      breed: breed ?? this.breed,
      aptitude: aptitude ?? this.aptitude,
      tags: tags ?? this.tags,
      breedingSystem: breedingSystem ?? this.breedingSystem,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
    );
  }

  /// Factory para criar instância vazia para formulários
  factory BovineModel.empty() {
    return const BovineModel(
      id: '',
      isActive: true,
      registrationId: '',
      commonName: '',
      originCountry: '',
      imageUrls: <String>[],
      animalType: '',
      origin: '',
      characteristics: '',
      breed: '',
      aptitude: BovineAptitude.mixed,
      tags: <String>[],
      breedingSystem: BreedingSystem.extensive,
      purpose: '',
    );
  }
}
