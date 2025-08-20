class ConsultaValidators {
  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Animal é obrigatório';
    }
    return null;
  }

  static String? validateVeterinario(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veterinário é obrigatório';
    }
    if (value.length > 100) {
      return 'Nome do veterinário deve ter no máximo 100 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\.]+$').hasMatch(value)) {
      return 'Nome do veterinário contém caracteres inválidos';
    }
    return null;
  }

  static String? validateMotivo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Motivo é obrigatório';
    }
    if (value.length > 255) {
      return 'Motivo deve ter no máximo 255 caracteres';
    }
    return null;
  }

  static String? validateDiagnostico(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Diagnóstico é obrigatório';
    }
    if (value.length > 500) {
      return 'Diagnóstico deve ter no máximo 500 caracteres';
    }
    return null;
  }

  static String? validateObservacoes(String? value) {
    if (value != null && value.length > 1000) {
      return 'Observações devem ter no máximo 1000 caracteres';
    }
    return null;
  }

  static String? validateDataConsulta(DateTime? value) {
    if (value == null) {
      return 'Data da consulta é obrigatória';
    }

    final now = DateTime.now();
    final twoYearsAgo = now.subtract(const Duration(days: 730));
    final oneYearFromNow = now.add(const Duration(days: 365));

    if (value.isBefore(twoYearsAgo)) {
      return 'Data não pode ser anterior a 2 anos';
    }
    if (value.isAfter(oneYearFromNow)) {
      return 'Data não pode ser posterior a 1 ano';
    }

    return null;
  }

  static bool isValidDate(DateTime date) {
    return validateDataConsulta(date) == null;
  }

  static bool isValidVeterinario(String veterinario) {
    return validateVeterinario(veterinario) == null;
  }

  static bool isValidMotivo(String motivo) {
    return validateMotivo(motivo) == null;
  }

  static bool isValidDiagnostico(String diagnostico) {
    return validateDiagnostico(diagnostico) == null;
  }

  static bool isValidObservacoes(String? observacoes) {
    return validateObservacoes(observacoes) == null;
  }

  static String sanitizeInput(String? input) {
    if (input == null) return '';
    return input.trim();
  }

  static bool isFormValid({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
    String? observacoes,
  }) {
    return validateAnimalId(animalId) == null &&
           validateVeterinario(veterinario) == null &&
           validateMotivo(motivo) == null &&
           validateDiagnostico(diagnostico) == null &&
           validateDataConsulta(dataConsulta) == null &&
           validateObservacoes(observacoes) == null;
  }

  static Map<String, String?> validateAllFields({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'veterinario': validateVeterinario(veterinario),
      'motivo': validateMotivo(motivo),
      'diagnostico': validateDiagnostico(diagnostico),
      'dataConsulta': validateDataConsulta(dataConsulta),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  static String getValidationMessage(String field, String? error) {
    if (error == null) return '';

    final fieldNames = {
      'animalId': 'Animal',
      'veterinario': 'Veterinário',
      'motivo': 'Motivo',
      'diagnostico': 'Diagnóstico',
      'observacoes': 'Observações',
      'dataConsulta': 'Data da consulta',
    };

    final fieldName = fieldNames[field] ?? field;
    return '$fieldName: $error';
  }

  static Map<String, String> validateConsultationData({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
    String? observacoes,
  }) {
    final errors = <String, String>{};
    
    final validation = validateAllFields(
      animalId: animalId,
      veterinario: veterinario,
      motivo: motivo,
      diagnostico: diagnostico,
      dataConsulta: dataConsulta,
      observacoes: observacoes,
    );

    validation.forEach((field, error) {
      if (error != null) {
        errors[field] = getValidationMessage(field, error);
      }
    });

    return errors;
  }
}