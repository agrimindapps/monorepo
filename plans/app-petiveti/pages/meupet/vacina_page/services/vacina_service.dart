// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service class for vaccine-related business logic and error handling.
/// 
/// This service provides utility methods for:
/// - Error message translation and user-friendly formatting
/// - Data validation and sanitization
/// - Date range validation
/// - Logging and debugging support
/// 
/// The service acts as a bridge between the raw data layer and the
/// business logic layer, ensuring data integrity and providing
/// consistent error handling across the vaccine management system.
/// 
/// Example usage:
/// ```dart
/// final service = VacinaService();
/// final userMessage = service.getErrorMessage(exception);
/// final isValid = service.validateVaccineData(
///   animalId: 'animal123',
///   vaccineName: 'Rabies',
///   applicationDate: DateTime.now().millisecondsSinceEpoch,
///   nextDoseDate: DateTime.now().add(Duration(days: 365)).millisecondsSinceEpoch,
/// );
/// ```
class VacinaService {
  
  /// Converts technical exceptions into user-friendly error messages.
  /// 
  /// This method analyzes different types of exceptions and returns
  /// appropriate messages that can be displayed to end users. It handles
  /// common network, server, and data format errors.
  /// 
  /// Supported exception types:
  /// - [TimeoutException]: Connection timeout errors
  /// - [SocketException]: Network connectivity issues
  /// - [HttpException]: HTTP protocol errors
  /// - [FormatException]: Data parsing errors
  /// - HTTP status codes (404, 401, 403, 500)
  /// 
  /// Parameters:
  /// - [error]: The exception or error object to translate
  /// 
  /// Returns:
  /// - A user-friendly error message in Portuguese
  String getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Conexão muito lenta. Verifique sua internet e tente novamente.';
    } else if (error is SocketException) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    } else if (error is HttpException) {
      return 'Erro no servidor. Tente novamente em alguns minutos.';
    } else if (error is FormatException) {
      return 'Dados inválidos recebidos do servidor. Contate o suporte se o problema persistir.';
    } else if (error.toString().contains('404')) {
      return 'Recurso não encontrado. Verifique se o animal ainda existe.';
    } else if (error.toString().contains('401') || error.toString().contains('403')) {
      return 'Acesso negado. Faça login novamente.';
    } else if (error.toString().contains('500')) {
      return 'Erro interno do servidor. Tente novamente mais tarde.';
    } else {
      return 'Erro inesperado: ${error.toString()}. Tente novamente ou contate o suporte.';
    }
  }

  /// Validates vaccine data before processing operations.
  /// 
  /// Performs comprehensive validation of vaccine data including:
  /// - Animal ID presence and validity
  /// - Vaccine name requirements
  /// - Date validity (positive timestamps)
  /// - Logical date ordering (next dose after application)
  /// 
  /// This method provides basic validation that complements the more
  /// detailed validation in [VacinaValidators].
  /// 
  /// Parameters:
  /// - [animalId]: ID of the animal receiving the vaccine
  /// - [vaccineName]: Name/type of the vaccine
  /// - [applicationDate]: Timestamp of vaccine application
  /// - [nextDoseDate]: Timestamp of next required dose
  /// 
  /// Returns:
  /// - `true` if all validation checks pass
  /// - `false` if any validation fails
  bool validateVaccineData({
    required String animalId,
    required String vaccineName,
    required int applicationDate,
    required int nextDoseDate,
  }) {
    if (animalId.isEmpty) return false;
    if (vaccineName.trim().isEmpty) return false;
    if (applicationDate <= 0) return false;
    if (nextDoseDate <= 0) return false;
    if (nextDoseDate <= applicationDate) return false;
    
    return true;
  }

  /// Sanitizes vaccine name input
  String sanitizeVaccineName(String name) {
    return name.trim()
        .replaceAll(RegExp(r'[<>"' "'" r']'), '') // Remove potential dangerous characters
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }

  /// Calculates days between two timestamps
  /// Uses consistent calculation method across the application
  int calculateDaysBetween(int fromTimestamp, int toTimestamp) {
    final fromDate = DateTime.fromMillisecondsSinceEpoch(fromTimestamp);
    final toDate = DateTime.fromMillisecondsSinceEpoch(toTimestamp);
    return toDate.difference(fromDate).inDays;
  }

  /// Checks if a date is within a valid range
  bool isDateInValidRange(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final minDate = DateTime(1900);
    final maxDate = now.add(const Duration(days: 365 * 10)); // 10 years in future
    
    return date.isAfter(minDate) && date.isBefore(maxDate);
  }

  /// Formats error message for user display
  String formatUserErrorMessage(String error) {
    // Remove technical details and make user-friendly
    if (error.toLowerCase().contains('timeout')) {
      return 'A operação demorou muito. Tente novamente.';
    }
    if (error.toLowerCase().contains('network')) {
      return 'Problema de conexão. Verifique sua internet.';
    }
    if (error.toLowerCase().contains('server')) {
      return 'Problema no servidor. Tente novamente em alguns minutos.';
    }
    
    return 'Ocorreu um erro. Tente novamente.';
  }

  /// Logs error for debugging purposes
  void logError(String operation, dynamic error) {
    debugPrint('[$operation] Error: $error');
    debugPrint('[$operation] Stack trace: ${StackTrace.current}');
  }
}
