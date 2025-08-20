/// Classe de utilidades para os cálculos de dosagem de medicamentos
class DosagemMedicamentosUtils {
  /// Valida um campo numérico
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value) == null) {
      return 'Digite um número válido';
    }
    if (double.parse(value) <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  /// Valida o campo de dosagem que pode ser um número ou um intervalo
  static String? validateDosagem(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    // Verificar se é um número simples
    if (double.tryParse(value) != null) {
      return null;
    }
    // Verificar se é um intervalo (formato: "min - max")
    if (value.contains('-')) {
      final partes = value.split('-');
      if (partes.length == 2 &&
          double.tryParse(partes[0].trim()) != null &&
          double.tryParse(partes[1].trim()) != null) {
        return null;
      }
    }
    return 'Formato inválido. Use um número ou um intervalo (ex: 10 - 20)';
  }
}
