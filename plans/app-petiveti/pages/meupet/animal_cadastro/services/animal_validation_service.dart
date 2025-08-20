// Project imports:
import '../constants/animal_form_constants.dart';

class AnimalValidationService {
  // Private constructor to prevent instantiation
  AnimalValidationService._();

  // Species and sex options
  static const List<String> especiesOptions = [
    'Cachorro',
    'Gato',
    'Ave',
    'Peixe',
    'Coelho',
    'Hamster',
    'Réptil',
    'Porquinho da Índia',
    'Furão',
    'Outro'
  ];

  static const List<String> sexoOptions = [
    'Macho',
    'Fêmea',
  ];

  // Main validation method for all fields
  static Map<String, String?> validateAllFields({
    required String nome,
    required String especie,
    required String raca,
    required DateTime? dataNascimento,
    required String sexo,
    required String cor,
    required double? pesoAtual,
    String? observacoes,
  }) {
    final errors = <String, String?>{};

    // Validate each field
    final nomeError = validateNome(nome);
    if (nomeError != null) errors['nome'] = nomeError;

    final especieError = validateEspecie(especie);
    if (especieError != null) errors['especie'] = especieError;

    final racaError = validateRaca(raca);
    if (racaError != null) errors['raca'] = racaError;

    final dataError = validateDataNascimento(dataNascimento);
    if (dataError != null) errors['dataNascimento'] = dataError;

    final sexoError = validateSexo(sexo);
    if (sexoError != null) errors['sexo'] = sexoError;

    final corError = validateCor(cor);
    if (corError != null) errors['cor'] = corError;

    final pesoError = validatePesoAtual(pesoAtual, especie);
    if (pesoError != null) errors['pesoAtual'] = pesoError;

    final obsError = validateObservacoes(observacoes);
    if (obsError != null) errors['observacoes'] = obsError;

    return errors;
  }

  // Individual field validation methods
  static String? validateNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    final cleanName = nome.trim();

    if (cleanName.length < AnimalFormConstants.minNomeLength) {
      return AnimalFormConstants.msgNomeMuitoCurto;
    }

    if (cleanName.length > AnimalFormConstants.maxNomeLength) {
      return AnimalFormConstants.msgNomeMuitoLongo;
    }

    // Check for excessive spaces
    if (cleanName.contains('  ')) {
      return 'Nome não pode conter espaços duplos';
    }

    return null;
  }

  static String? validateEspecie(String? especie) {
    if (especie == null || especie.trim().isEmpty) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    if (!especiesOptions.contains(especie)) {
      return 'Selecione uma espécie válida';
    }

    return null;
  }

  static String? validateRaca(String? raca) {
    if (raca == null || raca.trim().isEmpty) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    final cleanRaca = raca.trim();

    if (cleanRaca.length > AnimalFormConstants.maxRacaLength) {
      return AnimalFormConstants.msgRacaMuitoLonga;
    }

    // Basic validation for breed names - allow most characters
    // More permissive validation for breed names

    return null;
  }

  static String? validateDataNascimento(DateTime? dataNascimento) {
    if (dataNascimento == null) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    final now = DateTime.now();
    final minDate = DateTime(AnimalFormConstants.minAnoNascimento);
    final maxDate =
        now.add(const Duration(days: 1)); // Allow today, but not future

    if (dataNascimento.isBefore(minDate)) {
      return 'Data de nascimento não pode ser anterior a ${AnimalFormConstants.minAnoNascimento}';
    }

    if (dataNascimento.isAfter(maxDate)) {
      return 'Data de nascimento não pode ser no futuro';
    }

    return null;
  }

  static String? validateSexo(String? sexo) {
    if (sexo == null || sexo.trim().isEmpty) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    if (!sexoOptions.contains(sexo)) {
      return 'Selecione um sexo válido';
    }

    return null;
  }

  static String? validateCor(String? cor) {
    if (cor == null || cor.trim().isEmpty) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    final cleanCor = cor.trim();

    if (cleanCor.length > 50) {
      // Reasonable limit for color description
      return 'Cor deve ter no máximo 50 caracteres';
    }

    // Basic validation for colors - allow most characters
    // More permissive validation for color descriptions

    return null;
  }

  static String? validatePesoAtual(double? pesoAtual, String? especie) {
    if (pesoAtual == null) {
      return AnimalFormConstants.msgCampoObrigatorio;
    }

    if (pesoAtual <= 0) {
      return AnimalFormConstants.msgPesoMenorQueZero;
    }

    if (pesoAtual < AnimalFormConstants.minPesoKg) {
      return 'Peso mínimo é ${AnimalFormConstants.minPesoKg}kg';
    }

    if (pesoAtual > AnimalFormConstants.maxPesoKg) {
      return 'Peso máximo é ${AnimalFormConstants.maxPesoKg}kg';
    }

    // Species-specific weight validation
    if (especie != null &&
        AnimalFormConstants.pesoLimitesPorEspecie.containsKey(especie)) {
      final limits = AnimalFormConstants.pesoLimitesPorEspecie[especie]!;
      if (pesoAtual < limits.min) {
        return 'Peso muito baixo para ${especie.toLowerCase()} (mín. ${limits.min}kg)';
      }
      if (pesoAtual > limits.max) {
        return 'Peso muito alto para ${especie.toLowerCase()} (máx. ${limits.max}kg)';
      }
    }

    return null;
  }

  static String? validateObservacoes(String? observacoes) {
    if (observacoes == null || observacoes.trim().isEmpty) {
      return null; // Observations are optional
    }

    final cleanObs = observacoes.trim();

    if (cleanObs.length > AnimalFormConstants.maxObservacoesLength) {
      return 'Observações devem ter no máximo ${AnimalFormConstants.maxObservacoesLength} caracteres';
    }

    return null;
  }

  // Field validation for real-time feedback
  static String? validateField(String fieldName, dynamic value,
      {String? especie}) {
    switch (fieldName) {
      case 'nome':
        return validateNome(value as String?);
      case 'especie':
        return validateEspecie(value as String?);
      case 'raca':
        return validateRaca(value as String?);
      case 'dataNascimento':
        return validateDataNascimento(value as DateTime?);
      case 'sexo':
        return validateSexo(value as String?);
      case 'cor':
        return validateCor(value as String?);
      case 'pesoAtual':
        return validatePesoAtual(value as double?, especie);
      case 'observacoes':
        return validateObservacoes(value as String?);
      default:
        return null;
    }
  }

  // Data sanitization methods
  static String sanitizeText(String? text) {
    if (text == null) return '';

    // Remove extra spaces and trim
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeNome(String? nome) {
    if (nome == null) return '';

    // Capitalize first letter of each word
    final sanitized = sanitizeText(nome);
    return sanitized
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  static String sanitizeRaca(String? raca) {
    if (raca == null) return '';

    // Capitalize first letter of each word, preserve some breed naming conventions
    final sanitized = sanitizeText(raca);
    return sanitized
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  static String sanitizeCor(String? cor) {
    if (cor == null) return '';

    // Lowercase for colors
    return sanitizeText(cor).toLowerCase();
  }

  static double? parseWeight(String? weightText) {
    if (weightText == null || weightText.trim().isEmpty) return null;

    // Remove common weight units and extra characters
    String cleanText = weightText
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[kg|kilo|quilos?|gramas?|g]'), '')
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');

    if (cleanText.isEmpty) return null;

    try {
      return double.parse(cleanText);
    } catch (e) {
      return null;
    }
  }

  // Business rules validation
  static List<String> validateBusinessRules({
    required String nome,
    required String especie,
    required String raca,
    required DateTime? dataNascimento,
    required String sexo,
    required String cor,
    required double? pesoAtual,
    String? observacoes,
  }) {
    final warnings = <String>[];

    // Age-related warnings
    if (dataNascimento != null) {
      final age = DateTime.now().difference(dataNascimento).inDays / 365;

      if (age < 0.1) {
        // Less than ~1 month old
        warnings.add('Animal muito jovem - confirme a data de nascimento');
      }

      if (age > 20) {
        // Very old animal
        warnings
            .add('Animal com idade avançada - confirme a data de nascimento');
      }
    }

    // Weight-related warnings
    if (pesoAtual != null && especie.isNotEmpty) {
      if (AnimalFormConstants.pesoLimitesPorEspecie.containsKey(especie)) {
        final limits = AnimalFormConstants.pesoLimitesPorEspecie[especie]!;

        if (pesoAtual < limits.min * 1.5) {
          warnings.add(
              'Peso baixo para a espécie - considere consulta veterinária');
        }

        if (pesoAtual > limits.max * 0.8) {
          warnings.add('Peso alto para a espécie - considere dieta controlada');
        }
      }
    }

    // Breed-species consistency
    if (especie.isNotEmpty && raca.isNotEmpty) {
      if (!_isBreedConsistentWithSpecies(especie, raca)) {
        warnings.add('Raça pode não ser compatível com a espécie selecionada');
      }
    }

    return warnings;
  }

  // Helper methods
  static bool _isBreedConsistentWithSpecies(String especie, String raca) {
    final racaLower = raca.toLowerCase();

    switch (especie.toLowerCase()) {
      case 'gato':
        return racaLower.contains('gato') ||
            racaLower.contains('cat') ||
            racaLower.contains('siamês') ||
            racaLower.contains('persa') ||
            racaLower.contains('maine') ||
            racaLower.contains('british') ||
            racaLower.contains('srd') ||
            racaLower.contains('sem raça');

      case 'cachorro':
      case 'cão':
        return racaLower.contains('dog') ||
            racaLower.contains('labrador') ||
            racaLower.contains('golden') ||
            racaLower.contains('pastor') ||
            racaLower.contains('poodle') ||
            racaLower.contains('bulldog') ||
            racaLower.contains('pit') ||
            racaLower.contains('srd') ||
            racaLower.contains('sem raça') ||
            racaLower.contains('vira') ||
            racaLower.contains('mix');

      default:
        return true; // Assume consistency for other species
    }
  }

  // Get validation summary
  static Map<String, dynamic> getValidationSummary({
    required String nome,
    required String especie,
    required String raca,
    required DateTime? dataNascimento,
    required String sexo,
    required String cor,
    required double? pesoAtual,
    String? observacoes,
  }) {
    final errors = validateAllFields(
      nome: nome,
      especie: especie,
      raca: raca,
      dataNascimento: dataNascimento,
      sexo: sexo,
      cor: cor,
      pesoAtual: pesoAtual,
      observacoes: observacoes,
    );

    final warnings = validateBusinessRules(
      nome: nome,
      especie: especie,
      raca: raca,
      dataNascimento: dataNascimento,
      sexo: sexo,
      cor: cor,
      pesoAtual: pesoAtual,
      observacoes: observacoes,
    );

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'errorCount': errors.length,
      'warningCount': warnings.length,
    };
  }
}
