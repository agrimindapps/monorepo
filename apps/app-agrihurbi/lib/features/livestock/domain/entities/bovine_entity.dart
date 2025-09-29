import 'animal_base_entity.dart';

/// Enumeração para aptidão bovina
enum BovineAptitude {
  dairy('Leiteira'),
  beef('Corte'),
  mixed('Mista');

  const BovineAptitude(displayName);
  final String displayName;
}

/// Enumeração para sistema de criação
enum BreedingSystem {
  extensive('Extensivo'),
  intensive('Intensivo'),
  semiIntensive('Semi-intensivo');

  const BreedingSystem(displayName);
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
    required animalType,
    required origin,
    required characteristics,
    required breed,
    required aptitude,
    required tags,
    required breedingSystem,
    required purpose,
    notes,
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
      id: id ?? id,
      createdAt: createdAt ?? createdAt,
      updatedAt: updatedAt ?? updatedAt,
      isActive: isActive ?? isActive,
      registrationId: registrationId ?? registrationId,
      commonName: commonName ?? commonName,
      originCountry: originCountry ?? originCountry,
      imageUrls: imageUrls ?? imageUrls,
      thumbnailUrl: thumbnailUrl ?? thumbnailUrl,
      animalType: animalType ?? animalType,
      origin: origin ?? origin,
      characteristics: characteristics ?? characteristics,
      breed: breed ?? breed,
      aptitude: aptitude ?? aptitude,
      tags: tags ?? tags,
      breedingSystem: breedingSystem ?? breedingSystem,
      purpose: purpose ?? purpose,
      notes: notes ?? notes,
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