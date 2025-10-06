import 'package:core/core.dart' show Equatable;
import 'medication_dosage_input.dart';

/// Concentração disponível do medicamento
class MedicationConcentration extends Equatable {
  final double value; // mg/ml
  final String unit;
  final String description; // "10mg/ml", "25mg/ml", etc.

  const MedicationConcentration({
    required this.value,
    required this.unit,
    required this.description,
  });

  @override
  List<Object> get props => [value, unit, description];
}

/// Dosagem por espécie e condição
class DosageRange extends Equatable {
  final double minDose; // mg/kg
  final double maxDose; // mg/kg
  final double? toxicDose; // mg/kg
  final double? lethalDose; // mg/kg
  final Species species;
  final AgeGroup? ageGroup; // null = todas as idades
  final List<SpecialCondition> applicableConditions;

  const DosageRange({
    required this.minDose,
    required this.maxDose,
    this.toxicDose,
    this.lethalDose,
    required this.species,
    this.ageGroup,
    this.applicableConditions = const [],
  });

  /// Verifica se a dosagem está dentro da faixa segura
  bool isDoseInSafeRange(double dosePerKg) {
    return dosePerKg >= minDose && dosePerKg <= maxDose;
  }

  /// Verifica se a dosagem pode ser tóxica
  bool isDosePotentiallyToxic(double dosePerKg) {
    return toxicDose != null && dosePerKg >= toxicDose!;
  }

  /// Verifica se a dosagem pode ser letal
  bool isDosePotentiallyLethal(double dosePerKg) {
    return lethalDose != null && dosePerKg >= lethalDose!;
  }

  @override
  List<Object?> get props => [
    minDose,
    maxDose,
    toxicDose,
    lethalDose,
    species,
    ageGroup,
    applicableConditions,
  ];
}

/// Contraindicação do medicamento
class Contraindication extends Equatable {
  final String condition;
  final String reason;
  final bool isAbsolute; // true = contraindicação absoluta
  final String? alternative; // medicamento alternativo

  const Contraindication({
    required this.condition,
    required this.reason,
    this.isAbsolute = false,
    this.alternative,
  });

  @override
  List<Object?> get props => [condition, reason, isAbsolute, alternative];
}

/// Dados completos do medicamento
class MedicationData extends Equatable {
  final String id;
  final String name;
  final String activeIngredient;
  final String category; // "Antibiótico", "Anti-inflamatório", etc.
  final List<String> indications;
  final List<DosageRange> dosageRanges;
  final List<MedicationConcentration> concentrations;
  final List<String> pharmaceuticalForms; // "Comprimido", "Suspensão", etc.
  final List<AdministrationFrequency> recommendedFrequencies;
  final List<String> administrationRoutes; // "Oral", "IV", "IM", etc.
  final List<Contraindication> contraindications;
  final List<String> sideEffects;
  final List<String> drugInteractions;
  final String? pregnancyCategory; // A, B, C, D, X
  final String? lactationSafety;
  final Map<Species, List<String>> speciesSpecificWarnings;
  final String? storageInstructions;
  final String? clinicalNotes;
  final bool requiresPrescription;
  final DateTime lastUpdated;

  const MedicationData({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.category,
    required this.indications,
    required this.dosageRanges,
    required this.concentrations,
    required this.pharmaceuticalForms,
    required this.recommendedFrequencies,
    required this.administrationRoutes,
    this.contraindications = const [],
    this.sideEffects = const [],
    this.drugInteractions = const [],
    this.pregnancyCategory,
    this.lactationSafety,
    this.speciesSpecificWarnings = const {},
    this.storageInstructions,
    this.clinicalNotes,
    this.requiresPrescription = true,
    required this.lastUpdated,
  });

  /// Retorna a faixa de dosagem para uma espécie e grupo de idade específicos
  DosageRange? getDosageRange(Species species, AgeGroup ageGroup) {
    final specificRange = dosageRanges.firstWhere(
      (range) => range.species == species && range.ageGroup == ageGroup,
      orElse: () => DosageRange(minDose: 0, maxDose: 0, species: species),
    );

    if (specificRange.maxDose > 0) return specificRange;
    final generalRange = dosageRanges.firstWhere(
      (range) => range.species == species && range.ageGroup == null,
      orElse: () => DosageRange(minDose: 0, maxDose: 0, species: species),
    );

    return generalRange.maxDose > 0 ? generalRange : null;
  }

  /// Verifica se o medicamento é contraindicado para as condições especificadas
  List<Contraindication> getContraindications(
    List<SpecialCondition> conditions,
  ) {
    return contraindications
        .where(
          (contraindication) => conditions.any(
            (condition) => contraindication.condition.toLowerCase().contains(
              condition.displayName.toLowerCase(),
            ),
          ),
        )
        .toList();
  }

  /// Verifica se o medicamento é seguro para gestantes
  bool isSafeForPregnancy() {
    return pregnancyCategory == 'A' || pregnancyCategory == 'B';
  }

  /// Verifica se o medicamento é seguro para lactantes
  bool isSafeForLactation() {
    return lactationSafety?.toLowerCase().contains('seguro') ?? false;
  }

  /// Retorna avisos específicos da espécie
  List<String> getSpeciesWarnings(Species species) {
    return speciesSpecificWarnings[species] ?? [];
  }

  /// Verifica se o medicamento é adequado para a idade
  bool isAppropriateForAge(AgeGroup ageGroup, Species species) {
    final range = getDosageRange(species, ageGroup);
    return range != null && range.maxDose > 0;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    activeIngredient,
    category,
    indications,
    dosageRanges,
    concentrations,
    pharmaceuticalForms,
    recommendedFrequencies,
    administrationRoutes,
    contraindications,
    sideEffects,
    drugInteractions,
    pregnancyCategory,
    lactationSafety,
    speciesSpecificWarnings,
    storageInstructions,
    clinicalNotes,
    requiresPrescription,
    lastUpdated,
  ];

  @override
  String toString() {
    return 'MedicationData(id: $id, name: $name, category: $category)';
  }
}
