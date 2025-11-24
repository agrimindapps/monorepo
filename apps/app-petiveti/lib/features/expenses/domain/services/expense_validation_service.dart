import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

/// Service responsible for expense-related validations
/// Follows Single Responsibility Principle - only handles validation logic
class ExpenseValidationService {
  const ExpenseValidationService();

  /// Validates expense title
  Either<Failure, String> validateTitle(String title) {
    if (title.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Título da despesa é obrigatório'));
    }

    if (title.trim().length < 3) {
      return const Left(ValidationFailure(
          message: 'Título deve ter pelo menos 3 caracteres'));
    }

    return Right(title.trim());
  }

  /// Validates expense amount
  Either<Failure, double> validateAmount(double amount) {
    if (amount <= 0) {
      return const Left(ValidationFailure(
          message: 'Valor da despesa deve ser maior que zero'));
    }

    if (amount > 1000000) {
      return const Left(ValidationFailure(
          message: 'Valor da despesa excede o limite permitido'));
    }

    return Right(amount);
  }

  /// Validates expense date
  Either<Failure, DateTime> validateDate(DateTime date) {
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return const Left(
          ValidationFailure(message: 'Data da despesa não pode ser futura'));
    }

    // Check if date is too old (more than 10 years)
    final tenYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 10));
    if (date.isBefore(tenYearsAgo)) {
      return const Left(
          ValidationFailure(message: 'Data da despesa é muito antiga'));
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

  /// Validates complete expense for adding
  Either<Failure, Expense> validateForAdd(Expense expense) {
    final titleValidation = validateTitle(expense.title);
    if (titleValidation.isLeft()) {
      return titleValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    final amountValidation = validateAmount(expense.amount);
    if (amountValidation.isLeft()) {
      return amountValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    final dateValidation = validateDate(expense.expenseDate);
    if (dateValidation.isLeft()) {
      return dateValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    return Right(expense);
  }

  /// Validates complete expense for updating
  Either<Failure, Expense> validateForUpdate(Expense expense) {
    final titleValidation = validateTitle(expense.title);
    if (titleValidation.isLeft()) {
      return titleValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    final amountValidation = validateAmount(expense.amount);
    if (amountValidation.isLeft()) {
      return amountValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    return Right(expense);
  }
}
