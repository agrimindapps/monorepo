import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/expense_constants.dart';
import '../entities/expense_entity.dart';
import 'expense_analyzer.dart';
import 'expense_form_validator.dart';
import 'expense_validation_types.dart';

export 'expense_analyzer.dart';
export 'expense_form_validator.dart';
export 'expense_validation_types.dart';

/// Serviço avançado para validação contextual de registros de despesas
///
/// Este serviço é stateless e pode ser injetado como dependency normal.
/// Não utiliza singleton pattern pois não mantém estado interno.
///
/// Refatorado para delegar responsabilidades:
/// - Validação de formulário -> ExpenseFormValidator
/// - Análise de padrões -> ExpenseAnalyzer
/// - Tipos de dados -> ExpenseValidationTypes
class ExpenseValidationService {
  /// Cria uma nova instância do serviço de validação
  const ExpenseValidationService({
    this.formValidator = const ExpenseFormValidator(),
    this.analyzer = const ExpenseAnalyzer(),
  });

  final ExpenseFormValidator formValidator;
  final ExpenseAnalyzer analyzer;

  /// Valida consistência entre registros de despesas
  ValidationResult validateExpenseRecord(
    ExpenseEntity record,
    VehicleEntity vehicle,
    List<ExpenseEntity> previousExpenses,
  ) {
    final errors = <String, String>{};
    final warnings = <String, String>{};
    _validateVehicleCompatibility(record, vehicle, errors);
    _validateOdometerSequence(
      record,
      vehicle,
      previousExpenses,
      errors,
      warnings,
    );
    _validateValuePatterns(record, previousExpenses, warnings);
    _validateDuplicates(record, previousExpenses, errors, warnings);
    _validateRecurringExpenses(record, previousExpenses, warnings);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida compatibilidade entre registro e veículo
  void _validateVehicleCompatibility(
    ExpenseEntity record,
    VehicleEntity vehicle,
    Map<String, String> errors,
  ) {
    if (!vehicle.isActive) {
      errors['vehicle'] = 'Veículo está inativo';
    }
    // REMOVIDO: Validação que bloqueava odômetro menor que o atual
    // Agora permite lançamentos retroativos
  }

  /// Valida sequência lógica do odômetro
  void _validateOdometerSequence(
    ExpenseEntity record,
    VehicleEntity vehicle,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> errors,
    Map<String, String> warnings,
  ) {
    if (previousExpenses.isEmpty) return;
    final sortedExpenses = List<ExpenseEntity>.from(previousExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final lastExpense = sortedExpenses.first;
    
    // ALTERADO: Agora apenas avisa, não bloqueia lançamentos retroativos
    if (record.odometer < lastExpense.odometer) {
      warnings['odometer'] =
          'Lançamento retroativo: Odômetro menor que a última despesa (${lastExpense.odometer.toStringAsFixed(0)} km). Este registro não atualizará a quilometragem do veículo.';
    }
    
    if (record.odometer < vehicle.currentOdometer) {
      warnings['odometer'] =
          'Lançamento retroativo: Odômetro abaixo do atual (${vehicle.currentOdometer.toStringAsFixed(0)} km). Este registro não atualizará a quilometragem do veículo.';
      return;
    }
    
    final difference = record.odometer - lastExpense.odometer;
    final daysDifference =
        record.date.difference(lastExpense.date).inDays.abs();

    if (difference > ExpenseConstants.maxOdometerDifference) {
      warnings['odometer'] =
          'Diferença muito grande desde última despesa: ${difference.toStringAsFixed(0)} km';
    }
    if (daysDifference > 0 &&
        daysDifference < 30 &&
        difference / daysDifference > 300) {
      warnings['odometer'] =
          'Média diária muito alta: ${(difference / daysDifference).toStringAsFixed(0)} km/dia';
    }
  }

  /// Valida padrões de valor por tipo de despesa
  void _validateValuePatterns(
    ExpenseEntity record,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> warnings,
  ) {
    final sameType =
        previousExpenses
            .where(
              (expense) =>
                  expense.type == record.type && expense.id != record.id,
            )
            .toList();

    if (sameType.isEmpty) return;
    if (record.type.isRecurring && sameType.length >= 2) {
      final avgAmount =
          sameType.fold<double>(0, (sum, expense) => sum + expense.amount) /
          sameType.length;
      final variation = (record.amount - avgAmount).abs() / avgAmount;

      if (variation > ExpenseConstants.maxAmountVariationPercent) {
        final percentDiff = (variation * 100).toStringAsFixed(0);
        warnings['amount'] =
            'Valor ${record.amount > avgAmount ? 'acima' : 'abaixo'} da média ($percentDiff% de diferença)';
      }
    }
    final typeProperties = record.type.properties;
    if (typeProperties.maxExpectedValue != null &&
        record.amount > typeProperties.maxExpectedValue!) {
      warnings['amount'] =
          'Valor alto para ${record.type.displayName} (esperado até R\$ ${typeProperties.maxExpectedValue!.toStringAsFixed(2)})';
    }
    if (typeProperties.minExpectedValue != null &&
        record.amount < typeProperties.minExpectedValue!) {
      warnings['amount'] =
          'Valor baixo para ${record.type.displayName} (esperado mínimo R\$ ${typeProperties.minExpectedValue!.toStringAsFixed(2)})';
    }
  }

  /// Valida duplicatas por data e tipo
  void _validateDuplicates(
    ExpenseEntity record,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> errors,
    Map<String, String> warnings,
  ) {
    final sameDate = previousExpenses.where(
      (expense) =>
          expense.type == record.type &&
          expense.date.day == record.date.day &&
          expense.date.month == record.date.month &&
          expense.date.year == record.date.year &&
          expense.id != record.id,
    );

    if (sameDate.isNotEmpty) {
      if (!record.type.isRecurring) {
        warnings['date'] =
            'Já existe despesa de ${record.type.displayName} nesta data';
      }
      final exactDuplicates = sameDate.where(
        (expense) =>
            (expense.amount - record.amount).abs() < 0.01 &&
            expense.description.toLowerCase() ==
                record.description.toLowerCase(),
      );

      if (exactDuplicates.isNotEmpty) {
        errors['duplicate'] = 'Possível despesa duplicada encontrada';
      }
    }
  }

  /// Valida frequência de despesas recorrentes
  void _validateRecurringExpenses(
    ExpenseEntity record,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> warnings,
  ) {
    if (!record.type.isRecurring) return;

    final sameType =
        previousExpenses
            .where(
              (expense) =>
                  expense.type == record.type && expense.id != record.id,
            )
            .toList();

    if (sameType.isEmpty) return;
    sameType.sort((a, b) => b.date.compareTo(a.date));
    final lastSameType = sameType.first;

    final monthsDifference = _calculateMonthsDifference(
      record.date,
      lastSameType.date,
    );
    switch (record.type) {
      case ExpenseType.insurance:
        if (monthsDifference < 11) {
          warnings['frequency'] = 'Seguro registrado há menos de 1 ano';
        }
        break;

      case ExpenseType.ipva:
        if (monthsDifference < 11) {
          warnings['frequency'] = 'IPVA registrado há menos de 1 ano';
        }
        break;

      case ExpenseType.licensing:
        if (monthsDifference < 11) {
          warnings['frequency'] = 'Licenciamento registrado há menos de 1 ano';
        }
        break;

      default:
        break;
    }
  }

  /// Valida consistência de dados relacionados
  List<String> validateDataConsistency({
    required ExpenseType expenseType,
    required DateTime date,
    required double amount,
    List<ExpenseEntity>? previousExpenses,
  }) {
    final warnings = <String>[];
    if (previousExpenses != null) {
      final sameDate = previousExpenses.where((expense) {
        return expense.type == expenseType &&
            expense.date.day == date.day &&
            expense.date.month == date.month &&
            expense.date.year == date.year;
      });

      if (sameDate.isNotEmpty) {
        warnings.add(
          'Já existe despesa do tipo ${expenseType.displayName} nesta data',
        );
      }
      if (expenseType.isRecurring) {
        final sameType = previousExpenses.where(
          (expense) => expense.type == expenseType,
        );
        if (sameType.isNotEmpty) {
          final avgAmount =
              sameType.fold<double>(0, (sum, expense) => sum + expense.amount) /
              sameType.length;
          if ((amount - avgAmount).abs() / avgAmount > 0.5) {
            warnings.add(
              'Valor muito diferente da média para ${expenseType.displayName}',
            );
          }
        }
      }
    }

    return warnings;
  }

  /// Calcula diferença em meses entre duas datas
  int _calculateMonthsDifference(DateTime date1, DateTime date2) {
    final months = (date1.year - date2.year) * 12 + (date1.month - date2.month);
    return months.abs();
  }

  // DELEGATED METHODS

  /// Análise de padrões de despesas para um veículo
  ExpensePatternAnalysis analyzeExpensePatterns(
    List<ExpenseEntity> expenses,
    VehicleEntity vehicle,
  ) {
    return analyzer.analyzeExpensePatterns(expenses, vehicle);
  }

  /// Validação contextual completa do formulário
  Map<String, String> validateCompleteForm({
    required ExpenseType? expenseType,
    required String? description,
    required String? amount,
    required String? odometer,
    required DateTime? date,
    String? location,
    String? notes,
    VehicleEntity? vehicle,
    double? lastExpenseOdometer,
  }) {
    return formValidator.validateCompleteForm(
      expenseType: expenseType,
      description: description,
      amount: amount,
      odometer: odometer,
      date: date,
      location: location,
      notes: notes,
      vehicle: vehicle,
      lastExpenseOdometer: lastExpenseOdometer,
    );
  }

  // Helper methods delegated to formValidator for convenience
  String? validateExpenseType(ExpenseType? value) =>
      formValidator.validateExpenseType(value);
  String? validateDescription(String? value) =>
      formValidator.validateDescription(value);
  String? validateAmount(String? value, {ExpenseType? expenseType}) =>
      formValidator.validateAmount(value, expenseType: expenseType);
  String? validateOdometer(
    String? value, {
    double? currentOdometer,
    double? initialOdometer,
    double? lastExpenseOdometer,
  }) => formValidator.validateOdometer(
    value,
    currentOdometer: currentOdometer,
    initialOdometer: initialOdometer,
    lastExpenseOdometer: lastExpenseOdometer,
  );
  String? validateDate(DateTime? date) => formValidator.validateDate(date);
  String? validateLocation(String? value) =>
      formValidator.validateLocation(value);
  String? validateNotes(String? value) => formValidator.validateNotes(value);
  ExpenseType suggestCategoryFromDescription(String description) =>
      formValidator.suggestCategoryFromDescription(description);
}
