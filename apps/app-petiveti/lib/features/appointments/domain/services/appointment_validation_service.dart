import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';

/// Service responsible for validating appointment business rules
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles appointment validation logic
/// - **Open/Closed**: New validation rules can be added without modifying existing code
/// - **Dependency Inversion**: Use cases depend on this abstraction
///
/// **Features:**
/// - Validates veterinarian name
/// - Validates reason for appointment
/// - Validates animal selection
/// - Validates appointment ID
/// - Validates appointment date
/// - Composite validation for add/update operations
class AppointmentValidationService {
  /// Validates veterinarian name
  ///
  /// Returns ValidationFailure if:
  /// - Name is empty
  /// - Name contains only whitespace
  Either<Failure, void> validateVeterinarianName(String veterinarianName) {
    if (veterinarianName.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates reason for appointment
  ///
  /// Returns ValidationFailure if:
  /// - Reason is empty
  /// - Reason contains only whitespace
  Either<Failure, void> validateReason(String reason) {
    if (reason.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Motivo da consulta é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates animal ID
  ///
  /// Returns ValidationFailure if:
  /// - Animal ID is empty
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
  /// Returns ValidationFailure if:
  /// - ID is empty
  Either<Failure, void> validateId(String id) {
    if (id.isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID da consulta é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates appointment date
  ///
  /// Returns ValidationFailure if:
  /// - Date is in the past (before today)
  ///
  /// Note: Allows today's date and future dates
  Either<Failure, void> validateDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(date.year, date.month, date.day);

    if (appointmentDate.isBefore(today)) {
      return const Left(
        ValidationFailure(message: 'Data da consulta não pode ser no passado'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields required for adding a new appointment
  ///
  /// Validates:
  /// - Veterinarian name
  /// - Reason
  /// - Animal ID
  /// - Appointment date
  ///
  /// Returns first validation failure encountered, or success if all validations pass
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

    return const Right(null);
  }

  /// Validates all fields required for updating an existing appointment
  ///
  /// Validates:
  /// - Appointment ID (must exist)
  /// - All fields from validateForAdd
  ///
  /// Returns first validation failure encountered, or success if all validations pass
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
