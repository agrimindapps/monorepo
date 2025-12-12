/// Helper para conversão segura de campos de modelos dinâmicos
///
/// Reduz complexidade ciclomática e código duplicado em factory methods
class PlantFieldConverter {
  /// Extrai string não-vazia ou retorna null
  static String? extractOptionalString(dynamic value, {String? defaultValue}) {
    try {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extrai string obrigatória ou retorna valor padrão
  static String extractRequiredString(
    dynamic value, {
    required String defaultValue,
  }) {
    try {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extrai DateTime ou retorna null
  static DateTime? extractOptionalDateTime(dynamic value) {
    try {
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extrai bool ou retorna valor padrão
  static bool extractBool(dynamic value, {bool defaultValue = false}) {
    try {
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        return normalized == 'true' || normalized == '1';
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extrai int positivo ou retorna valor padrão
  static int extractPositiveInt(dynamic value, {int defaultValue = 1}) {
    try {
      if (value is int && value > 0) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) return parsed;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extrai lista de strings não-vazias
  static List<String> extractStringList(dynamic value) {
    try {
      if (value is List) {
        return value
            .where((item) => item != null && item.toString().trim().isNotEmpty)
            .map((item) => item.toString().trim())
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Valida ID (não pode ser null ou vazio)
  static String validateId(dynamic value) {
    if (value == null) {
      throw ArgumentError('ID cannot be null');
    }

    final id = value.toString().trim();
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }

    return id;
  }

  /// Gera ID de fallback baseado em timestamp
  static String generateFallbackId([dynamic originalValue]) {
    try {
      if (originalValue != null) {
        final attempt = originalValue.toString().trim();
        if (attempt.isNotEmpty) return attempt;
      }
    } catch (_) {}

    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
