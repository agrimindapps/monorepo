// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../config/lembrete_form_config.dart';

class LembreteFormValidators {
  // Constantes removidas - agora centralizadas em LembreteFormConfig
  
  // Métodos de validação simplificados - delegando para a configuração central
  static String? validateTitulo(String? value) => LembreteFormConfig.validateTitulo(value);
  
  static String? validateDescricao(String? value) => LembreteFormConfig.validateDescricao(value);
  
  static String? validateAnimalId(String? value) => LembreteFormConfig.validateAnimalId(value);
  
  static String? validateDataHora(DateTime? value) => LembreteFormConfig.validateDataHora(value);
  
  static String? validateTipo(String? value) => LembreteFormConfig.validateTipo(value);
  
  static String? validateRepetir(String? value) => LembreteFormConfig.validateRepetir(value);

  // Métodos delegados para configuração central
  static bool isFormValid({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    String? tipo,
    String? repetir,
  }) => LembreteFormConfig.isFormValid(
        titulo: titulo,
        descricao: descricao,
        animalId: animalId,
        dataHora: dataHora,
        tipo: tipo,
        repetir: repetir,
      );

  static Map<String, String?> validateAllFields({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) => LembreteFormConfig.validateAllFields(
        titulo: titulo,
        descricao: descricao,
        animalId: animalId,
        dataHora: dataHora,
        tipo: tipo,
        repetir: repetir,
      );

  static bool isValidTitulo(String titulo) => LembreteFormConfig.isValidTitulo(titulo);

  static bool isValidDescricao(String descricao) => LembreteFormConfig.isValidDescricao(descricao);

  static bool isValidDataHora(DateTime dataHora) => LembreteFormConfig.isValidDataHora(dataHora);

  static String sanitizeTitulo(String titulo) => LembreteFormConfig.sanitizeTitulo(titulo);

  static String sanitizeDescricao(String descricao) => LembreteFormConfig.sanitizeDescricao(descricao);

  static DateTime getNextValidDateTime([DateTime? currentDateTime]) => 
      LembreteFormConfig.getNextValidDateTime(currentDateTime);

  static List<String> getValidTipos() => LembreteFormConfig.tiposValidos;

  static List<String> getValidRepeticoes() => LembreteFormConfig.repeticoesValidas;

  static String? validateDateTime({
    required DateTime date,
    required TimeOfDay time,
  }) {
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    return validateDataHora(combinedDateTime);
  }

  static String? validateDateOnly(DateTime? date) => LembreteFormConfig.validateDataOnly(date);

  static String? validateTimeOnly({
    required TimeOfDay? time,
    required DateTime date,
  }) => LembreteFormConfig.validateTimeOnly(time: time, date: date);

  static bool isToday(DateTime date) => LembreteFormConfig.isToday(date);

  static bool isTomorrow(DateTime date) => LembreteFormConfig.isTomorrow(date);

  static bool isPastDue(DateTime dateTime) => LembreteFormConfig.isPastDue(dateTime);

  static Duration getTimeUntil(DateTime dateTime) => LembreteFormConfig.getTimeUntil(dateTime);

  static String formatValidationError(String fieldName, String? error) => 
      LembreteFormConfig.formatValidationError(fieldName, error);

  static List<String> getAllValidationErrors({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) => LembreteFormConfig.getAllValidationErrors(
        titulo: titulo,
        descricao: descricao,
        animalId: animalId,
        dataHora: dataHora,
        tipo: tipo,
        repetir: repetir,
      );

  static bool hasAnyValidationError({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) => LembreteFormConfig.hasAnyValidationError(
        titulo: titulo,
        descricao: descricao,
        animalId: animalId,
        dataHora: dataHora,
        tipo: tipo,
        repetir: repetir,
      );
}
