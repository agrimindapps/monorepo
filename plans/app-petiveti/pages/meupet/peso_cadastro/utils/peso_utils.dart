// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;
import '../../../../../../app-petiveti/utils/peso/peso_core.dart' as peso_core;
import '../../../../../../app-petiveti/utils/peso/peso_validators.dart' as peso_validators;
import '../../../../../../app-petiveti/utils/string_utils.dart';

class PesoUtils {
  // Delegated functions to centralized utils
  static String formatPeso(double peso) => peso_core.PesoCore.formatPeso(peso);
  static String formatPesoWithUnit(double peso) => peso_core.PesoCore.formatPesoWithUnit(peso);
  static double roundPeso(double peso, {int decimalPlaces = 2}) => peso_core.PesoCore.roundPeso(peso, decimalPlaces: decimalPlaces);
  static bool isValidPesoRange(double peso) => peso_core.PesoCore.isValidPesoRange(peso);
  static String? validatePesoValue(double? peso) => peso_validators.PesoValidators.validatePesoValue(peso);
  static double parsePesoFromString(String value) => peso_core.PesoCore.parsePesoFromString(value);
  static String getPesoCategory(double peso) => peso_core.PesoCore.getPesoCategory(peso);
  static List<double> generatePesoSuggestions(double? currentPeso) => peso_core.PesoCore.generatePesoSuggestions(currentPeso);
  static String? validatePeso(String? value) => peso_validators.PesoValidators.validatePeso(value);
  static String? validateDogPeso(String? value) => peso_validators.PesoValidators.validateDogPeso(value);
  static String? validateCatPeso(String? value) => peso_validators.PesoValidators.validateCatPeso(value);
  static String? validatePesoChange(double currentPeso, double? previousPeso) => peso_validators.PesoValidators.validatePesoChange(currentPeso, previousPeso);
  static String? validatePesoForAge(double peso, DateTime birthDate, String animalType) => peso_validators.PesoValidators.validatePesoForAge(peso, birthDate, animalType);
  
  // Date utility functions
  static String formatDate(DateTime date) => app_date_utils.DateUtils.formatDate(date.millisecondsSinceEpoch);
  static String formatDateComplete(DateTime date) => app_date_utils.DateUtils.formatDateComplete(date);
  static DateTime? parseDate(String dateString) => app_date_utils.DateUtils.parseStringToDate(dateString);
  static bool isToday(DateTime date) => app_date_utils.DateUtils.isToday(date);
  static bool isTomorrow(DateTime date) => app_date_utils.DateUtils.isTomorrow(date);
  static bool isYesterday(DateTime date) => app_date_utils.DateUtils.isYesterday(date);
  static String getRelativeTime(DateTime date) => app_date_utils.DateUtils.getRelativeTimeString(date);
  static DateTime normalizeDate(DateTime date) => app_date_utils.DateUtils.normalizeDate(date);

  // String utility functions
  static String capitalize(String text) => StringUtils.capitalize(text);
  static String sanitizeText(String text) => StringUtils.sanitizeText(text);

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
  }) {
    return peso_core.PesoCore.exportToJson(
      animalId: animalId,
      peso: peso,
      dataPesagem: dataPesagem,
      observacoes: observacoes,
    );
  }

  // Form-specific utility functions (keep these)
  static String getCharacterCountText(int current, int max) {
    return '$current/$max';
  }

  static Color getCharacterCountColor(int current, int max) {
    final percentage = current / max;

    if (percentage >= 1.0) {
      return const Color(0xFFE53935); // Red - over limit
    } else if (percentage >= 0.8) {
      return const Color(0xFFFF9800); // Orange - near limit
    } else {
      return const Color(0xFF757575); // Gray - normal
    }
  }

  static bool isCharacterLimitExceeded(int current, int max) {
    return current > max;
  }

  static bool isCharacterLimitNear(int current, int max) {
    return current > (max * 0.8);
  }

  static Map<String, dynamic> getFormStatistics({
    required String animalId,
    required double peso,
    required DateTime? dataPesagem,
    String? observacoes,
  }) {
    return {
      'hasAnimal': animalId.isNotEmpty,
      'hasPeso': peso > 0,
      'hasDataPesagem': dataPesagem != null,
      'hasObservacoes': observacoes != null && observacoes.isNotEmpty,
      'pesoValid': isValidPesoRange(peso),
      'observacoesLength': observacoes?.length ?? 0,
      'completionPercentage': _calculateCompletionPercentage(
        animalId: animalId,
        peso: peso,
        dataPesagem: dataPesagem,
        observacoes: observacoes,
      ),
    };
  }

  static double _calculateCompletionPercentage({
    required String animalId,
    required double peso,
    required DateTime? dataPesagem,
    String? observacoes,
  }) {
    int completed = 0;
    const int total = 3; // Required fields: animal, peso, data

    if (animalId.isNotEmpty) completed++;
    if (peso > 0) completed++;
    if (dataPesagem != null) completed++;

    return (completed / total) * 100;
  }

  static String getFormCompletionText(double percentage) {
    if (percentage == 100) {
      return 'Formulário completo';
    } else if (percentage >= 75) {
      return 'Quase pronto';
    } else if (percentage >= 50) {
      return 'Metade completo';
    } else if (percentage > 0) {
      return 'Iniciado';
    } else {
      return 'Não iniciado';
    }
  }

  static Color getFormCompletionColor(double percentage) {
    if (percentage == 100) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= 75) {
      return const Color(0xFF66BB6A); // Light green
    } else if (percentage >= 50) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFF757575); // Gray
    }
  }

  // Validation functions for forms
  static bool isFormValid({
    required String animalId,
    required double peso,
    required DateTime? dataPesagem,
    String? observacoes,
  }) {
    return animalId.isNotEmpty &&
        isValidPesoRange(peso) &&
        dataPesagem != null &&
        (observacoes == null || observacoes.length <= 500);
  }

  static Map<String, String?> validateForm({
    required String animalId,
    required String? pesoString,
    required DateTime? dataPesagem,
    String? observacoes,
    String? animalType,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    // Validate peso based on animal type
    String? pesoError;
    if (animalType == 'Cachorro') {
      pesoError = validateDogPeso(pesoString);
    } else if (animalType == 'Gato') {
      pesoError = validateCatPeso(pesoString);
    } else {
      pesoError = validatePeso(pesoString);
    }

    if (pesoError != null) {
      errors['peso'] = pesoError;
    }

    if (dataPesagem == null) {
      errors['dataPesagem'] = 'Data é obrigatória';
    } else if (dataPesagem.isAfter(DateTime.now())) {
      errors['dataPesagem'] = 'A data não pode ser no futuro';
    }

    if (observacoes != null && observacoes.length > 500) {
      errors['observacoes'] = 'Observações devem ter no máximo 500 caracteres';
    }

    return errors;
  }

  // Input formatting helpers
  static String formatPesoInput(String input) {
    // Remove any non-numeric characters except comma and dot
    final cleaned = input.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Handle comma as decimal separator
    if (cleaned.contains(',')) {
      final parts = cleaned.split(',');
      if (parts.length == 2) {
        return '${parts[0]}.${parts[1]}';
      }
    }
    
    return cleaned;
  }

  static String maskPesoInput(String value) {
    if (value.isEmpty) return value;
    
    // Remove all non-numeric characters
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.isEmpty) return '';
    
    // Add decimal point before last digit if more than 1 digit
    if (numbers.length > 1) {
      final integerPart = numbers.substring(0, numbers.length - 1);
      final decimalPart = numbers.substring(numbers.length - 1);
      return '$integerPart.$decimalPart';
    } else {
      return '0.$numbers';
    }
  }

  // Date/Time specific utilities
  static String formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTimeForDisplay(DateTime dateTime) {
    return '${formatDate(dateTime)} às ${formatTimeOnly(dateTime)}';
  }

  static DateTime? combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static TimeOfDay getTimeFromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static DateTime getDateFromDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Peso suggestions based on context
  static List<double> getContextualPesoSuggestions({
    required String animalType,
    String? breed,
    DateTime? birthDate,
    double? lastPeso,
  }) {
    final baseSuggestions = generatePesoSuggestions(lastPeso);
    
    // Filter suggestions based on animal type and age
    if (birthDate != null) {
      final ageInDays = DateTime.now().difference(birthDate).inDays;
      
      if (animalType == 'Gato') {
        if (ageInDays < 30) {
          // Kitten - very light weights
          return baseSuggestions.where((peso) => peso <= 1.0).toList();
        } else if (ageInDays < 365) {
          // Young cat
          return baseSuggestions.where((peso) => peso <= 5.0).toList();
        } else {
          // Adult cat
          return baseSuggestions.where((peso) => peso >= 2.0 && peso <= 10.0).toList();
        }
      } else if (animalType == 'Cachorro') {
        if (ageInDays < 30) {
          // Puppy - very light weights
          return baseSuggestions.where((peso) => peso <= 2.0).toList();
        } else if (ageInDays < 365) {
          // Young dog - variable based on breed
          final maxWeight = _getMaxPuppyWeight(breed);
          return baseSuggestions.where((peso) => peso <= maxWeight).toList();
        }
      }
    }
    
    return baseSuggestions;
  }

  static double _getMaxPuppyWeight(String? breed) {
    switch (breed?.toLowerCase()) {
      case 'chihuahua':
      case 'yorkshire':
        return 2.0;
      case 'maltês':
      case 'poodle toy':
        return 3.0;
      case 'beagle':
      case 'cocker spaniel':
        return 15.0;
      case 'golden retriever':
      case 'labrador':
        return 30.0;
      case 'pastor alemão':
      case 'rottweiler':
        return 40.0;
      default:
        return 20.0; // Default for unknown breeds
    }
  }

  // Peso tracking helpers
  static Map<String, dynamic> getPesoProgress({
    required double currentPeso,
    required double? targetPeso,
    required double? previousPeso,
  }) {
    if (targetPeso == null) {
      return {
        'hasTarget': false,
        'progress': 0.0,
        'remaining': 0.0,
        'changeFromPrevious': previousPeso != null ? currentPeso - previousPeso : 0.0,
      };
    }

    final progress = previousPeso != null 
        ? ((currentPeso - previousPeso) / (targetPeso - previousPeso)) * 100
        : 0.0;
    
    final remaining = targetPeso - currentPeso;
    final changeFromPrevious = previousPeso != null ? currentPeso - previousPeso : 0.0;

    return {
      'hasTarget': true,
      'progress': progress.clamp(0.0, 100.0),
      'remaining': remaining,
      'changeFromPrevious': changeFromPrevious,
      'isIncreasing': targetPeso > (previousPeso ?? currentPeso),
      'onTrack': (remaining.abs() <= 0.5), // Within 0.5kg of target
    };
  }
}
