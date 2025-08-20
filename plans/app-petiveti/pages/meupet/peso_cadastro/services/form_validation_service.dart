class FormValidationService {
  static String? validatePeso(double? value) {
    if (value == null || value <= 0) {
      return 'O peso deve ser maior que zero';
    }
    if (value > 500) {
      return 'O peso deve ser menor que 500kg';
    }
    return null;
  }

  static String? validateAnimalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecione um animal';
    }
    return null;
  }

  static String? validateObservacoes(String? value) {
    if (value != null && value.length > 500) {
      return 'Observações não podem exceder 500 caracteres';
    }
    return null;
  }

  static bool isFormValid({
    required String animalId,
    required double peso,
    String? observacoes,
  }) {
    return validateAnimalId(animalId) == null &&
           validatePeso(peso) == null &&
           validateObservacoes(observacoes) == null;
  }

  static Map<String, String?> validateAllFields({
    required String animalId,
    required double peso,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'peso': validatePeso(peso),
      'observacoes': validateObservacoes(observacoes),
    };
  }
}