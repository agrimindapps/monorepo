// Main entry point for consulta utilities
// Re-exports all consulta utility functions for backward compatibility

// Legacy compatibility - maintains existing API

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'consulta/consulta_core.dart';
import 'consulta/consulta_date_utils.dart';
import 'consulta/consulta_display_utils.dart';
import 'consulta/consulta_validators.dart';

export 'consulta/consulta_core.dart';
export 'consulta/consulta_date_utils.dart';
export 'consulta/consulta_display_utils.dart';
export 'consulta/consulta_form_helpers.dart';
export 'consulta/consulta_validators.dart';

class ConsultaUtils {
  static Color getMotivoColor(String motivo) {
    return ConsultaDisplayUtils.getMotivoColor(motivo);
  }

  static String getMotivoIcon(String motivo) {
    return ConsultaDisplayUtils.getMotivoIcon(motivo);
  }

  static List<String> getAvailableMotivos() {
    return ConsultaCore.getAvailableMotivos();
  }

  static String? getDefaultMotivo() {
    return ConsultaCore.getDefaultMotivo();
  }

  static bool isMotivoValid(String motivo) {
    return ConsultaCore.isMotivoValid(motivo);
  }

  static String normalizeMotivo(String motivo) {
    return ConsultaCore.normalizeMotivo(motivo);
  }

  static List<String> getCommonVeterinarios() {
    return ConsultaCore.getCommonVeterinarios();
  }

  static String? generateSuggestion(String motivo, String? currentText) {
    return ConsultaCore.generateSuggestion(motivo, currentText);
  }

  static bool isValidDate(DateTime date) {
    return ConsultaValidators.isValidDate(date);
  }

  static bool isValidVeterinario(String veterinario) {
    return ConsultaValidators.isValidVeterinario(veterinario);
  }

  static bool isValidMotivo(String motivo) {
    return ConsultaValidators.isValidMotivo(motivo);
  }

  static bool isValidDiagnostico(String diagnostico) {
    return ConsultaValidators.isValidDiagnostico(diagnostico);
  }

  static bool isValidObservacoes(String? observacoes) {
    return ConsultaValidators.isValidObservacoes(observacoes);
  }

  static String getValidationMessage(String field, String? error) {
    return ConsultaValidators.getValidationMessage(field, error);
  }

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required DateTime dataConsulta,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    String? observacoes,
  }) {
    return ConsultaDisplayUtils.exportDisplayData(
      animalId: animalId,
      dataConsulta: dataConsulta,
      veterinario: veterinario,
      motivo: motivo,
      diagnostico: diagnostico,
      observacoes: observacoes,
    );
  }

  static Map<String, String> validateConsultationData({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
    String? observacoes,
  }) {
    return ConsultaValidators.validateConsultationData(
      animalId: animalId,
      veterinario: veterinario,
      motivo: motivo,
      diagnostico: diagnostico,
      dataConsulta: dataConsulta,
      observacoes: observacoes,
    );
  }

  static String formatData(DateTime date) {
    return ConsultaDateUtils.formatData(date);
  }

  static String formatDataCompleta(DateTime date) {
    return ConsultaDateUtils.formatDataCompleta(date);
  }

  static DateTime? parseData(String dateString) {
    return ConsultaDateUtils.parseData(dateString);
  }

  static bool isToday(DateTime date) {
    return ConsultaDateUtils.isToday(date);
  }

  static bool isThisWeek(DateTime date) {
    return ConsultaDateUtils.isThisWeek(date);
  }

  static bool isThisMonth(DateTime date) {
    return ConsultaDateUtils.isThisMonth(date);
  }

  static bool isThisYear(DateTime date) {
    return ConsultaDateUtils.isThisYear(date);
  }

  static String getRelativeTime(DateTime date) {
    return ConsultaDateUtils.getRelativeTime(date);
  }

  static DateTime getStartOfDay(DateTime date) {
    return ConsultaDateUtils.getStartOfDay(date);
  }

  static DateTime getEndOfDay(DateTime date) {
    return ConsultaDateUtils.getEndOfDay(date);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return ConsultaDateUtils.getStartOfMonth(date);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return ConsultaDateUtils.getEndOfMonth(date);
  }

  static String truncateText(String text, int maxLength) {
    return ConsultaDisplayUtils.truncateText(text, maxLength);
  }

  static String capitalizeText(String text) {
    return ConsultaDisplayUtils.capitalizeText(text);
  }

  static String escapeForCsv(String field) {
    return ConsultaDisplayUtils.escapeForCsv(field);
  }

  static int calculatePriority(String motivo) {
    return ConsultaCore.calculatePriority(motivo);
  }

  static String getPriorityText(int priority) {
    return ConsultaCore.getPriorityText(priority);
  }

  static bool requiresFollowUp(String motivo) {
    return ConsultaCore.requiresFollowUp(motivo);
  }

  static int getEstimatedDuration(String motivo) {
    return ConsultaCore.getEstimatedDuration(motivo);
  }
}
