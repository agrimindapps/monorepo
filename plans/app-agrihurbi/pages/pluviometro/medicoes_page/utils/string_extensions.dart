/// Extensions consolidadas para String para evitar duplicação
extension StringExtensions on String {
  /// Capitaliza a primeira letra da string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Verifica se a string é um ID válido (não vazio e com tamanho mínimo)
  bool get isValidId {
    return isNotEmpty && length >= 3;
  }

  /// Remove acentos da string
  String removeAccents() {
    const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutAccents =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeClIIIIiiiiUUUUuuuuyNn';

    String result = this;
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }

  /// Trunca string com ellipsis se exceder o limite
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Verifica se a string contém apenas números
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Converte string para double de forma segura
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Converte string para int de forma segura
  int? toIntOrNull() {
    return int.tryParse(this);
  }
}
