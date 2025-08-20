import '../entities/expense_entity.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';

/// Serviço especializado para validação contextual de campos de despesas
class ExpenseValidatorService {
  static final ExpenseValidatorService _instance = ExpenseValidatorService._internal();
  factory ExpenseValidatorService() => _instance;
  ExpenseValidatorService._internal();

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
  String? validateOdometer(String? value, {
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

  /// Validação específica por tipo de despesa
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
        if (amount > 1000.0) {
          return 'Valor alto para documentação (máximo esperado: R\$ 1.000)';
        }
        break;
      
      case ExpenseType.other:
        // Sem validações específicas para "Outro"
        break;
    }
    
    return null;
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
        warnings.add('Já existe despesa do tipo ${expenseType.displayName} nesta data');
      }

      // Verificar padrões suspeitos de valor
      if (expenseType.isRecurring) {
        final sameType = previousExpenses.where((expense) => expense.type == expenseType);
        if (sameType.isNotEmpty) {
          final avgAmount = sameType.fold<double>(0, (sum, expense) => sum + expense.amount) / sameType.length;
          if ((amount - avgAmount).abs() / avgAmount > 0.5) {
            warnings.add('Valor muito diferente da média para ${expenseType.displayName}');
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
    if (descLower.contains('lavag') || descLower.contains('lav car')) return ExpenseType.carWash;
    if (descLower.contains('multa') || descLower.contains('infra')) return ExpenseType.fine;
    if (descLower.contains('pedágio') || descLower.contains('pedagio')) return ExpenseType.toll;
    if (descLower.contains('licen')) return ExpenseType.licensing;
    if (descLower.contains('acess') || descLower.contains('equip')) return ExpenseType.accessories;
    if (descLower.contains('document') || descLower.contains('papel')) return ExpenseType.documentation;
    
    return ExpenseType.other;
  }
}