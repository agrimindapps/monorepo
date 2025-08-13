// Project imports:
import '../../database/planta_model.dart';
import '../../repository/planta_repository.dart';

/// Service to ensure data integrity for plant operations
/// TODO: Reimplementar usando PlantaConfigModel e SimpleTaskService
class DataIntegrityService {
  static DataIntegrityService? _instance;
  static DataIntegrityService get instance =>
      _instance ??= DataIntegrityService._();
  DataIntegrityService._();

  PlantaRepository get _plantaRepository => PlantaRepository.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _plantaRepository.initialize();
    _isInitialized = true;
  }

  /// Validates plant data before saving (simplified version)
  ValidationResult validatePlantData(PlantaModel planta) {
    final errors = <String>[];

    // Required field validations
    if (planta.nome == null || planta.nome!.trim().isEmpty) {
      errors.add('Nome da planta é obrigatório');
    }

    if (planta.nome != null && planta.nome!.length > 100) {
      errors.add('Nome da planta deve ter no máximo 100 caracteres');
    }

    if (planta.especie != null && planta.especie!.length > 100) {
      errors.add('Espécie deve ter no máximo 100 caracteres');
    }

    if (planta.observacoes != null && planta.observacoes!.length > 1000) {
      errors.add('Observações devem ter no máximo 1000 caracteres');
    }

    // Validate image paths
    if (planta.imagePaths != null) {
      if (planta.imagePaths!.length > 10) {
        errors.add('Máximo de 10 imagens permitidas por planta');
      }

      for (String path in planta.imagePaths!) {
        if (path.trim().isEmpty) {
          errors.add('Caminho de imagem não pode estar vazio');
        }
        if (path.length > 500) {
          errors.add('Caminho de imagem muito longo');
        }
      }
    }

    // TODO: Adicionar validações específicas usando PlantaConfigModel

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Performs a system integrity check (simplified version)
  /// TODO: Reimplementar com novo sistema de tarefas
  Future<SystemIntegrityReport> performSystemIntegrityCheck() async {
    await initialize();

    final plantas = await _plantaRepository.findAll();
    final corruptedPlantas = <PlantIntegrityIssue>[];
    final duplicateNames = <DuplicateNameIssue>[];

    // Check for corrupted plants
    for (final planta in plantas) {
      final validation = validatePlantData(planta);
      if (!validation.isValid) {
        corruptedPlantas.add(PlantIntegrityIssue(
          plantaId: planta.id,
          issues: validation.errors,
        ));
      }
    }

    // Check for duplicate names
    final nameGroups = <String, List<String>>{};
    for (final planta in plantas) {
      final nome = planta.nome?.trim().toLowerCase() ?? '';
      if (nome.isNotEmpty) {
        nameGroups[nome] ??= [];
        nameGroups[nome]!.add(planta.id);
      }
    }

    for (final entry in nameGroups.entries) {
      if (entry.value.length > 1) {
        duplicateNames.add(DuplicateNameIssue(
          nome: entry.key,
          plantas: entry.value,
        ));
      }
    }

    return SystemIntegrityReport(
      isHealthy: corruptedPlantas.isEmpty && duplicateNames.isEmpty,
      corruptedPlantas: corruptedPlantas,
      duplicateNames: duplicateNames,
      checkedAt: DateTime.now(),
    );
  }

  /// TODO: Reimplementar métodos específicos usando novo sistema
  // Métodos removidos temporariamente que usavam campos obsoletos:
  // - validateWateringConsistency
  // - validateFertilizingConsistency
  // - validateCareScheduleConsistency
  // - findInconsistentPlants
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}

/// System integrity report
class SystemIntegrityReport {
  final bool isHealthy;
  final List<PlantIntegrityIssue> corruptedPlantas;
  final List<DuplicateNameIssue> duplicateNames;
  final DateTime checkedAt;

  SystemIntegrityReport({
    required this.isHealthy,
    required this.corruptedPlantas,
    required this.duplicateNames,
    required this.checkedAt,
  });
}

/// Plant integrity issue
class PlantIntegrityIssue {
  final String plantaId;
  final List<String> issues;

  PlantIntegrityIssue({
    required this.plantaId,
    required this.issues,
  });
}

/// Duplicate name issue
class DuplicateNameIssue {
  final String nome;
  final List<String> plantas;

  DuplicateNameIssue({
    required this.nome,
    required this.plantas,
  });
}
