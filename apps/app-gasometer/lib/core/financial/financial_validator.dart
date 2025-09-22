/// Financial Data Validator for GasOMeter
/// Provides validation for monetary values and financial data integrity
import 'package:core/core.dart';

import '../../features/expenses/data/models/expense_model.dart';
import '../../features/fuel/data/models/fuel_supply_model.dart';

/// Result class for financial validation
class FinancialValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const FinancialValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory FinancialValidationResult.valid() {
    return const FinancialValidationResult(isValid: true);
  }

  factory FinancialValidationResult.invalid(List<String> errors, {List<String> warnings = const []}) {
    return FinancialValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Get formatted error message
  String get errorMessage => errors.join('; ');

  /// Get formatted warning message
  String get warningMessage => warnings.join('; ');

  /// Check if has warnings (even if valid)
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Financial Data Validator
class FinancialValidator {
  static const double _maxReasonableValue = 100000.0; // R$ 100,000
  static const double _maxReasonableLiters = 500.0; // 500 liters
  static const double _maxReasonableOdometer = 10000000.0; // 10M km
  static const double _minPricePerLiter = 0.50; // R$ 0.50
  static const double _maxPricePerLiter = 50.0; // R$ 50.00

  /// Validate FuelSupplyModel before sync
  static FinancialValidationResult validateFuelSupply(FuelSupplyModel fuel) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required fields validation
    if (fuel.vehicleId.isEmpty) {
      errors.add('Veículo é obrigatório');
    }

    if (fuel.date <= 0) {
      errors.add('Data é obrigatória');
    } else {
      final fuelDate = DateTime.fromMillisecondsSinceEpoch(fuel.date);
      final now = DateTime.now();

      // Check if date is in future
      if (fuelDate.isAfter(now.add(const Duration(days: 1)))) {
        errors.add('Data não pode ser no futuro');
      }

      // Check if date is too old (more than 10 years)
      if (fuelDate.isBefore(now.subtract(const Duration(days: 3650)))) {
        warnings.add('Data muito antiga (mais de 10 anos)');
      }
    }

    // Monetary values validation
    if (fuel.totalPrice < 0) {
      errors.add('Valor total não pode ser negativo');
    } else if (fuel.totalPrice == 0) {
      errors.add('Valor total é obrigatório');
    } else if (fuel.totalPrice > _maxReasonableValue) {
      warnings.add('Valor total muito alto (R\$ ${fuel.totalPrice.toStringAsFixed(2)})');
    }

    // Liters validation
    if (fuel.liters < 0) {
      errors.add('Litros não pode ser negativo');
    } else if (fuel.liters == 0) {
      errors.add('Quantidade de litros é obrigatória');
    } else if (fuel.liters > _maxReasonableLiters) {
      warnings.add('Quantidade de litros muito alta (${fuel.liters.toStringAsFixed(2)}L)');
    }

    // Price per liter validation
    if (fuel.pricePerLiter < 0) {
      errors.add('Preço por litro não pode ser negativo');
    } else if (fuel.pricePerLiter == 0) {
      errors.add('Preço por litro é obrigatório');
    } else {
      if (fuel.pricePerLiter < _minPricePerLiter) {
        warnings.add('Preço por litro muito baixo (R\$ ${fuel.pricePerLiter.toStringAsFixed(2)})');
      }
      if (fuel.pricePerLiter > _maxPricePerLiter) {
        warnings.add('Preço por litro muito alto (R\$ ${fuel.pricePerLiter.toStringAsFixed(2)})');
      }
    }

    // Cross-validation: total price vs liters * price per liter
    if (fuel.liters > 0 && fuel.pricePerLiter > 0) {
      final calculatedTotal = fuel.liters * fuel.pricePerLiter;
      final difference = (fuel.totalPrice - calculatedTotal).abs();

      // Allow 1% tolerance for rounding
      if (difference > fuel.totalPrice * 0.01) {
        warnings.add('Inconsistência: Total calculado (R\$ ${calculatedTotal.toStringAsFixed(2)}) difere do total informado');
      }
    }

    // Odometer validation
    if (fuel.odometer < 0) {
      errors.add('Odômetro não pode ser negativo');
    } else if (fuel.odometer > _maxReasonableOdometer) {
      warnings.add('Valor do odômetro muito alto (${fuel.odometer.toStringAsFixed(0)} km)');
    }

    if (errors.isNotEmpty) {
      return FinancialValidationResult.invalid(errors, warnings: warnings);
    }

    return FinancialValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// Validate ExpenseModel before sync
  static FinancialValidationResult validateExpense(ExpenseModel expense) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required fields validation
    if (expense.veiculoId.isEmpty) {
      errors.add('Veículo é obrigatório');
    }

    if (expense.tipo.isEmpty) {
      errors.add('Tipo de despesa é obrigatório');
    }

    if (expense.descricao.isEmpty) {
      errors.add('Descrição é obrigatória');
    }

    if (expense.data <= 0) {
      errors.add('Data é obrigatória');
    } else {
      final expenseDate = DateTime.fromMillisecondsSinceEpoch(expense.data);
      final now = DateTime.now();

      // Check if date is in future
      if (expenseDate.isAfter(now.add(const Duration(days: 1)))) {
        errors.add('Data não pode ser no futuro');
      }

      // Check if date is too old (more than 10 years)
      if (expenseDate.isBefore(now.subtract(const Duration(days: 3650)))) {
        warnings.add('Data muito antiga (mais de 10 anos)');
      }
    }

    // Monetary values validation
    if (expense.valor < 0) {
      errors.add('Valor não pode ser negativo');
    } else if (expense.valor == 0) {
      errors.add('Valor é obrigatório');
    } else if (expense.valor > _maxReasonableValue) {
      warnings.add('Valor muito alto (R\$ ${expense.valor.toStringAsFixed(2)})');
    }

    // Odometer validation (if provided)
    if (expense.odometro < 0) {
      errors.add('Odômetro não pode ser negativo');
    } else if (expense.odometro > _maxReasonableOdometer) {
      warnings.add('Valor do odômetro muito alto (${expense.odometro.toStringAsFixed(0)} km)');
    }

    if (errors.isNotEmpty) {
      return FinancialValidationResult.invalid(errors, warnings: warnings);
    }

    return FinancialValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// Validate before sync operation (generic for any BaseSyncModel)
  static FinancialValidationResult validateForSync(BaseSyncEntity entity) {
    if (entity is FuelSupplyModel) {
      return validateFuelSupply(entity);
    } else if (entity is ExpenseModel) {
      return validateExpense(entity);
    }

    // For non-financial entities, just basic validation
    final errors = <String>[];

    if (entity.id.isEmpty) {
      errors.add('ID é obrigatório');
    }

    if (entity.userId?.isEmpty ?? true) {
      errors.add('Usuário é obrigatório para sincronização');
    }

    return errors.isEmpty
        ? FinancialValidationResult.valid()
        : FinancialValidationResult.invalid(errors);
  }

  /// Validate monetary value with custom limits
  static FinancialValidationResult validateMonetaryValue(
    double value, {
    required String fieldName,
    double? minValue,
    double? maxValue,
    bool allowZero = false,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value < 0) {
      errors.add('$fieldName não pode ser negativo');
    }

    if (!allowZero && value == 0) {
      errors.add('$fieldName é obrigatório');
    }

    if (minValue != null && value < minValue) {
      warnings.add('$fieldName muito baixo (${value.toStringAsFixed(2)})');
    }

    if (maxValue != null && value > maxValue) {
      warnings.add('$fieldName muito alto (${value.toStringAsFixed(2)})');
    }

    return errors.isEmpty
        ? FinancialValidationResult(isValid: true, warnings: warnings)
        : FinancialValidationResult.invalid(errors, warnings: warnings);
  }

  /// Check if entity is financial data (FuelSupply or Expense)
  static bool isFinancialData(BaseSyncEntity entity) {
    return entity is FuelSupplyModel || entity is ExpenseModel;
  }

  /// Get estimated importance level for financial data
  static int getFinancialImportanceLevel(BaseSyncEntity entity) {
    if (entity is FuelSupplyModel) {
      // Higher importance for expensive fuel purchases
      if (entity.totalPrice > 500) return 3; // High
      if (entity.totalPrice > 200) return 2; // Medium
      return 1; // Low
    }

    if (entity is ExpenseModel) {
      // Higher importance for expensive maintenance
      if (entity.valor > 1000) return 3; // High
      if (entity.valor > 500) return 2; // Medium
      return 1; // Low
    }

    return 0; // Not financial
  }
}