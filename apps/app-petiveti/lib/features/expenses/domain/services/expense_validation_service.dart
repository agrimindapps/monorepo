import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

/// Service responsible for expense-related validations
/// Follows Single Responsibility Principle - only handles validation logic
class ExpenseValidationService {
  const ExpenseValidationService();

  /// Validates expense title/description
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 3 characters
  /// - Must have at most 150 characters
  Either<Failure, String> validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Descrição da despesa é obrigatória'));
    }

    if (trimmed.length < 3) {
      return const Left(ValidationFailure(
          message: 'Descrição deve ter pelo menos 3 caracteres'));
    }

    if (trimmed.length > 150) {
      return const Left(ValidationFailure(
          message: 'Descrição deve ter no máximo 150 caracteres'));
    }

    return Right(trimmed);
  }

  /// Validates expense amount
  ///
  /// **Rules:**
  /// - Must be greater than 0
  /// - Must be less than or equal to 999999.99
  Either<Failure, double> validateAmount(double amount) {
    if (amount <= 0) {
      return const Left(ValidationFailure(
          message: 'Valor da despesa deve ser maior que zero'));
    }

    if (amount > 999999.99) {
      return const Left(ValidationFailure(
          message: 'Valor máximo é R\$ 999.999,99'));
    }

    return Right(amount);
  }

  /// Validates expense date
  ///
  /// **Rules:**
  /// - Cannot be in the future
  /// - Cannot be more than 5 years in the past
  Either<Failure, DateTime> validateDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (date.isAfter(tomorrow)) {
      return const Left(
          ValidationFailure(message: 'Data da despesa não pode ser futura'));
    }

    // Check if date is too old (more than 5 years)
    final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 5));
    if (date.isBefore(fiveYearsAgo)) {
      return const Left(
          ValidationFailure(message: 'Data da despesa não pode ser superior a 5 anos no passado'));
    }

    return Right(date);
  }

  /// Validates expense ID
  Either<Failure, String> validateId(String id) {
    if (id.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'ID da despesa é obrigatório'));
    }

    return Right(id.trim());
  }

  /// Validates veterinarian/clinic name
  ///
  /// **Rules:**
  /// - If provided, must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateVeterinarian(String? veterinarian) {
    if (veterinarian == null || veterinarian.trim().isEmpty) {
      return const Right(null);
    }

    final trimmed = veterinarian.trim();
    if (trimmed.length < 2) {
      return const Left(ValidationFailure(
          message: 'Nome do veterinário/local deve ter pelo menos 2 caracteres'));
    }

    if (trimmed.length > 100) {
      return const Left(ValidationFailure(
          message: 'Nome do veterinário/local deve ter no máximo 100 caracteres'));
    }

    return const Right(null);
  }

  /// Validates receipt number
  ///
  /// **Rules:**
  /// - If provided, must have at least 3 characters
  /// - Must have at most 50 characters
  Either<Failure, void> validateReceiptNumber(String? receiptNumber) {
    if (receiptNumber == null || receiptNumber.trim().isEmpty) {
      return const Right(null);
    }

    final trimmed = receiptNumber.trim();
    if (trimmed.length < 3) {
      return const Left(ValidationFailure(
          message: 'Número do recibo deve ter pelo menos 3 caracteres'));
    }

    if (trimmed.length > 50) {
      return const Left(ValidationFailure(
          message: 'Número do recibo deve ter no máximo 50 caracteres'));
    }

    return const Right(null);
  }

  /// Validates notes
  ///
  /// **Rules:**
  /// - If provided, must have at most 500 characters
  Either<Failure, void> validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) {
      return const Right(null);
    }

    if (notes.trim().length > 500) {
      return const Left(ValidationFailure(
          message: 'Observações devem ter no máximo 500 caracteres'));
    }

    return const Right(null);
  }

  /// Validates category is selected
  Either<Failure, void> validateCategory(ExpenseCategory? category) {
    if (category == null) {
      return const Left(ValidationFailure(
          message: 'Categoria é obrigatória'));
    }
    return const Right(null);
  }

  /// Validates complete expense for adding
  Either<Failure, Expense> validateForAdd(Expense expense) {
    // Validate title
    final titleValidation = validateTitle(expense.title);
    if (titleValidation.isLeft()) {
      return titleValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate amount
    final amountValidation = validateAmount(expense.amount);
    if (amountValidation.isLeft()) {
      return amountValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate date
    final dateValidation = validateDate(expense.expenseDate);
    if (dateValidation.isLeft()) {
      return dateValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate veterinarian
    final vetValidation = validateVeterinarian(expense.veterinarian);
    if (vetValidation.isLeft()) {
      return vetValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate receipt number
    final receiptValidation = validateReceiptNumber(expense.receiptNumber);
    if (receiptValidation.isLeft()) {
      return receiptValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate notes
    final notesValidation = validateNotes(expense.notes);
    if (notesValidation.isLeft()) {
      return notesValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    return Right(expense);
  }

  /// Validates complete expense for updating
  Either<Failure, Expense> validateForUpdate(Expense expense) {
    // Validate ID first
    final idValidation = validateId(expense.id);
    if (idValidation.isLeft()) {
      return idValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    return validateForAdd(expense);
  }
}
