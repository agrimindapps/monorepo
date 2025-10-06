import 'package:core/core.dart' show injectable;

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/expense_constants.dart';
import '../entities/expense_entity.dart';

/// Serviço avançado para validação contextual de registros de despesas
///
/// Este serviço é stateless e pode ser injetado como dependency normal.
/// Não utiliza singleton pattern pois não mantém estado interno.
@injectable
class ExpenseValidationService {
  /// Cria uma nova instância do serviço de validação
  const ExpenseValidationService();

  /// Valida consistência entre registros de despesas
  ValidationResult validateExpenseRecord(
    ExpenseEntity record,
    VehicleEntity vehicle,
    List<ExpenseEntity> previousExpenses,
  ) {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    // Validar compatibilidade com o veículo
    _validateVehicleCompatibility(record, vehicle, errors);

    // Validar sequência de odômetro
    _validateOdometerSequence(
      record,
      vehicle,
      previousExpenses,
      errors,
      warnings,
    );

    // Validar padrões de valor por tipo
    _validateValuePatterns(record, previousExpenses, warnings);

    // Validar duplicatas por data e tipo
    _validateDuplicates(record, previousExpenses, errors, warnings);

    // Validar frequência de despesas recorrentes
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
    // Verificar se o veículo está ativo
    if (!vehicle.isActive) {
      errors['vehicle'] = 'Veículo está inativo';
    }

    // Verificar se o odômetro não regrediu muito
    if (record.odometer < vehicle.currentOdometer - 1000) {
      errors['odometer'] =
          'Odômetro muito abaixo do atual do veículo (${vehicle.currentOdometer.toStringAsFixed(0)} km)';
    }
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

    // Ordenar por data para encontrar o registro mais próximo
    final sortedExpenses = List<ExpenseEntity>.from(previousExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final lastExpense = sortedExpenses.first;

    // Verificar se odômetro não regrediu
    if (record.odometer < lastExpense.odometer) {
      errors['odometer'] =
          'Odômetro menor que a última despesa (${lastExpense.odometer.toStringAsFixed(0)} km)';
      return;
    }

    // Verificar diferença suspeita
    final difference = record.odometer - lastExpense.odometer;
    final daysDifference =
        record.date.difference(lastExpense.date).inDays.abs();

    if (difference > ExpenseConstants.maxOdometerDifference) {
      warnings['odometer'] =
          'Diferença muito grande desde última despesa: ${difference.toStringAsFixed(0)} km';
    }

    // Alertar para rodagem muito alta em pouco tempo
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

    // Para despesas recorrentes, verificar se o valor está muito diferente da média
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

    // Verificar valores extremos por categoria
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
      // Para despesas não recorrentes, isso pode ser um erro
      if (!record.type.isRecurring) {
        warnings['date'] =
            'Já existe despesa de ${record.type.displayName} nesta data';
      }

      // Para despesas de mesmo tipo, valor e data, pode ser duplicata
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

    // Ordenar por data
    sameType.sort((a, b) => b.date.compareTo(a.date));
    final lastSameType = sameType.first;

    final monthsDifference = _calculateMonthsDifference(
      record.date,
      lastSameType.date,
    );

    // Alertas baseados no tipo de despesa
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

  /// Análise de padrões de despesas para um veículo
  ExpensePatternAnalysis analyzeExpensePatterns(
    List<ExpenseEntity> expenses,
    VehicleEntity vehicle,
  ) {
    if (expenses.isEmpty) {
      return ExpensePatternAnalysis.empty();
    }

    final sortedExpenses = List<ExpenseEntity>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calcular estatísticas gerais
    final totalAmount = sortedExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final averageAmount = totalAmount / sortedExpenses.length;

    // Agrupar por tipo
    final expensesByType = <ExpenseType, List<ExpenseEntity>>{};
    for (final expense in sortedExpenses) {
      expensesByType.putIfAbsent(expense.type, () => []).add(expense);
    }

    // Calcular gastos por tipo
    final expensesByTypeAmount = expensesByType.map(
      (type, expenses) =>
          MapEntry(type, expenses.fold<double>(0, (sum, e) => sum + e.amount)),
    );

    // Detectar anomalias
    final anomalies = _detectExpenseAnomalies(sortedExpenses);

    // Calcular tendências
    final trends = _calculateExpenseTrends(sortedExpenses);

    return ExpensePatternAnalysis(
      totalRecords: sortedExpenses.length,
      totalAmount: totalAmount,
      averageAmount: averageAmount,
      expensesByType: expensesByTypeAmount,
      anomalies: anomalies,
      trends: trends,
      lastExpense: sortedExpenses.last,
      firstExpense: sortedExpenses.first,
      period: sortedExpenses.last.date.difference(sortedExpenses.first.date),
    );
  }

  /// Detecta anomalias nos registros de despesas
  List<ExpenseAnomaly> _detectExpenseAnomalies(List<ExpenseEntity> expenses) {
    final anomalies = <ExpenseAnomaly>[];

    // Calcular médias por tipo
    final typeAverages = <ExpenseType, double>{};
    final typeGroups = <ExpenseType, List<ExpenseEntity>>{};

    for (final expense in expenses) {
      typeGroups.putIfAbsent(expense.type, () => []).add(expense);
    }

    typeGroups.forEach((type, expenses) {
      typeAverages[type] =
          expenses.fold<double>(0, (sum, e) => sum + e.amount) /
          expenses.length;
    });

    // Detectar outliers de valor
    for (final expense in expenses) {
      final average = typeAverages[expense.type]!;
      final deviation = (expense.amount - average).abs() / average;

      if (deviation > 1.0) {
        // Mais de 100% de desvio
        anomalies.add(
          ExpenseAnomaly(
            expenseId: expense.id,
            type: AnomalyType.valueOutlier,
            description:
                'Valor muito ${expense.amount > average ? 'alto' : 'baixo'} '
                'para ${expense.type.displayName} (${deviation.toStringAsFixed(1)}x da média)',
            severity:
                deviation > 2.0 ? AnomalySeverity.high : AnomalySeverity.medium,
          ),
        );
      }
    }

    // Detectar frequência anômala
    final recurringTypes = expenses.where((e) => e.type.isRecurring).toList();
    final frequencyMap = <ExpenseType, List<ExpenseEntity>>{};

    for (final expense in recurringTypes) {
      frequencyMap.putIfAbsent(expense.type, () => []).add(expense);
    }

    frequencyMap.forEach((type, typeExpenses) {
      if (typeExpenses.length < 2) return;

      typeExpenses.sort((a, b) => a.date.compareTo(b.date));

      for (int i = 1; i < typeExpenses.length; i++) {
        final monthsDiff = _calculateMonthsDifference(
          typeExpenses[i].date,
          typeExpenses[i - 1].date,
        );

        if (monthsDiff < 6) {
          // Menos de 6 meses entre despesas anuais
          anomalies.add(
            ExpenseAnomaly(
              expenseId: typeExpenses[i].id,
              type: AnomalyType.frequencyAnomaly,
              description:
                  'Despesa recorrente registrada muito cedo ($monthsDiff meses)',
              severity: AnomalySeverity.medium,
            ),
          );
        }
      }
    });

    return anomalies;
  }

  /// Calcula tendências de gastos
  Map<String, dynamic> _calculateExpenseTrends(List<ExpenseEntity> expenses) {
    if (expenses.length < 2) return {};

    // Agrupar por mês
    final monthlyTotals = <String, double>{};

    for (final expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    final months = monthlyTotals.keys.toList()..sort();
    if (months.length < 2) return {};

    // Calcular tendência (simples: comparar últimos 3 meses com 3 anteriores)
    final recentMonths =
        months.length >= 6
            ? months.sublist(months.length - 3)
            : months.sublist((months.length / 2).ceil());
    final olderMonths =
        months.length >= 6
            ? months.sublist(months.length - 6, months.length - 3)
            : months.sublist(0, (months.length / 2).floor());

    final recentAverage =
        recentMonths.fold<double>(
          0,
          (sum, month) => sum + monthlyTotals[month]!,
        ) /
        recentMonths.length;
    final olderAverage =
        olderMonths.fold<double>(
          0,
          (sum, month) => sum + monthlyTotals[month]!,
        ) /
        olderMonths.length;

    final trendPercentage =
        olderAverage > 0
            ? ((recentAverage - olderAverage) / olderAverage) * 100
            : 0;

    return {
      'trend':
          trendPercentage > 5
              ? 'increasing'
              : trendPercentage < -5
              ? 'decreasing'
              : 'stable',
      'trendPercentage': trendPercentage,
      'recentAverage': recentAverage,
      'olderAverage': olderAverage,
    };
  }

  /// Calcula diferença em meses entre duas datas
  int _calculateMonthsDifference(DateTime date1, DateTime date2) {
    final months = (date1.year - date2.year) * 12 + (date1.month - date2.month);
    return months.abs();
  }

  // ========================================================================
  // FORM VALIDATION METHODS (consolidated from ExpenseValidatorService)
  // ========================================================================

  /// Valida tipo de despesa
  String? validateExpenseType(ExpenseType? value) {
    if (value == null) {
      return 'Tipo de despesa é obrigatório';
    }
    return null;
  }

  /// Valida descrição da despesa
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Descrição muito curta (mínimo 3 caracteres)';
    }

    if (trimmed.length > 100) {
      return 'Descrição muito longa (máximo 100 caracteres)';
    }

    // Verificar caracteres válidos
    if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)]+$').hasMatch(trimmed)) {
      return 'Caracteres inválidos na descrição';
    }

    return null;
  }

  /// Valida valor da despesa
  String? validateAmount(String? value, {ExpenseType? expenseType}) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor é obrigatório';
    }

    final cleanValue = value
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return 'Valor inválido';
    }

    if (amount <= 0) {
      return 'Valor deve ser maior que zero';
    }

    if (amount > 999999.99) {
      return 'Valor muito alto';
    }

    // Validações contextuais por tipo de despesa
    if (expenseType != null) {
      final validationError = _validateAmountByType(amount, expenseType);
      if (validationError != null) return validationError;
    }

    return null;
  }

  /// Valida odômetro com contexto do veículo
  String? validateOdometer(
    String? value, {
    double? currentOdometer,
    double? initialOdometer,
    double? lastExpenseOdometer,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Odômetro é obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final odometer = double.tryParse(cleanValue);

    if (odometer == null) {
      return 'Valor inválido';
    }

    if (odometer < 0) {
      return 'Odômetro não pode ser negativo';
    }

    if (odometer > 9999999) {
      return 'Valor muito alto';
    }

    // Validação contextual com odômetro inicial do veículo
    if (initialOdometer != null && odometer < initialOdometer) {
      return 'Odômetro não pode ser menor que o inicial (${initialOdometer.toStringAsFixed(0)} km)';
    }

    // Validação contextual com odômetro atual
    if (currentOdometer != null && odometer < currentOdometer - 1000) {
      return 'Odômetro muito abaixo do atual';
    }

    // Validação com último registro de despesa
    if (lastExpenseOdometer != null) {
      if (odometer < lastExpenseOdometer) {
        return 'Odômetro menor que a última despesa';
      }

      // Alerta para diferença muito grande (mais de 5000km)
      if (odometer - lastExpenseOdometer > 5000) {
        return 'Diferença muito grande desde a última despesa';
      }
    }

    return null;
  }

  /// Valida data da despesa
  String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Data é obrigatória';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAfter(today)) {
      return 'Data não pode ser futura';
    }

    // Não permitir datas muito antigas (mais de 10 anos para despesas)
    final tenYearsAgo = today.subtract(const Duration(days: 365 * 10));
    if (selectedDate.isBefore(tenYearsAgo)) {
      return 'Data muito antiga (máximo 10 anos)';
    }

    return null;
  }

  /// Valida localização (opcional)
  String? validateLocation(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final trimmed = value.trim();

      if (trimmed.length < 2) {
        return 'Localização muito curta';
      }

      if (trimmed.length > 100) {
        return 'Localização muito longa';
      }

      // Verificar caracteres válidos para endereços
      if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)\/]+$').hasMatch(trimmed)) {
        return 'Caracteres inválidos na localização';
      }
    }
    return null;
  }

  /// Valida observações (opcional)
  String? validateNotes(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length > 300) {
        return 'Observação muito longa (máximo 300 caracteres)';
      }
    }
    return null;
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
    final errors = <String, String>{};

    // Validar tipo
    final typeError = validateExpenseType(expenseType);
    if (typeError != null) errors['expenseType'] = typeError;

    // Validar descrição
    final descriptionError = validateDescription(description);
    if (descriptionError != null) errors['description'] = descriptionError;

    // Validar valor
    final amountError = validateAmount(amount, expenseType: expenseType);
    if (amountError != null) errors['amount'] = amountError;

    // Validar odômetro
    final odometerError = validateOdometer(
      odometer,
      currentOdometer: vehicle?.currentOdometer,
      lastExpenseOdometer: lastExpenseOdometer,
    );
    if (odometerError != null) errors['odometer'] = odometerError;

    // Validar data
    final dateError = validateDate(date);
    if (dateError != null) errors['date'] = dateError;

    // Validar campos opcionais
    final locationError = validateLocation(location);
    if (locationError != null) errors['location'] = locationError;

    final notesError = validateNotes(notes);
    if (notesError != null) errors['notes'] = notesError;

    return errors;
  }

  /// Valida consistência de dados relacionados
  List<String> validateDataConsistency({
    required ExpenseType expenseType,
    required DateTime date,
    required double amount,
    List<ExpenseEntity>? previousExpenses,
  }) {
    final warnings = <String>[];

    // Verificar despesas duplicadas no mesmo dia
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

      // Verificar padrões suspeitos de valor
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

  /// Sugere categoria baseada na descrição
  ExpenseType suggestCategoryFromDescription(String description) {
    final descLower = description.toLowerCase();

    if (descLower.contains('seguro')) return ExpenseType.insurance;
    if (descLower.contains('ipva')) return ExpenseType.ipva;
    if (descLower.contains('estacion')) return ExpenseType.parking;
    if (descLower.contains('lavag') || descLower.contains('lav car')) {
      return ExpenseType.carWash;
    }
    if (descLower.contains('multa') || descLower.contains('infra')) {
      return ExpenseType.fine;
    }
    if (descLower.contains('pedágio') || descLower.contains('pedagio')) {
      return ExpenseType.toll;
    }
    if (descLower.contains('licen')) return ExpenseType.licensing;
    if (descLower.contains('acess') || descLower.contains('equip')) {
      return ExpenseType.accessories;
    }
    if (descLower.contains('document') || descLower.contains('papel')) {
      return ExpenseType.documentation;
    }

    return ExpenseType.other;
  }

  /// Validação específica por tipo de despesa (private method)
  String? _validateAmountByType(double amount, ExpenseType expenseType) {
    switch (expenseType) {
      case ExpenseType.fuel:
        if (amount > 500.0) {
          return 'Valor alto para combustível (máximo esperado: R\$ 500)';
        }
        break;

      case ExpenseType.maintenance:
        if (amount > 2000.0) {
          return 'Valor alto para manutenção (máximo esperado: R\$ 2000)';
        }
        break;

      case ExpenseType.parking:
        if (amount > 50.0) {
          return 'Valor alto para estacionamento (máximo esperado: R\$ 50)';
        }
        break;

      case ExpenseType.carWash:
        if (amount > 100.0) {
          return 'Valor alto para lavagem (máximo esperado: R\$ 100)';
        }
        break;

      case ExpenseType.toll:
        if (amount > 200.0) {
          return 'Valor alto para pedágio (máximo esperado: R\$ 200)';
        }
        break;

      case ExpenseType.fine:
        if (amount > 2000.0) {
          return 'Valor muito alto para multa';
        }
        break;

      case ExpenseType.insurance:
        if (amount < 100.0) {
          return 'Valor baixo para seguro (mínimo esperado: R\$ 100)';
        }
        if (amount > 10000.0) {
          return 'Valor muito alto para seguro';
        }
        break;

      case ExpenseType.ipva:
        if (amount < 50.0) {
          return 'Valor baixo para IPVA (mínimo esperado: R\$ 50)';
        }
        if (amount > 15000.0) {
          return 'Valor muito alto para IPVA';
        }
        break;

      case ExpenseType.licensing:
        if (amount > 500.0) {
          return 'Valor alto para licenciamento (máximo esperado: R\$ 500)';
        }
        break;

      case ExpenseType.accessories:
        if (amount > 5000.0) {
          return 'Valor muito alto para acessórios';
        }
        break;

      case ExpenseType.documentation:
        if (amount > ExpenseConstants.documentationMaxExpected) {
          return 'Valor alto para documentação (máximo esperado: R\$ ${ExpenseConstants.documentationMaxExpected.toStringAsFixed(0)})';
        }
        break;

      case ExpenseType.other:
        // Sem validações específicas para "Outro"
        break;
    }

    return null;
  }
}

/// Resultado de validação de despesa
class ValidationResult {
  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Análise de padrões de despesas
class ExpensePatternAnalysis {
  ExpensePatternAnalysis({
    required this.totalRecords,
    required this.totalAmount,
    required this.averageAmount,
    required this.expensesByType,
    required this.anomalies,
    required this.trends,
    required this.lastExpense,
    required this.firstExpense,
    required this.period,
  });

  factory ExpensePatternAnalysis.empty() {
    final now = DateTime.now();
    final dummyExpense = ExpenseEntity(
      id: '',
      userId: '',
      vehicleId: '',
      type: ExpenseType.other,
      description: '',
      amount: 0,
      date: now,
      odometer: 0,
      createdAt: now,
      updatedAt: now,
    );

    return ExpensePatternAnalysis(
      totalRecords: 0,
      totalAmount: 0,
      averageAmount: 0,
      expensesByType: {},
      anomalies: [],
      trends: {},
      lastExpense: dummyExpense,
      firstExpense: dummyExpense,
      period: Duration.zero,
    );
  }
  final int totalRecords;
  final double totalAmount;
  final double averageAmount;
  final Map<ExpenseType, double> expensesByType;
  final List<ExpenseAnomaly> anomalies;
  final Map<String, dynamic> trends;
  final ExpenseEntity lastExpense;
  final ExpenseEntity firstExpense;
  final Duration period;

  bool get hasAnomalies => anomalies.isNotEmpty;
  String get totalAmountFormatted => 'R\$ ${totalAmount.toStringAsFixed(2)}';
  String get averageAmountFormatted =>
      'R\$ ${averageAmount.toStringAsFixed(2)}';
  int get periodInDays => period.inDays;
  double get monthlyAverage =>
      periodInDays > 0 ? totalAmount / (periodInDays / 30.44) : 0;
}

/// Anomalia detectada em despesas
class ExpenseAnomaly {
  ExpenseAnomaly({
    required this.expenseId,
    required this.type,
    required this.description,
    required this.severity,
  });
  final String expenseId;
  final AnomalyType type;
  final String description;
  final AnomalySeverity severity;
}

enum AnomalyType {
  valueOutlier,
  frequencyAnomaly,
  sequenceError,
  duplicateExpense,
}

enum AnomalySeverity { low, medium, high, critical }
