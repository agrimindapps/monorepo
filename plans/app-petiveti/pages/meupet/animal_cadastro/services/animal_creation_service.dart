// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../repository/animal_repository.dart';
import '../models/animal_creation_model.dart';
import '../models/animal_form_model.dart';
import 'animal_validation_service.dart';

class AnimalCreationService {
  final AnimalRepository _repository;
  final Uuid _uuid = const Uuid();

  AnimalCreationService({AnimalRepository? repository})
      : _repository = repository ?? AnimalRepository();

  // Create a new animal from form data
  Future<Animal> createAnimal(AnimalFormModel formModel) async {
    // Convert int timestamp to DateTime for validation
    final birthDate =
        DateTime.fromMillisecondsSinceEpoch(formModel.dataNascimento);

    // Validate the form data first
    final validationResult = AnimalValidationService.getValidationSummary(
      nome: formModel.nome,
      especie: formModel.especie,
      raca: formModel.raca,
      dataNascimento: birthDate,
      sexo: formModel.sexo,
      cor: formModel.cor,
      pesoAtual: formModel.pesoAtual,
      observacoes: formModel.observacoes,
    );

    if (!validationResult['isValid']) {
      throw ArgumentError(
          'Dados do formulário inválidos: ${validationResult['errors']}');
    }

    // Sanitize the form data
    final sanitizedModel = _sanitizeFormData(formModel);

    // Create the animal object
    final now = DateTime.now().millisecondsSinceEpoch;
    final animal = Animal(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: 1,
      nome: sanitizedModel.nome,
      especie: sanitizedModel.especie,
      raca: sanitizedModel.raca,
      dataNascimento: sanitizedModel.dataNascimento,
      sexo: sanitizedModel.sexo,
      cor: sanitizedModel.cor,
      pesoAtual: sanitizedModel.pesoAtual ?? 0.0,
      foto: sanitizedModel.foto,
      observacoes: sanitizedModel.observacoes,
    );

    // Save to repository
    final success = await _repository.addAnimal(animal);
    if (!success) {
      throw Exception('Falha ao criar animal no repositório');
    }

    return animal;
  }

  // Update an existing animal
  Future<Animal> updateAnimal(
      String animalId, AnimalFormModel formModel) async {
    // Convert int timestamp to DateTime for validation
    final birthDate =
        DateTime.fromMillisecondsSinceEpoch(formModel.dataNascimento);

    // Validate the form data first
    final validationResult = AnimalValidationService.getValidationSummary(
      nome: formModel.nome,
      especie: formModel.especie,
      raca: formModel.raca,
      dataNascimento: birthDate,
      sexo: formModel.sexo,
      cor: formModel.cor,
      pesoAtual: formModel.pesoAtual,
      observacoes: formModel.observacoes,
    );

    if (!validationResult['isValid']) {
      throw ArgumentError(
          'Dados do formulário inválidos: ${validationResult['errors']}');
    }

    // Get the existing animal
    final existingAnimal = await _repository.getAnimalById(animalId);
    if (existingAnimal == null) {
      throw ArgumentError('Animal não encontrado: $animalId');
    }

    // Sanitize the form data
    final sanitizedModel = _sanitizeFormData(formModel);

    // Create updated animal object
    final updatedAnimal = Animal(
      id: existingAnimal.id,
      createdAt: existingAnimal.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: existingAnimal.isDeleted,
      needsSync: true,
      lastSyncAt: existingAnimal.lastSyncAt,
      version: existingAnimal.version + 1,
      nome: sanitizedModel.nome,
      especie: sanitizedModel.especie,
      raca: sanitizedModel.raca,
      dataNascimento: sanitizedModel.dataNascimento,
      sexo: sanitizedModel.sexo,
      cor: sanitizedModel.cor,
      pesoAtual: sanitizedModel.pesoAtual ?? 0.0,
      foto: sanitizedModel.foto,
      observacoes: sanitizedModel.observacoes,
    );

    // Update in repository
    final success = await _repository.updateAnimal(updatedAnimal);
    if (!success) {
      throw Exception('Falha ao atualizar animal no repositório');
    }

    return updatedAnimal;
  }

  // Delete an animal
  Future<bool> deleteAnimal(String animalId) async {
    final existingAnimal = await _repository.getAnimalById(animalId);
    if (existingAnimal == null) {
      throw ArgumentError('Animal não encontrado: $animalId');
    }

    return await _repository.deleteAnimal(existingAnimal);
  }

  // Create a creation model for tracking the creation process
  AnimalCreationModel createCreationSession(AnimalFormModel formModel) {
    final formData = AnimalFormData(
      nome: formModel.nome,
      especie: formModel.especie,
      raca: formModel.raca,
      dataNascimento:
          DateTime.fromMillisecondsSinceEpoch(formModel.dataNascimento),
      sexo: formModel.sexo,
      cor: formModel.cor,
      pesoAtual: formModel.pesoAtual,
      foto: formModel.foto,
      observacoes: formModel.observacoes,
    );

    return AnimalCreationModel(
      sessionId: _uuid.v4(),
      createdAt: DateTime.now(),
      formData: formData,
    );
  }

  // Validate and prepare creation model
  AnimalCreationModel validateCreationData(AnimalCreationModel creationModel) {
    final validationResult = AnimalValidationService.getValidationSummary(
      nome: creationModel.formData.nome,
      especie: creationModel.formData.especie,
      raca: creationModel.formData.raca,
      dataNascimento: creationModel.formData.dataNascimento,
      sexo: creationModel.formData.sexo,
      cor: creationModel.formData.cor,
      pesoAtual: creationModel.formData.pesoAtual,
      observacoes: creationModel.formData.observacoes,
    );

    final errors = (validationResult['errors'] as Map<String, String?>)
        .values
        .where((error) => error != null)
        .cast<String>()
        .toList();

    final warnings = validationResult['warnings'] as List<String>;

    return creationModel.copyWith(
      validationErrors: [...errors, ...warnings],
    );
  }

  // Sanitize form data before creating/updating animal
  AnimalFormModel _sanitizeFormData(AnimalFormModel formModel) {
    return AnimalFormModel(
      nome: AnimalValidationService.sanitizeNome(formModel.nome),
      especie: formModel.especie, // Species should be from dropdown
      raca: AnimalValidationService.sanitizeRaca(formModel.raca),
      dataNascimento: formModel.dataNascimento,
      sexo: formModel.sexo, // Sex should be from dropdown
      cor: AnimalValidationService.sanitizeCor(formModel.cor),
      pesoAtual: formModel.pesoAtual,
      foto: formModel.foto?.trim(),
      observacoes: formModel.observacoes?.trim(),
    );
  }

  // Business rules validation before creation
  Future<List<String>> validateBusinessRules(AnimalFormModel formModel) async {
    final warnings = <String>[];

    // Check for duplicate names
    if (formModel.nome.isNotEmpty) {
      final existingAnimals = await _repository.getAnimais();
      final duplicateName = existingAnimals.any((animal) =>
          animal.nome.toLowerCase() == formModel.nome.toLowerCase());

      if (duplicateName) {
        warnings.add(
            'Já existe um animal com este nome. Considere usar um nome diferente.');
      }
    }

    // Age-related business rules
    final birthDate =
        DateTime.fromMillisecondsSinceEpoch(formModel.dataNascimento);
    final age = DateTime.now().difference(birthDate).inDays / 365;

    if (age < 0.08) {
      // Less than 1 month
      warnings.add('Animal muito jovem. Certifique-se da data correta.');
    }

    if (age > 25) {
      // Very old
      warnings.add('Idade muito avançada. Verifique a data de nascimento.');
    }

    // Weight-related business rules
    if (formModel.pesoAtual > 0 && formModel.especie.isNotEmpty) {
      final speciesLimits = _getSpeciesTypicalWeights(formModel.especie);
      if (speciesLimits != null) {
        if (formModel.pesoAtual < speciesLimits['typical_min']!) {
          warnings.add(
              'Peso baixo para a espécie. Considere consulta veterinária.');
        }
        if (formModel.pesoAtual > speciesLimits['typical_max']!) {
          warnings.add(
              'Peso alto para a espécie. Considere avaliação nutricional.');
        }
      }
    }

    return warnings;
  }

  // Get typical weight ranges for species
  Map<String, double>? _getSpeciesTypicalWeights(String especie) {
    switch (especie.toLowerCase()) {
      case 'cachorro':
        return {'typical_min': 2.0, 'typical_max': 50.0};
      case 'gato':
        return {'typical_min': 2.5, 'typical_max': 8.0};
      case 'coelho':
        return {'typical_min': 1.0, 'typical_max': 6.0};
      case 'hamster':
        return {'typical_min': 0.08, 'typical_max': 0.15};
      case 'ave':
        return {'typical_min': 0.02, 'typical_max': 1.5};
      default:
        return null;
    }
  }

  // Create animal with comprehensive validation
  Future<Animal> createAnimalWithValidation(AnimalFormModel formModel) async {
    // Run business rules validation
    final businessWarnings = await validateBusinessRules(formModel);

    // Log warnings if any (could be shown to user for confirmation)
    if (businessWarnings.isNotEmpty) {
      // In a real app, you might want to show these warnings to the user
      // and ask for confirmation before proceeding
      debugPrint('Business rule warnings: $businessWarnings');
    }

    // Proceed with creation
    return await createAnimal(formModel);
  }

  // Get creation statistics
  Future<Map<String, dynamic>> getCreationStatistics() async {
    final allAnimals = await _repository.getAnimais();

    final speciesCounts = <String, int>{};
    final sexCounts = <String, int>{};
    var totalWeight = 0.0;
    var averageAge = 0.0;

    for (final animal in allAnimals) {
      // Count species
      speciesCounts[animal.especie] = (speciesCounts[animal.especie] ?? 0) + 1;

      // Count sexes
      sexCounts[animal.sexo] = (sexCounts[animal.sexo] ?? 0) + 1;

      // Sum weight
      totalWeight += animal.pesoAtual;

      // Calculate age
      final birthDate =
          DateTime.fromMillisecondsSinceEpoch(animal.dataNascimento);
      final age = DateTime.now().difference(birthDate).inDays / 365;
      averageAge += age;
    }

    if (allAnimals.isNotEmpty) {
      averageAge /= allAnimals.length;
    }

    return {
      'total_animals': allAnimals.length,
      'species_distribution': speciesCounts,
      'sex_distribution': sexCounts,
      'average_weight':
          allAnimals.isNotEmpty ? totalWeight / allAnimals.length : 0.0,
      'average_age': averageAge,
      'most_common_species': speciesCounts.isNotEmpty
          ? speciesCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : null,
    };
  }

  // Prepare form data for editing existing animal
  static AnimalFormModel fromAnimal(Animal animal) {
    return AnimalFormModel(
      nome: animal.nome,
      especie: animal.especie,
      raca: animal.raca,
      dataNascimento: animal.dataNascimento,
      sexo: animal.sexo,
      cor: animal.cor,
      pesoAtual: animal.pesoAtual,
      foto: animal.foto,
      observacoes: animal.observacoes,
    );
  }
}
