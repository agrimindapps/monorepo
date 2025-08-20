// Project imports:
import '../../../../utils/vacina_utils.dart';

/// Form-specific UI helpers for vaccination registration
class FormHelpers {
  
  /// Gets field hint text for vaccine name
  static String getVaccineNameHint(String? animalType) {
    final suggestions = VacinaUtils.getVaccineSuggestions(animalType);
    if (suggestions.isNotEmpty) {
      return 'Ex: ${suggestions.first}';
    }
    return 'Nome da vacina';
  }
  
  /// Gets field hint text for observations
  static String getObservationsHint() {
    return 'Reações, lote, veterinário, etc.';
  }
  
  /// Gets formatted title for vaccine registration
  static String getFormTitle(String? animalName) {
    if (animalName != null && animalName.isNotEmpty) {
      return 'Vacina para $animalName';
    }
    return 'Cadastro de Vacina';
  }
  
  /// Gets character count display
  static String getCharacterCount(String text, int maxLength) {
    return '${text.length}/$maxLength';
  }
  
  /// Gets vaccine suggestions for autocomplete
  static List<String> getVaccineSuggestions(String? animalType) {
    return VacinaUtils.getVaccineSuggestions(animalType);
  }
  
  /// Formats date for display in form
  static String formatDateForForm(int timestamp) {
    return VacinaUtils.timestampToDateString(timestamp);
  }
  
  /// Formats time for display in form
  static String formatTimeForForm(int timestamp) {
    return VacinaUtils.timestampToTimeString(timestamp);
  }
  
  /// Gets field label text
  static String getFieldLabel(String field) {
    switch (field) {
      case 'observacoes':
        return 'Observações';
      case 'nomeVacina':
        return 'Nome da Vacina';
      default:
        return field;
    }
  }
  
  /// Gets field hint text
  static String getFieldHint(String field) {
    switch (field) {
      case 'observacoes':
        return getObservationsHint();
      case 'nomeVacina':
        return 'Ex: V8, V10, Raiva, Múltipla';
      default:
        return '';
    }
  }
  
  /// Cleans observation text
  static String cleanObservations(String value) {
    // Remove excess whitespace and normalize
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Validates if text has valid characters
  static bool hasValidCharacters(String value) {
    // Allow alphanumeric, spaces, and common punctuation
    return RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\.\,\!\?\-\(\)\[\]\:\/]*$').hasMatch(value);
  }
  
  /// Gets character count text
  static String getCharacterCountText(String text, String field) {
    return '${text.length}';
  }
  
  /// Formats vaccine name
  static String formatVaccineName(String value) {
    // Remove excess whitespace and normalize
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
