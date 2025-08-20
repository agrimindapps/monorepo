// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../services/vacina_validation_rules.dart';

/// Mixin for form validation logic - now delegates to VacinaValidationRules
mixin ValidationMixin<T extends StatefulWidget> on State<T> {
  /// Validates all form fields and returns a map of field errors
  Map<String, String?> validateAllFields({
    required String? animalId,
    required String? nomeVacina,
    required int? dataAplicacao,
    required int? proximaDose,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'nomeVacina': validateVaccineName(nomeVacina),
      'dataAplicacao': validateApplicationDateTimestamp(dataAplicacao),
      'proximaDose': validateNextDoseDateTimestamp(proximaDose, dataAplicacao),
      'observacoes': validateObservations(observacoes),
    };
  }

  /// Validates vaccine name specifically
  String? validateVaccineName(String? name) {
    return VacinaValidationRules.validateVaccineName(name);
  }

  /// Validates observations specifically
  String? validateObservations(String? observations) {
    return VacinaValidationRules.validateObservations(observations);
  }

  /// Validates application date
  String? validateApplicationDate(DateTime? date) {
    return VacinaValidationRules.validateApplicationDate(date);
  }

  /// Validates next dose date
  String? validateNextDoseDate(DateTime? nextDate, DateTime? applicationDate) {
    return VacinaValidationRules.validateNextDoseDate(
        nextDate, applicationDate);
  }

  /// Validates animal ID
  String? validateAnimalId(String? animalId) {
    return VacinaValidationRules.validateAnimalId(animalId);
  }

  /// Validates application date (timestamp version)
  String? validateApplicationDateTimestamp(int? timestamp) {
    if (timestamp == null) {
      return VacinaValidationRules.validateApplicationDate(null);
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return VacinaValidationRules.validateApplicationDate(date);
  }

  /// Validates next dose date (timestamp version)
  String? validateNextDoseDateTimestamp(int? nextTimestamp, int? appTimestamp) {
    final nextDate = nextTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(nextTimestamp)
        : null;
    final appDate = appTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(appTimestamp)
        : null;
    return VacinaValidationRules.validateNextDoseDate(nextDate, appDate);
  }

  /// Validates date interval between application and next dose
  bool isValidDateInterval(DateTime applicationDate, DateTime nextDoseDate) {
    final difference = nextDoseDate.difference(applicationDate).inDays;
    return difference >= 0 && difference <= 365; // Maximum 1 year interval
  }

  /// Gets validation error for date interval
  String? validateDateInterval(
      DateTime? applicationDate, DateTime? nextDoseDate) {
    if (applicationDate == null || nextDoseDate == null) {
      return null;
    }

    if (!isValidDateInterval(applicationDate, nextDoseDate)) {
      return 'Intervalo entre doses deve ser de no máximo 1 ano';
    }

    return null;
  }

  /// Validates if all required fields are filled
  bool areRequiredFieldsFilled({
    required String? animalId,
    required String? nomeVacina,
    required DateTime? dataAplicacao,
    required DateTime? proximaDose,
  }) {
    return animalId != null &&
        animalId.isNotEmpty &&
        nomeVacina != null &&
        nomeVacina.trim().isNotEmpty &&
        dataAplicacao != null &&
        proximaDose != null;
  }

  /// Gets comprehensive validation result
  Map<String, String?> getValidationResults({
    required String? animalId,
    required String? nomeVacina,
    required DateTime? dataAplicacao,
    required DateTime? proximaDose,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'nomeVacina': validateVaccineName(nomeVacina),
      'dataAplicacao': validateApplicationDate(dataAplicacao),
      'proximaDose': validateNextDoseDate(proximaDose, dataAplicacao),
      'observacoes': validateObservations(observacoes),
      'dateInterval': validateDateInterval(dataAplicacao, proximaDose),
    };
  }

  /// Checks if form is valid
  bool isFormValid({
    required String? animalId,
    required String? nomeVacina,
    required DateTime? dataAplicacao,
    required DateTime? proximaDose,
    String? observacoes,
  }) {
    final validationResults = getValidationResults(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );

    return validationResults.values.every((error) => error == null);
  }

  /// Suggests next dose date based on application date
  DateTime? suggestNextDoseDate(DateTime? applicationDate) {
    if (applicationDate == null) return null;

    return DateTime(
      applicationDate.year,
      applicationDate.month + 1,
      applicationDate.day,
    ); // Default to 1 month later
  }

  /// Validates form for submission
  Map<String, dynamic> validateForSubmission({
    required String? animalId,
    required String? nomeVacina,
    required DateTime? dataAplicacao,
    required DateTime? proximaDose,
    String? observacoes,
  }) {
    final validationResults = getValidationResults(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );

    final errors = validationResults.entries
        .where((entry) => entry.value != null)
        .map((entry) => entry.value!)
        .toList();

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'fieldErrors': validationResults,
    };
  }
}
