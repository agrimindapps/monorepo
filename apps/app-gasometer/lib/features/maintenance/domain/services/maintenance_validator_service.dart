import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../entities/maintenance_entity.dart';

/// Serviço especializado para validação de campos de manutenção
class MaintenanceValidatorService {
  factory MaintenanceValidatorService() => _instance;
  MaintenanceValidatorService._internal();
  static final MaintenanceValidatorService _instance = MaintenanceValidatorService._internal();

  /// Valida tipo de manutenção
  String? validateType(MaintenanceType? value) {
    if (value == null) {
      return 'Tipo de manutenção é obrigatório';
    }
    return null;
  }

  /// Valida título/nome da manutenção
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }

    final trimmed = value.trim();
    
    if (trimmed.length < 3) {
      return 'Título muito curto (mínimo 3 caracteres)';
    }

    if (trimmed.length > 100) {
      return 'Título muito longo (máximo 100 caracteres)';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)]+$').hasMatch(trimmed)) {
      return 'Caracteres inválidos no título';
    }

    return null;
  }

  /// Valida descrição da manutenção
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }

    final trimmed = value.trim();
    
    if (trimmed.length < 5) {
      return 'Descrição muito curta (mínimo 5 caracteres)';
    }

    if (trimmed.length > 500) {
      return 'Descrição muito longa (máximo 500 caracteres)';
    }

    return null;
  }

  /// Valida valor da manutenção
  String? validateCost(String? value, {MaintenanceType? type}) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor é obrigatório';
    }

    final cleanValue = value
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    final cost = double.tryParse(cleanValue);

    if (cost == null) {
      return 'Valor inválido';
    }

    if (cost <= 0) {
      return 'Valor deve ser maior que zero';
    }

    if (cost > 999999.99) {
      return 'Valor muito alto';
    }
    if (type != null) {
      final validationError = _validateCostByType(cost, type);
      if (validationError != null) return validationError;
    }

    return null;
  }

  /// Valida odômetro com contexto do veículo
  String? validateOdometer(String? value, {
    double? currentOdometer,
    double? initialOdometer,
    double? lastMaintenanceOdometer,
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
    if (initialOdometer != null && odometer < initialOdometer) {
      return 'Odômetro não pode ser menor que o inicial (${initialOdometer.toStringAsFixed(0)} km)';
    }
    if (currentOdometer != null && odometer < currentOdometer - 5000) {
      return 'Odômetro muito abaixo do atual';
    }
    if (lastMaintenanceOdometer != null) {
      if (odometer < lastMaintenanceOdometer) {
        return 'Odômetro menor que a última manutenção';
      }
      if (odometer - lastMaintenanceOdometer > 50000) {
        return 'Diferença muito grande desde a última manutenção';
      }
    }

    return null;
  }

  /// Valida data da manutenção
  String? validateServiceDate(DateTime? date, {MaintenanceType? type}) {
    if (date == null) {
      return 'Data é obrigatória';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAfter(today)) {
      return 'Data não pode ser futura';
    }
    if ((type == MaintenanceType.preventive || type == MaintenanceType.inspection)) {
      final twoYearsAgo = today.subtract(const Duration(days: 365 * 2));
      if (selectedDate.isBefore(twoYearsAgo)) {
        return 'Data muito antiga para este tipo de manutenção';
      }
    } else {
      final fiveYearsAgo = today.subtract(const Duration(days: 365 * 5));
      if (selectedDate.isBefore(fiveYearsAgo)) {
        return 'Data muito antiga (máximo 5 anos)';
      }
    }

    return null;
  }

  /// Valida data da próxima manutenção
  String? validateNextServiceDate(DateTime? date, DateTime serviceDate) {
    if (date == null) return null; // Opcional
    
    if (date.isBefore(serviceDate)) {
      return 'Data da próxima manutenção deve ser posterior à atual';
    }

    final maxFuture = serviceDate.add(const Duration(days: 365 * 3)); // 3 anos max
    if (date.isAfter(maxFuture)) {
      return 'Data muito distante (máximo 3 anos)';
    }

    return null;
  }

  /// Valida odômetro da próxima manutenção
  String? validateNextServiceOdometer(String? value, double currentOdometer) {
    if (value == null || value.trim().isEmpty) return null; // Opcional

    final cleanValue = value.replaceAll(',', '.');
    final nextOdometer = double.tryParse(cleanValue);

    if (nextOdometer == null) {
      return 'Valor inválido';
    }

    if (nextOdometer <= currentOdometer) {
      return 'Deve ser maior que o odômetro atual';
    }

    if (nextOdometer - currentOdometer > 100000) {
      return 'Intervalo muito longo (máximo 100.000 km)';
    }

    return null;
  }

  /// Valida nome da oficina
  String? validateWorkshopName(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Opcional

    final trimmed = value.trim();
    
    if (trimmed.length < 2) {
      return 'Nome muito curto';
    }
    
    if (trimmed.length > 100) {
      return 'Nome muito longo';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)\/&]+$').hasMatch(trimmed)) {
      return 'Caracteres inválidos no nome';
    }

    return null;
  }

  /// Valida telefone
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Opcional
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    if (cleaned.length == 11 && !cleaned.startsWith(RegExp(r'[1-9][1-9]9'))) {
      return 'Formato de celular inválido';
    }
    
    if (cleaned.length == 10 && !cleaned.startsWith(RegExp(r'[1-9][1-9]'))) {
      return 'Formato de telefone inválido';
    }

    return null;
  }

  /// Valida endereço da oficina
  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Opcional
    
    final trimmed = value.trim();
    
    if (trimmed.length < 10) {
      return 'Endereço muito curto';
    }
    
    if (trimmed.length > 200) {
      return 'Endereço muito longo';
    }

    return null;
  }

  /// Valida observações
  String? validateNotes(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length > 1000) {
        return 'Observação muito longa (máximo 1000 caracteres)';
      }
    }
    return null;
  }

  /// Validação contextual completa do formulário
  Map<String, String> validateCompleteForm({
    required MaintenanceType? type,
    required String? title,
    required String? description,
    required String? cost,
    required String? odometer,
    required DateTime? serviceDate,
    String? workshopName,
    String? workshopPhone,
    String? workshopAddress,
    DateTime? nextServiceDate,
    String? nextServiceOdometer,
    String? notes,
    VehicleEntity? vehicle,
    double? lastMaintenanceOdometer,
  }) {
    final errors = <String, String>{};
    final typeError = validateType(type);
    if (typeError != null) errors['type'] = typeError;

    final titleError = validateTitle(title);
    if (titleError != null) errors['title'] = titleError;

    final descriptionError = validateDescription(description);
    if (descriptionError != null) errors['description'] = descriptionError;

    final costError = validateCost(cost, type: type);
    if (costError != null) errors['cost'] = costError;

    final odometerError = validateOdometer(
      odometer,
      currentOdometer: vehicle?.currentOdometer,
      lastMaintenanceOdometer: lastMaintenanceOdometer,
    );
    if (odometerError != null) errors['odometer'] = odometerError;

    final dateError = validateServiceDate(serviceDate, type: type);
    if (dateError != null) errors['serviceDate'] = dateError;
    final workshopNameError = validateWorkshopName(workshopName);
    if (workshopNameError != null) errors['workshopName'] = workshopNameError;

    final phoneError = validatePhone(workshopPhone);
    if (phoneError != null) errors['workshopPhone'] = phoneError;

    final addressError = validateAddress(workshopAddress);
    if (addressError != null) errors['workshopAddress'] = addressError;

    final notesError = validateNotes(notes);
    if (notesError != null) errors['notes'] = notesError;
    if (nextServiceDate != null && serviceDate != null) {
      final nextDateError = validateNextServiceDate(nextServiceDate, serviceDate);
      if (nextDateError != null) errors['nextServiceDate'] = nextDateError;
    }

    if (nextServiceOdometer != null && odometer != null) {
      final currentOdo = double.tryParse(odometer.replaceAll(',', '.')) ?? 0.0;
      final nextOdoError = validateNextServiceOdometer(nextServiceOdometer, currentOdo);
      if (nextOdoError != null) errors['nextServiceOdometer'] = nextOdoError;
    }

    return errors;
  }

  /// Validação específica por tipo de manutenção
  String? _validateCostByType(double cost, MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        if (cost > 5000.0) {
          return 'Valor alto para manutenção preventiva (máximo esperado: R\$ 5.000)';
        }
        if (cost < 50.0) {
          return 'Valor baixo para manutenção preventiva (mínimo esperado: R\$ 50)';
        }
        break;
      
      case MaintenanceType.corrective:
        if (cost > 15000.0) {
          return 'Valor muito alto para manutenção corretiva';
        }
        break;
      
      case MaintenanceType.inspection:
        if (cost > 1000.0) {
          return 'Valor alto para revisão (máximo esperado: R\$ 1.000)';
        }
        if (cost < 100.0) {
          return 'Valor baixo para revisão (mínimo esperado: R\$ 100)';
        }
        break;
      
      case MaintenanceType.emergency:
        if (cost > 20000.0) {
          return 'Valor muito alto para manutenção emergencial';
        }
        break;
    }
    
    return null;
  }

  /// Valida consistência de dados relacionados
  List<String> validateDataConsistency({
    required MaintenanceType type,
    required DateTime serviceDate,
    required double cost,
    List<MaintenanceEntity>? previousMaintenances,
  }) {
    final warnings = <String>[];
    if (previousMaintenances != null) {
      final sameDate = previousMaintenances.where((maintenance) {
        return maintenance.type == type &&
               maintenance.serviceDate.day == serviceDate.day &&
               maintenance.serviceDate.month == serviceDate.month &&
               maintenance.serviceDate.year == serviceDate.year;
      });

      if (sameDate.isNotEmpty) {
        warnings.add('Já existe manutenção do tipo ${type.displayName} nesta data');
      }
      final sameType = previousMaintenances.where((m) => m.type == type);
      if (sameType.isNotEmpty) {
        final avgCost = sameType.fold<double>(0, (sum, m) => sum + m.cost) / sameType.length;
        if ((cost - avgCost).abs() / avgCost > 1.0) { // 100% de diferença
          warnings.add('Valor muito diferente da média para ${type.displayName}');
        }
      }
      final recentSameType = sameType.where((m) {
        final daysDiff = serviceDate.difference(m.serviceDate).inDays;
        return daysDiff >= 0 && daysDiff < 30; // Menos de 30 dias
      });

      if (recentSameType.isNotEmpty) {
        warnings.add('Manutenção do mesmo tipo realizada recentemente');
      }
    }

    return warnings;
  }

  /// Sugere tipo baseado na descrição/título
  MaintenanceType suggestTypeFromDescription(String description) {
    final descLower = description.toLowerCase();
    if (descLower.contains('prevent') || descLower.contains('troca') || 
        descLower.contains('filtro') || descLower.contains('óleo') ||
        descLower.contains('oleo') || descLower.contains('pneu')) {
      return MaintenanceType.preventive;
    }
    if (descLower.contains('revisão') || descLower.contains('revisao') || 
        descLower.contains('inspeção') || descLower.contains('inspecao') ||
        descLower.contains('check')) {
      return MaintenanceType.inspection;
    }
    if (descLower.contains('emergência') || descLower.contains('emergencia') ||
        descLower.contains('urgente') || descLower.contains('guincho') ||
        descLower.contains('pane') || descLower.contains('socorro')) {
      return MaintenanceType.emergency;
    }
    if (descLower.contains('reparo') || descLower.contains('conserto') ||
        descLower.contains('quebra') || descLower.contains('defeito') ||
        descLower.contains('problema') || descLower.contains('falha')) {
      return MaintenanceType.corrective;
    }
    return MaintenanceType.preventive;
  }
}