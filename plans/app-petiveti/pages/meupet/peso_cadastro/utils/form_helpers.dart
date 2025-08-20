// Project imports:
import '../../../../utils/peso/peso_core.dart';
import '../../../../utils/peso/peso_validators.dart';

/// Form-specific helpers for peso registration
class FormHelpers {
  
  /// Gets field hint text based on animal type
  static String getHintForAnimalType(String? animalType) {
    switch (animalType) {
      case 'Cachorro':
        return 'Ex: 5.5 kg';
      case 'Gato':
        return 'Ex: 3.2 kg';
      default:
        return 'Ex: 4.5 kg';
    }
  }
  
  /// Gets field label text
  static String getFieldLabel(String field) {
    switch (field) {
      case 'peso':
        return 'Peso';
      case 'data':
        return 'Data da Pesagem';
      case 'observacoes':
        return 'Observações';
      default:
        return field;
    }
  }
  
  /// Gets field hint text
  static String getFieldHint(String field) {
    switch (field) {
      case 'peso':
        return 'Digite o peso do animal';
      case 'data':
        return 'Selecione a data da pesagem';
      case 'observacoes':
        return 'Informações adicionais sobre a pesagem';
      default:
        return '';
    }
  }
  
  /// Gets character count text
  static String getCharacterCount(String text, int maxLength) {
    return '${text.length}/$maxLength';
  }
  
  /// Formats peso input for display in form
  static String formatPesoInput(String input) {
    final cleaned = PesoCore.cleanPesoInput(input);
    final peso = PesoCore.parsePeso(cleaned);
    
    if (peso == null) return cleaned;
    
    return PesoCore.formatPeso(peso);
  }
  
  /// Gets peso suggestions based on animal type
  static List<String> getPesoSuggestions(String? animalType, double? currentPeso) {
    final suggestions = PesoCore.generatePesoSuggestions(currentPeso);
    
    // Filter suggestions based on animal type
    final filteredSuggestions = suggestions.where((peso) {
      switch (animalType) {
        case 'Cachorro':
          return peso >= 0.5 && peso <= 100;
        case 'Gato':
          return peso >= 0.2 && peso <= 20;
        default:
          return peso >= 0.1 && peso <= 500;
      }
    }).toList();
    
    return filteredSuggestions.map((peso) => PesoCore.formatPeso(peso)).toList();
  }
  
  /// Validates form specific to cadastro context
  static Map<String, String?> validateForm({
    required String? peso,
    required DateTime? data,
    required String? animalType,
    String? observacoes,
  }) {
    final errors = <String, String?>{};
    
    // Validate peso
    String? pesoError;
    switch (animalType) {
      case 'Cachorro':
        pesoError = PesoValidators.validateDogPeso(peso);
        break;
      case 'Gato':
        pesoError = PesoValidators.validateCatPeso(peso);
        break;
      default:
        pesoError = PesoValidators.validatePeso(peso);
    }
    errors['peso'] = pesoError;
    
    // Validate data
    errors['data'] = PesoValidators.validateDate(data);
    
    // Validate animal type
    errors['animalType'] = PesoValidators.validateAnimalType(animalType);
    
    // Validate observacoes
    errors['observacoes'] = PesoValidators.validateObservations(observacoes);
    
    return errors;
  }
  
  /// Calculates form completion percentage
  static double calculateFormProgress({
    required String? peso,
    required DateTime? data,
    required String? animalType,
    String? observacoes,
  }) {
    int completed = 0;
    int total = 3; // peso, data, animalType are required
    
    if (peso != null && peso.trim().isNotEmpty) completed++;
    if (data != null) completed++;
    if (animalType != null && animalType.trim().isNotEmpty) completed++;
    
    return completed / total;
  }
  
  /// Gets form progress text
  static String getFormProgressText(double progress) {
    final percentage = (progress * 100).round();
    
    if (percentage == 100) {
      return 'Formulário completo';
    } else if (percentage >= 75) {
      return 'Quase pronto ($percentage%)';
    } else if (percentage >= 50) {
      return 'Metade completa ($percentage%)';
    } else {
      return 'Iniciado ($percentage%)';
    }
  }
  
  /// Gets contextual help text for peso input
  static String getContextualHelpText(String? animalType) {
    switch (animalType) {
      case 'Cachorro':
        return 'Para cães, o peso varia muito conforme a raça e idade. Filhotes ganham peso rapidamente.';
      case 'Gato':
        return 'Gatos adultos geralmente pesam entre 2.5kg e 5.5kg. Monitore mudanças bruscas.';
      default:
        return 'Registre o peso atual do animal para acompanhar sua evolução.';
    }
  }
  
  /// Formats peso for form display
  static String formatPesoForForm(double peso) {
    return PesoCore.formatPesoWithUnit(peso);
  }
}
