class MacronutrientesValidationService {
  // Valida se um valor está dentro de uma faixa específica
  static bool validarFaixa(double valor, double min, double max) {
    return valor >= min && valor <= max;
  }

  // Função auxiliar para parsing seguro de double com validação de range
  static double parseDoubleWithValidation(
    String value,
    double min,
    double max,
    String errorMessage,
  ) {
    try {
      double parsedValue = double.parse(value.trim());
      if (parsedValue < min || parsedValue > max) {
        throw RangeError(errorMessage);
      }
      return parsedValue;
    } on FormatException catch (_) {
      throw const FormatException('Valor deve ser um número válido');
    }
  }

  // Função auxiliar para parsing seguro de int com validação de range
  static int parseIntWithValidation(
    String value,
    int min,
    int max,
    String errorMessage,
  ) {
    try {
      int parsedValue = int.parse(value.trim());
      if (parsedValue < min || parsedValue > max) {
        throw RangeError(errorMessage);
      }
      return parsedValue;
    } on FormatException catch (_) {
      throw const FormatException('Valor deve ser um número inteiro válido');
    }
  }
}
