import 'animal_base_entity.dart';

/// Enumeração para temperamento equino
enum EquineTemperament {
  calm('Calmo'),
  spirited('Vivaz'),
  gentle('Dócil'),
  energetic('Energético'),
  docile('Manso');

  const EquineTemperament(displayName);
  final String displayName;
}

/// Enumeração para pelagem equina
enum CoatColor {
  bay('Baio'),
  chestnut('Alazão'),
  black('Preto'),
  gray('Tordilho'),
  palomino('Palomino'),
  pinto('Pampa'),
  roan('Rosilho');

  const CoatColor(displayName);
  final String displayName;
}

/// Enumeração para uso principal do equino
enum EquinePrimaryUse {
  riding('Montaria'),
  sport('Esporte'),
  work('Trabalho'),
  breeding('Reprodução'),
  leisure('Lazer');

  const EquinePrimaryUse(displayName);
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
    required history,
    required temperament,
    required coat,
    required primaryUse,
    required geneticInfluences,
    required height,
    required weight,
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
      id: id ?? id,
      createdAt: createdAt ?? createdAt,
      updatedAt: updatedAt ?? updatedAt,
      isActive: isActive ?? isActive,
      registrationId: registrationId ?? registrationId,
      commonName: commonName ?? commonName,
      originCountry: originCountry ?? originCountry,
      imageUrls: imageUrls ?? imageUrls,
      thumbnailUrl: thumbnailUrl ?? thumbnailUrl,
      history: history ?? history,
      temperament: temperament ?? temperament,
      coat: coat ?? coat,
      primaryUse: primaryUse ?? primaryUse,
      geneticInfluences: geneticInfluences ?? geneticInfluences,
      height: height ?? height,
      weight: weight ?? weight,
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
      imageUrls: [],
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