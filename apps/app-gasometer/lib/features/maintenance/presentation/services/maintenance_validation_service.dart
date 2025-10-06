import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for maintenance record validation
///
/// Follows SRP by handling only validation logic
class MaintenanceValidationService {
  /// Validates a complete maintenance record
  Map<String, String> validateMaintenance(MaintenanceEntity maintenance) {
    final errors = <String, String>{};
    if (maintenance.vehicleId.isEmpty) {
      errors['vehicleId'] = 'Veículo é obrigatório';
    }
    if (maintenance.title.trim().isEmpty) {
      errors['title'] = 'Título é obrigatório';
    } else if (maintenance.title.trim().length < 3) {
      errors['title'] = 'Título muito curto (mínimo 3 caracteres)';
    } else if (maintenance.title.trim().length > 100) {
      errors['title'] = 'Título muito longo (máximo 100 caracteres)';
    }
    if (maintenance.description.trim().isEmpty) {
      errors['description'] = 'Descrição é obrigatória';
    } else if (maintenance.description.trim().length < 5) {
      errors['description'] = 'Descrição muito curta (mínimo 5 caracteres)';
    } else if (maintenance.description.trim().length > 500) {
      errors['description'] = 'Descrição muito longa (máximo 500 caracteres)';
    }
    if (maintenance.cost < 0) {
      errors['cost'] = 'Custo não pode ser negativo';
    } else if (maintenance.cost > 999999.99) {
      errors['cost'] = 'Custo muito alto';
    }
    if (maintenance.odometer < 0) {
      errors['odometer'] = 'Odômetro não pode ser negativo';
    } else if (maintenance.odometer > 9999999) {
      errors['odometer'] = 'Valor muito alto';
    }
    final now = DateTime.now();
    if (maintenance.serviceDate.isAfter(now)) {
      errors['serviceDate'] = 'Data de serviço não pode ser futura';
    }
    if (maintenance.workshopName != null && maintenance.workshopName!.trim().isNotEmpty) {
      if (maintenance.workshopName!.trim().length < 2) {
        errors['workshopName'] = 'Nome da oficina muito curto';
      } else if (maintenance.workshopName!.trim().length > 100) {
        errors['workshopName'] = 'Nome da oficina muito longo';
      }
    }
    if (maintenance.workshopPhone != null && maintenance.workshopPhone!.trim().isNotEmpty) {
      final cleanPhone = maintenance.workshopPhone!.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        errors['workshopPhone'] = 'Telefone inválido (10 ou 11 dígitos)';
      }
    }
    if (maintenance.workshopAddress != null && maintenance.workshopAddress!.trim().isNotEmpty) {
      if (maintenance.workshopAddress!.trim().length < 5) {
        errors['workshopAddress'] = 'Endereço muito curto';
      } else if (maintenance.workshopAddress!.trim().length > 200) {
        errors['workshopAddress'] = 'Endereço muito longo';
      }
    }
    if (maintenance.nextServiceDate != null) {
      if (maintenance.nextServiceDate!.isBefore(maintenance.serviceDate)) {
        errors['nextServiceDate'] = 'Próxima manutenção deve ser após a data de serviço';
      }
    }
    if (maintenance.nextServiceOdometer != null) {
      if (maintenance.nextServiceOdometer! < maintenance.odometer) {
        errors['nextServiceOdometer'] = 'Próximo odômetro deve ser maior que o atual';
      } else if (maintenance.nextServiceOdometer! > 9999999) {
        errors['nextServiceOdometer'] = 'Valor muito alto';
      }
    }
    if (maintenance.notes != null && maintenance.notes!.trim().isNotEmpty) {
      if (maintenance.notes!.trim().length > 1000) {
        errors['notes'] = 'Observações muito longas (máximo 1000 caracteres)';
      }
    }

    return errors;
  }

  /// Validates title
  String? validateTitle(String title) {
    if (title.trim().isEmpty) {
      return 'Título é obrigatório';
    } else if (title.trim().length < 3) {
      return 'Título muito curto (mínimo 3 caracteres)';
    } else if (title.trim().length > 100) {
      return 'Título muito longo (máximo 100 caracteres)';
    }
    return null;
  }

  /// Validates description
  String? validateDescription(String description) {
    if (description.trim().isEmpty) {
      return 'Descrição é obrigatória';
    } else if (description.trim().length < 5) {
      return 'Descrição muito curta (mínimo 5 caracteres)';
    } else if (description.trim().length > 500) {
      return 'Descrição muito longa (máximo 500 caracteres)';
    }
    return null;
  }

  /// Validates cost
  String? validateCost(double cost) {
    if (cost < 0) {
      return 'Custo não pode ser negativo';
    } else if (cost > 999999.99) {
      return 'Custo muito alto';
    }
    return null;
  }

  /// Validates odometer
  String? validateOdometer(double odometer) {
    if (odometer < 0) {
      return 'Odômetro não pode ser negativo';
    } else if (odometer > 9999999) {
      return 'Valor muito alto';
    }
    return null;
  }

  /// Validates service date
  String? validateServiceDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Data não pode ser futura';
    }
    return null;
  }

  /// Validates next service configuration
  String? validateNextService({
    DateTime? nextServiceDate,
    double? nextServiceOdometer,
    required DateTime serviceDate,
    required double currentOdometer,
  }) {
    if (nextServiceDate != null) {
      if (nextServiceDate.isBefore(serviceDate)) {
        return 'Próxima manutenção deve ser após a data de serviço';
      }
    }

    if (nextServiceOdometer != null) {
      if (nextServiceOdometer < currentOdometer) {
        return 'Próximo odômetro deve ser maior que o atual';
      } else if (nextServiceOdometer > 9999999) {
        return 'Valor muito alto';
      }
    }

    return null;
  }

  /// Validates workshop phone
  String? validateWorkshopPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Telefone inválido (deve ter 10 ou 11 dígitos)';
    }

    return null;
  }

  /// Checks if maintenance is duplicate
  bool isDuplicate(
    MaintenanceEntity maintenance,
    List<MaintenanceEntity> existingMaintenances,
  ) {
    return existingMaintenances.any((existing) {
      if (existing.id == maintenance.id) return false; // Same record
      final sameVehicle = existing.vehicleId == maintenance.vehicleId;
      final sameDate = existing.serviceDate.difference(maintenance.serviceDate).inHours.abs() < 24;
      final sameOdometer = (existing.odometer - maintenance.odometer).abs() < 10;

      return sameVehicle && sameDate && sameOdometer;
    });
  }

  /// Validates if odometer is consistent with vehicle history
  bool isOdometerConsistent(
    double odometer,
    String vehicleId,
    List<MaintenanceEntity> existingMaintenances,
  ) {
    final vehicleMaintenances = existingMaintenances
        .where((m) => m.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    if (vehicleMaintenances.isEmpty) return true;

    final latestMaintenance = vehicleMaintenances.last;
    if (odometer < latestMaintenance.odometer) {
      return false;
    }

    return true;
  }

  /// Validates if next service is overdue
  bool isNextServiceOverdue(MaintenanceEntity maintenance) {
    if (maintenance.nextServiceDate == null) return false;

    final now = DateTime.now();
    return maintenance.nextServiceDate!.isBefore(now);
  }

  /// Calculates recommended next service date based on type
  DateTime calculateRecommendedNextServiceDate(
    MaintenanceType type,
    DateTime serviceDate,
  ) {
    switch (type) {
      case MaintenanceType.preventive:
        return serviceDate.add(const Duration(days: 180)); // 6 months
      case MaintenanceType.inspection:
        return serviceDate.add(const Duration(days: 365)); // 1 year
      case MaintenanceType.corrective:
      case MaintenanceType.emergency:
        return serviceDate.add(const Duration(days: 30)); // 1 month follow-up
    }
  }

  /// Calculates recommended next service odometer based on type
  double calculateRecommendedNextServiceOdometer(
    MaintenanceType type,
    double currentOdometer,
  ) {
    switch (type) {
      case MaintenanceType.preventive:
        return currentOdometer + 10000; // Every 10,000 km
      case MaintenanceType.inspection:
        return currentOdometer + 20000; // Every 20,000 km
      case MaintenanceType.corrective:
      case MaintenanceType.emergency:
        return currentOdometer + 5000; // Follow-up at 5,000 km
    }
  }

  /// Validates if maintenance cost is reasonable for type
  bool isCostReasonable(MaintenanceType type, double cost) {
    switch (type) {
      case MaintenanceType.preventive:
        return cost >= 50 && cost <= 5000;
      case MaintenanceType.corrective:
        return cost >= 100 && cost <= 10000;
      case MaintenanceType.inspection:
        return cost >= 50 && cost <= 2000;
      case MaintenanceType.emergency:
        return cost >= 100 && cost <= 20000;
    }
  }
}
