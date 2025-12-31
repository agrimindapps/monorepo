import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';

/// Service responsible for validating appointment business rules
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles appointment validation logic
/// - **Open/Closed**: New validation rules can be added without modifying existing code
/// - **Dependency Inversion**: Use cases depend on this abstraction
class AppointmentValidationService {
  /// Validates veterinarian name
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateVeterinarianName(String veterinarianName) {
    final trimmed = veterinarianName.trim();
    if (trimmed.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário é obrigatório'),
      );
    }
    if (trimmed.length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário deve ter pelo menos 2 caracteres'),
      );
    }
    if (trimmed.length > 100) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário deve ter no máximo 100 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates reason for appointment
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 3 characters
  /// - Must have at most 200 characters
  Either<Failure, void> validateReason(String reason) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Motivo da consulta é obrigatório'),
      );
    }
    if (trimmed.length < 3) {
      return const Left(
        ValidationFailure(message: 'Motivo deve ter pelo menos 3 caracteres'),
      );
    }
    if (trimmed.length > 200) {
      return const Left(
        ValidationFailure(message: 'Motivo deve ter no máximo 200 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates diagnosis
  ///
  /// **Rules:**
  /// - If provided, must have at most 500 characters
  Either<Failure, void> validateDiagnosis(String? diagnosis) {
    if (diagnosis == null || diagnosis.trim().isEmpty) return const Right(null);
    
    if (diagnosis.trim().length > 500) {
      return const Left(
        ValidationFailure(message: 'Diagnóstico deve ter no máximo 500 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates notes
  ///
  /// **Rules:**
  /// - If provided, must have at most 500 characters
  Either<Failure, void> validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return const Right(null);
    
    if (notes.trim().length > 500) {
      return const Left(
        ValidationFailure(message: 'Observações devem ter no máximo 500 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates animal ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  Either<Failure, void> validateAnimalId(String animalId) {
    if (animalId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Animal deve ser selecionado'),
      );
    }
    return const Right(null);
  }

  /// Validates appointment ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  Either<Failure, void> validateId(String id) {
    if (id.isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID da consulta é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates appointment date for new appointments
  ///
  /// **Rules:**
  /// - Cannot be more than 1 year in the past
  /// - Cannot be more than 2 years in the future
  Either<Failure, void> validateDate(DateTime date) {
    final now = DateTime.now();
    
    // Allow dates up to 1 year in the past (for registering past appointments)
    final minDate = now.subtract(const Duration(days: 365));
    if (date.isBefore(minDate)) {
      return const Left(
        ValidationFailure(message: 'Data da consulta não pode ser superior a 1 ano no passado'),
      );
    }
    
    // Cannot be more than 2 years in the future
    final maxDate = now.add(const Duration(days: 730));
    if (date.isAfter(maxDate)) {
      return const Left(
        ValidationFailure(message: 'Data da consulta não pode ser superior a 2 anos no futuro'),
      );
    }
    
    return const Right(null);
  }

  /// Validates appointment date for scheduling (must be future)
  ///
  /// **Rules:**
  /// - Must be today or in the future
  Either<Failure, void> validateDateForScheduling(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(date.year, date.month, date.day);

    if (appointmentDate.isBefore(today)) {
      return const Left(
        ValidationFailure(message: 'Data do agendamento não pode ser no passado'),
      );
    }
    return const Right(null);
  }

  /// Validates cost
  ///
  /// **Rules:**
  /// - If provided, must be >= 0
  /// - If provided, must be <= 100000 (reasonable max)
  Either<Failure, void> validateCost(double? cost) {
    if (cost == null) return const Right(null);
    
    if (cost < 0) {
      return const Left(
        ValidationFailure(message: 'Valor não pode ser negativo'),
      );
    }
    if (cost > 100000) {
      return const Left(
        ValidationFailure(message: 'Valor máximo é R\$ 100.000,00'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields required for adding a new appointment
  Either<Failure, void> validateForAdd(Appointment appointment) {
    // Validate veterinarian name
    final veterinarianValidation = validateVeterinarianName(
      appointment.veterinarianName,
    );
    if (veterinarianValidation.isLeft()) {
      return veterinarianValidation;
    }

    // Validate reason
    final reasonValidation = validateReason(appointment.reason);
    if (reasonValidation.isLeft()) {
      return reasonValidation;
    }

    // Validate animal ID
    final animalIdValidation = validateAnimalId(appointment.animalId);
    if (animalIdValidation.isLeft()) {
      return animalIdValidation;
    }

    // Validate date
    final dateValidation = validateDate(appointment.date);
    if (dateValidation.isLeft()) {
      return dateValidation;
    }

    // Validate diagnosis
    final diagnosisValidation = validateDiagnosis(appointment.diagnosis);
    if (diagnosisValidation.isLeft()) {
      return diagnosisValidation;
    }

    // Validate notes
    final notesValidation = validateNotes(appointment.notes);
    if (notesValidation.isLeft()) {
      return notesValidation;
    }

    // Validate cost
    final costValidation = validateCost(appointment.cost);
    if (costValidation.isLeft()) {
      return costValidation;
    }

    return const Right(null);
  }

  /// Validates all fields required for updating an existing appointment
  Either<Failure, void> validateForUpdate(Appointment appointment) {
    // Validate ID first
    final idValidation = validateId(appointment.id);
    if (idValidation.isLeft()) {
      return idValidation;
    }

    // Validate all other fields using add validation
    return validateForAdd(appointment);
  }
}
