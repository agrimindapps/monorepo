// Main entry point for despesas utilities
// Re-exports all despesas utility functions for backward compatibility

// Legacy compatibility - maintains existing API

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'despesas/despesas_core.dart';
import 'despesas/despesas_date_utils.dart';
import 'despesas/despesas_display_utils.dart';
import 'despesas/despesas_validators.dart';

export 'despesas/despesas_core.dart';
export 'despesas/despesas_date_utils.dart';
export 'despesas/despesas_display_utils.dart';
export 'despesas/despesas_form_helpers.dart';
export 'despesas/despesas_validators.dart';

class DespesasUtils {
  static String getTipoIcon(String tipo) {
    return DespesasDisplayUtils.getTipoIcon(tipo);
  }

  static Color getTipoColor(String tipo) {
    return DespesasDisplayUtils.getTipoColor(tipo);
  }

  static List<String> getAvailableTipos() {
    return DespesasCore.getAvailableTipos();
  }

  static List<String> getCommonTipos() {
    return DespesasCore.getCommonTipos();
  }

  static String? getDefaultTipo() {
    return DespesasCore.getDefaultTipo();
  }

  static bool isTipoValid(String tipo) {
    return DespesasCore.isTipoValid(tipo);
  }

  static String normalizeTipo(String tipo) {
    return DespesasCore.normalizeTipo(tipo);
  }

  static bool isValidValor(double valor) {
    return DespesasCore.isValidValor(valor);
  }

  static bool isValidDescricao(String descricao) {
    return DespesasCore.isValidDescricao(descricao);
  }

  static bool isValidObservacao(String? observacao) {
    return DespesasCore.isValidObservacao(observacao);
  }

  static String getValidationMessage(String field, String? error) {
    return DespesasValidators.getValidationMessage(field, error);
  }

  static String? generateSuggestion(String tipo, String? currentText) {
    return DespesasCore.generateSuggestion(tipo, currentText);
  }

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required DateTime data,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return DespesasDisplayUtils.exportDisplayData(
      animalId: animalId,
      data: data,
      tipo: tipo,
      valor: valor,
      descricao: descricao,
      observacao: observacao,
    );
  }

  static String formatData(DateTime date) {
    return DespesasDateUtils.formatData(date);
  }

  static String formatDataCompleta(DateTime date) {
    return DespesasDateUtils.formatDataCompleta(date);
  }

  static DateTime? parseData(String dateString) {
    return DespesasDateUtils.parseData(dateString);
  }

  static String truncateText(String text, int maxLength) {
    return DespesasDisplayUtils.truncateText(text, maxLength);
  }

  static bool isToday(DateTime date) {
    return DespesasDateUtils.isToday(date);
  }

  static bool isThisWeek(DateTime date) {
    return DespesasDateUtils.isThisWeek(date);
  }

  static bool isThisMonth(DateTime date) {
    return DespesasDateUtils.isThisMonth(date);
  }

  static bool isThisYear(DateTime date) {
    return DespesasDateUtils.isThisYear(date);
  }

  static String getRelativeTime(DateTime date) {
    return DespesasDateUtils.getRelativeTime(date);
  }

  static String escapeForCsv(String field) {
    return DespesasDisplayUtils.escapeForCsv(field);
  }

  static double calculatePercentage(double value, double total) {
    return DespesasCore.calculatePercentage(value, total);
  }

  static String formatPercentage(double percentage) {
    return DespesasDisplayUtils.formatPercentage(percentage);
  }

  static DateTime getStartOfDay(DateTime date) {
    return DespesasDateUtils.getStartOfDay(date);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DespesasDateUtils.getEndOfDay(date);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DespesasDateUtils.getStartOfMonth(date);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DespesasDateUtils.getEndOfMonth(date);
  }

  static double roundToTwoDecimals(double value) {
    return DespesasCore.roundToTwoDecimals(value);
  }

  static bool isValidValueRange(double value) {
    return DespesasCore.isValidValueRange(value);
  }

  static bool isValidDescriptionLength(String description) {
    return DespesasCore.isValidDescriptionLength(description);
  }

  static String limitDescription(String description) {
    return DespesasCore.limitDescription(description);
  }
}
