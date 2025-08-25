import 'package:equatable/equatable.dart';

/// Enumeração para espécies suportadas
enum Species {
  dog('Cão'),
  cat('Gato');

  const Species(this.displayName);
  final String displayName;
}

/// Enumeração para grupos de idade
enum AgeGroup {
  puppy('Filhote (< 6 meses)'),
  young('Jovem (6m - 2anos)'),
  adult('Adulto (2-7 anos)'),
  senior('Sênior (> 7 anos)');

  const AgeGroup(this.displayName);
  final String displayName;
}

/// Enumeração para condições especiais
enum SpecialCondition {
  healthy('Saudável'),
  renalDisease('Doença Renal'),
  hepaticDisease('Doença Hepática'),
  heartDisease('Doença Cardíaca'),
  diabetes('Diabetes'),
  pregnant('Gestante'),
  lactating('Lactante'),
  geriatric('Geriátrico');

  const SpecialCondition(this.displayName);
  final String displayName;
}

/// Enumeração para frequência de administração
enum AdministrationFrequency {
  once('1x/dia (SID)', 1),
  twice('2x/dia (BID)', 2),
  thrice('3x/dia (TID)', 3),
  fourTimes('4x/dia (QID)', 4),
  everyEightHours('A cada 8h', 3),
  everySixHours('A cada 6h', 4);

  const AdministrationFrequency(this.displayName, this.timesPerDay);
  final String displayName;
  final int timesPerDay;
}

/// Entrada de dados para cálculo de dosagem de medicamentos
class MedicationDosageInput extends Equatable {
  final Species species;
  final double weight; // kg
  final AgeGroup ageGroup;
  final String medicationId;
  final double? concentration; // mg/ml
  final String? pharmaceuticalForm;
  final AdministrationFrequency frequency;
  final List<SpecialCondition> specialConditions;
  final bool isEmergency;
  final String? veterinarianNotes;

  const MedicationDosageInput({
    required this.species,
    required this.weight,
    required this.ageGroup,
    required this.medicationId,
    this.concentration,
    this.pharmaceuticalForm,
    required this.frequency,
    this.specialConditions = const [],
    this.isEmergency = false,
    this.veterinarianNotes,
  });

  /// Copia a instância com os parâmetros modificados
  MedicationDosageInput copyWith({
    Species? species,
    double? weight,
    AgeGroup? ageGroup,
    String? medicationId,
    double? concentration,
    String? pharmaceuticalForm,
    AdministrationFrequency? frequency,
    List<SpecialCondition>? specialConditions,
    bool? isEmergency,
    String? veterinarianNotes,
  }) {
    return MedicationDosageInput(
      species: species ?? this.species,
      weight: weight ?? this.weight,
      ageGroup: ageGroup ?? this.ageGroup,
      medicationId: medicationId ?? this.medicationId,
      concentration: concentration ?? this.concentration,
      pharmaceuticalForm: pharmaceuticalForm ?? this.pharmaceuticalForm,
      frequency: frequency ?? this.frequency,
      specialConditions: specialConditions ?? this.specialConditions,
      isEmergency: isEmergency ?? this.isEmergency,
      veterinarianNotes: veterinarianNotes ?? this.veterinarianNotes,
    );
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'species': species.name,
      'weight': weight,
      'ageGroup': ageGroup.name,
      'medicationId': medicationId,
      'concentration': concentration,
      'pharmaceuticalForm': pharmaceuticalForm,
      'frequency': frequency.name,
      'specialConditions': specialConditions.map((e) => e.name).toList(),
      'isEmergency': isEmergency,
      'veterinarianNotes': veterinarianNotes,
    };
  }

  /// Cria instância a partir de Map
  factory MedicationDosageInput.fromMap(Map<String, dynamic> map) {
    return MedicationDosageInput(
      species: Species.values.firstWhere((e) => e.name == map['species']),
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      ageGroup: AgeGroup.values.firstWhere((e) => e.name == map['ageGroup']),
      medicationId: map['medicationId'] as String? ?? '',
      concentration: (map['concentration'] as num?)?.toDouble(),
      pharmaceuticalForm: map['pharmaceuticalForm'] as String?,
      frequency: AdministrationFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
      ),
      specialConditions: (map['specialConditions'] as List<dynamic>?)
          ?.map((e) => SpecialCondition.values.firstWhere(
                (sc) => sc.name == e,
              ))
          .toList() ?? [],
      isEmergency: map['isEmergency'] as bool? ?? false,
      veterinarianNotes: map['veterinarianNotes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        species,
        weight,
        ageGroup,
        medicationId,
        concentration,
        pharmaceuticalForm,
        frequency,
        specialConditions,
        isEmergency,
        veterinarianNotes,
      ];

  @override
  String toString() {
    return 'MedicationDosageInput(species: $species, weight: ${weight}kg, '
        'ageGroup: $ageGroup, medicationId: $medicationId, '
        'frequency: $frequency, conditions: $specialConditions)';
  }
}