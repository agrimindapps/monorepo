import 'package:core/core.dart';
import 'animal_base_entity.dart';


/// Enumeração para temperamento equino
enum EquineTemperament {
  @HiveField(0)
  calm('Calmo'),
  @HiveField(1)
  spirited('Vivaz'),
  @HiveField(2)
  gentle('Dócil'),
  @HiveField(3)
  energetic('Energético'),
  @HiveField(4)
  docile('Manso');

  const EquineTemperament(this.displayName);
  final String displayName;
}

/// Enumeração para pelagem equina
enum CoatColor {
  @HiveField(0)
  bay('Baio'),
  @HiveField(1)
  chestnut('Alazão'),
  @HiveField(2)
  black('Preto'),
  @HiveField(3)
  gray('Tordilho'),
  @HiveField(4)
  palomino('Palomino'),
  @HiveField(5)
  pinto('Pampa'),
  @HiveField(6)
  roan('Rosilho');

  const CoatColor(this.displayName);
  final String displayName;
}

/// Enumeração para uso principal do equino
enum EquinePrimaryUse {
  @HiveField(0)
  riding('Montaria'),
  @HiveField(1)
  sport('Esporte'),
  @HiveField(2)
  work('Trabalho'),
  @HiveField(3)
  breeding('Reprodução'),
  @HiveField(4)
  leisure('Lazer');

  const EquinePrimaryUse(this.displayName);
  final String displayName;
}

/// Entidade do domínio para equinos
/// Herda campos comuns de AnimalBaseEntity e adiciona 15 campos específicos
/// Baseada na migração de EquinosClass do projeto original
class EquineEntity extends AnimalBaseEntity {
  const EquineEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required super.isActive,
    required super.registrationId,
    required super.commonName,
    required super.originCountry,
    required super.imageUrls,
    super.thumbnailUrl,
    required this.history,
    required this.temperament,
    required this.coat,
    required this.primaryUse,
    required this.geneticInfluences,
    required this.height,
    required this.weight,
  });

  /// História da raça equina
  final String history;

  /// Temperamento do equino
  final EquineTemperament temperament;

  /// Tipo/cor da pelagem
  final CoatColor coat;

  /// Uso principal do equino
  final EquinePrimaryUse primaryUse;

  /// Influências genéticas da raça
  final String geneticInfluences;

  /// Altura física do equino
  final String height;

  /// Peso físico do equino
  final String weight;

  @override
  List<Object?> get props => [
        ...super.props,
        history,
        temperament,
        coat,
        primaryUse,
        geneticInfluences,
        height,
        weight,
      ];

  /// Cria uma cópia da entidade com campos atualizados
  @override
  EquineEntity copyWith({
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
    return EquineEntity(
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
  factory EquineEntity.empty() {
    return const EquineEntity(
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

  @override
  String toString() {
    return 'EquineEntity(id: $id, commonName: $commonName, temperament: ${temperament.displayName})';
  }
}
