// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;
import '../../../../../../app-petiveti/utils/peso/peso_calculations.dart';
import '../../../../../../app-petiveti/utils/peso/peso_core.dart' as peso_core;
import '../../../../../../app-petiveti/utils/peso/peso_validators.dart' as peso_validators;
import '../../../../../../app-petiveti/utils/string_utils.dart';
import '../../../../models/17_peso_model.dart';

class PesoUtils {
  // Delegated functions to centralized utils - Core functions
  static String formatPeso(double peso) => peso_core.PesoCore.formatPeso(peso);
  static String formatPesoWithUnit(double peso) => peso_core.PesoCore.formatPesoWithUnit(peso);
  static String formatPesoWithPrecision(double peso, int precision) => peso_core.PesoCore.formatPesoWithPrecision(peso, precision);
  static String formatPesoChange(double change) => peso_core.PesoCore.formatPesoChange(change);
  static String formatPesoChangePercentage(double change, double previousPeso) => peso_core.PesoCore.formatPesoChangePercentage(change, previousPeso);
  static double? parsePeso(String? value) => peso_core.PesoCore.parsePeso(value);
  static double parsePesoFromString(String value) => peso_core.PesoCore.parsePesoFromString(value);
  static String cleanPesoInput(String input) => peso_core.PesoCore.cleanPesoInput(input);
  static double roundPeso(double peso, {int decimalPlaces = 2}) => peso_core.PesoCore.roundPeso(peso, decimalPlaces: decimalPlaces);
  static bool isValidPesoRange(double peso) => peso_core.PesoCore.isValidPesoRange(peso);
  static String getPesoCategory(double peso) => peso_core.PesoCore.getPesoCategory(peso);
  static Color getPesoCategoryColor(String category) => peso_core.PesoCore.getPesoCategoryColor(category);
  static String getPesoStatusIcon(String category) => peso_core.PesoCore.getPesoStatusIcon(category);
  static List<double> generatePesoSuggestions(double? currentPeso) => peso_core.PesoCore.generatePesoSuggestions(currentPeso);
  static Map<String, double> convertPesoToUnits(double pesoInKg) => peso_core.PesoCore.convertPesoToUnits(pesoInKg);
  static String formatPesoInUnit(double pesoInKg, String unit) => peso_core.PesoCore.formatPesoInUnit(pesoInKg, unit);
  
  // Delegated functions to centralized utils - Validation functions
  static String? validatePesoValue(double? peso) => peso_validators.PesoValidators.validatePesoValue(peso);
  static String? validatePeso(String? value) => peso_validators.PesoValidators.validatePeso(value);
  static String? validateDogPeso(String? value) => peso_validators.PesoValidators.validateDogPeso(value);
  static String? validateCatPeso(String? value) => peso_validators.PesoValidators.validateCatPeso(value);
  static String? validatePesoChange(double currentPeso, double? previousPeso) => peso_validators.PesoValidators.validatePesoChange(currentPeso, previousPeso);
  static String? validatePesoForAge(double peso, DateTime birthDate, String animalType) => peso_validators.PesoValidators.validatePesoForAge(peso, birthDate, animalType);
  
  // Delegated functions to centralized utils - Calculation functions
  static double? calculateBMI(double peso, String animalType) => PesoCalculations.calculateBMI(peso, animalType);
  static double calculateAveragePeso(List<PesoAnimal> pesos) => PesoCalculations.calculateAveragePeso(pesos);
  static double calculatePesoVariance(List<PesoAnimal> pesos) => PesoCalculations.calculatePesoVariance(pesos);
  static double calculatePesoStandardDeviation(List<PesoAnimal> pesos) => PesoCalculations.calculatePesoStandardDeviation(pesos);
  static List<PesoAnimal> findPesoOutliers(List<PesoAnimal> pesos, {double threshold = 2.0}) => PesoCalculations.findPesoOutliers(pesos, threshold: threshold);
  static List<ChartDataPoint> generateChartData(List<PesoAnimal> pesos) => PesoCalculations.generateChartData(pesos);
  static List<ChartDataPoint> calculateTrendLine(List<PesoAnimal> pesos) => PesoCalculations.calculateTrendLine(pesos);
  static Map<String, List<PesoAnimal>> groupPesosByMonth(List<PesoAnimal> pesos) => PesoCalculations.groupPesosByMonth(pesos);
  static double? calculateGrowthRate(List<PesoAnimal> pesos) => PesoCalculations.calculateGrowthRate(pesos);
  static String formatGrowthRate(double? growthRate) => PesoCalculations.formatGrowthRate(growthRate);
  static Map<String, double>? calculateIdealPesoRange(String animalType, String? breed) => PesoCalculations.calculateIdealPesoRange(animalType, breed);
  
  // Export function
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
  
  // Page-specific utility functions (keep these)
  static Map<String, dynamic> getPesoStatistics(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return {'count': 0, 'average': 0.0, 'trend': 'stable'};
    
    final average = calculateAveragePeso(pesos);
    final growthRate = calculateGrowthRate(pesos);
    
    String trend = 'stable';
    if (growthRate != null) {
      if (growthRate > 0.1) {
        trend = 'increasing';
      } else if (growthRate < -0.1) {
        trend = 'decreasing';
      }
    }
    
    return {
      'count': pesos.length,
      'average': average,
      'trend': trend,
      'growthRate': growthRate,
    };
  }
  
  static List<PesoAnimal> sortPesosByDate(List<PesoAnimal> pesos, {bool ascending = false}) {
    final sorted = List<PesoAnimal>.from(pesos);
    sorted.sort((a, b) => ascending 
      ? a.dataPesagem.compareTo(b.dataPesagem)
      : b.dataPesagem.compareTo(a.dataPesagem));
    return sorted;
  }
  
  static List<PesoAnimal> filterPesosByDateRange(List<PesoAnimal> pesos, DateTime start, DateTime end) {
    return pesos.where((peso) {
      final pesoDate = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      return pesoDate.isAfter(start) && pesoDate.isBefore(end);
    }).toList();
  }
  
  static String getDisplayTitle(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 'Nenhum registro';
    if (pesos.length == 1) return '1 registro de peso';
    return '${pesos.length} registros de peso';
  }
}
