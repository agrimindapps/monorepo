import 'package:core/core.dart';

import 'animal_base_entity.dart';


/// Enumeração para aptidão bovina
enum BovineAptitude {
  dairy('Leiteira'),
  beef('Corte'),
  mixed('Mista');

  const BovineAptitude(this.displayName);
  final String displayName;
}

/// Enumeração para sistema de criação
enum BreedingSystem {
  extensive('Extensivo'),
  intensive('Intensivo'),
  semiIntensive('Semi-intensivo');

  const BreedingSystem(this.displayName);
  final String displayName;
}

/// Entidade do domínio para bovinos
/// Herda campos comuns de AnimalBaseEntity e adiciona campos específicos
/// Baseada na migração de BovinoClass do projeto original com 17 campos mapeados
class BovineEntity extends AnimalBaseEntity {
  const BovineEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required super.isActive,
    required super.registrationId,
    required super.commonName,
    required super.originCountry,
    required super.imageUrls,
    super.thumbnailUrl,
    required this.animalType,
    required this.origin,
    required this.characteristics,
    required this.breed,
    required this.aptitude,
    required this.tags,
    required this.breedingSystem,
    required this.purpose,
    this.notes,
  });

  /// Tipo específico do animal
  final String animalType;

  /// Origem detalhada do bovino
  final String origin;

  /// Características físicas do bovino
  final String characteristics;

  /// Raça específica do bovino
  final String breed;

  /// Aptidão do bovino (leiteiro, corte, misto)
  final BovineAptitude aptitude;

  /// Lista de tags categorizadas
  final List<String> tags;

  /// Sistema de criação (extensivo, intensivo, semi-intensivo)
  final BreedingSystem breedingSystem;

  /// Finalidade específica da criação
  final String purpose;

  /// Observações adicionais sobre o bovino
  final String? notes;

  @override
  List<Object?> get props => [
        ...super.props,
        animalType,
        origin,
        characteristics,
        breed,
        aptitude,
        tags,
        breedingSystem,
        purpose,
        notes,
      ];

  /// Cria uma cópia da entidade com campos atualizados
  @override
  BovineEntity copyWith({
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
    return BovineEntity(
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
  factory BovineEntity.empty() {
    return const BovineEntity(
      id: '',
      isActive: true,
      registrationId: '',
      commonName: '',
      originCountry: '',
      imageUrls: [],
      animalType: '',
      origin: '',
      characteristics: '',
      breed: '',
      aptitude: BovineAptitude.mixed,
      tags: [],
      breedingSystem: BreedingSystem.extensive,
      purpose: '',
      notes: null,
    );
  }

  @override
  String toString() {
    return 'BovineEntity(id: $id, commonName: $commonName, breed: $breed, aptitude: ${aptitude.displayName})';
  }
}
