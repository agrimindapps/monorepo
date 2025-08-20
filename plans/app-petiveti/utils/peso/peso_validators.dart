// Project imports:
import 'peso_core.dart';

/// Peso validation utilities shared across browse and cadastro contexts
class PesoValidators {
  
  /// Validate peso value
  static String? validatePesoValue(double? peso) {
    if (peso == null || peso <= 0) {
      return 'O peso deve ser maior que zero';
    }
    if (peso > 500) {
      return 'O peso deve ser menor que 500kg';
    }
    return null;
  }

  /// Basic peso validation from string
  static String? validatePeso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Peso é obrigatório';
    }
    
    final peso = PesoCore.parsePeso(value);
    
    if (peso == null) {
      return 'Peso deve ser um número válido';
    }
    
    if (peso <= 0) {
      return 'Peso deve ser maior que zero';
    }
    
    if (peso > 500) {
      return 'Peso muito alto, verifique se está correto';
    }
    
    if (peso < 0.01) {
      return 'Peso muito baixo, verifique se está correto';
    }
    
    return null;
  }

  /// Validates peso specifically for dogs
  static String? validateDogPeso(String? value) {
    final baseError = validatePeso(value);
    if (baseError != null) return baseError;
    
    final peso = PesoCore.parsePeso(value)!;
    
    if (peso > 100) {
      return 'Peso muito alto para um cão';
    }
    
    if (peso < 0.5) {
      return 'Peso muito baixo para um cão';
    }
    
    return null;
  }

  /// Validates peso specifically for cats
  static String? validateCatPeso(String? value) {
    final baseError = validatePeso(value);
    if (baseError != null) return baseError;
    
    final peso = PesoCore.parsePeso(value)!;
    
    if (peso > 20) {
      return 'Peso muito alto para um gato';
    }
    
    if (peso < 0.2) {
      return 'Peso muito baixo para um gato';
    }
    
    return null;
  }

  /// Validates peso change for alerts
  static String? validatePesoChange(double currentPeso, double? previousPeso) {
    if (previousPeso == null) return null;
    
    final difference = currentPeso - previousPeso;
    final percentageChange = (difference / previousPeso) * 100;
    
    if (percentageChange.abs() > 50) {
      return 'Mudança de peso muito drástica (${percentageChange.toStringAsFixed(1)}%)';
    }
    
    return null;
  }

  /// Validates if peso is within expected range for animal age
  static String? validatePesoForAge(double peso, DateTime birthDate, String animalType) {
    final age = DateTime.now().difference(birthDate).inDays;
    
    if (animalType == 'Cachorro') {
      if (age < 30 && peso > 5) { // Puppy less than 1 month
        return 'Peso alto para filhote tão novo';
      }
      
      if (age < 90 && peso > 15) { // Puppy less than 3 months
        return 'Peso alto para filhote';
      }
    } else if (animalType == 'Gato') {
      if (age < 30 && peso > 1) { // Kitten less than 1 month
        return 'Peso alto para filhote tão novo';
      }
      
      if (age < 90 && peso > 2) { // Kitten less than 3 months
        return 'Peso alto para filhote';
      }
    }
    
    return null;
  }

  /// Validates animal type
  static String? validateAnimalType(String? animalType) {
    if (animalType == null || animalType.trim().isEmpty) {
      return 'Tipo de animal é obrigatório';
    }
    
    final validTypes = ['Cachorro', 'Gato', 'Outro'];
    if (!validTypes.contains(animalType)) {
      return 'Tipo de animal inválido';
    }
    
    return null;
  }

  /// Validates date
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Data é obrigatória';
    }
    
    if (date.isAfter(DateTime.now())) {
      return 'Data não pode ser futura';
    }
    
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    if (date.isBefore(oneYearAgo)) {
      return 'Data muito antiga';
    }
    
    return null;
  }

  /// Validates observations
  static String? validateObservations(String? observations) {
    if (observations == null || observations.trim().isEmpty) {
      return null; // Optional field
    }
    
    if (observations.length > 500) {
      return 'Observações muito longas (máximo 500 caracteres)';
    }
    
    // Check for valid characters
    if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\.\,\!\?\-\(\)\[\]\:\/]*$').hasMatch(observations)) {
      return 'Observações contêm caracteres inválidos';
    }
    
    return null;
  }
}
