import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for validating maintenance records
/// Follows SRP by handling only validation logic
@lazySingleton
class MaintenanceRecordValidator {
  /// Validate a complete maintenance record
  MaintenanceValidationResult validateRecord(MaintenanceEntity maintenance) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate vehicle ID
    if (maintenance.vehicleId.isEmpty) {
      errors.add('ID do veículo é obrigatório');
    }

    // Validate title
    if (maintenance.title.isEmpty) {
      errors.add('Título da manutenção é obrigatório');
    }

    // Validate description
    if (maintenance.description.isEmpty) {
      warnings.add('Descrição não fornecida');
    }

    // Validate cost
    final costValidation = validateCost(maintenance.cost);
    if (!costValidation.isValid) {
      errors.addAll(costValidation.errors);
    }
    warnings.addAll(costValidation.warnings);

    // Validate odometer
    final odometerValidation = validateOdometer(maintenance.odometer);
    if (!odometerValidation.isValid) {
      errors.addAll(odometerValidation.errors);
    }
    warnings.addAll(odometerValidation.warnings);

    // Validate service date
    final dateValidation = validateServiceDate(maintenance.serviceDate);
    if (!dateValidation.isValid) {
      errors.addAll(dateValidation.errors);
    }
    warnings.addAll(dateValidation.warnings);

    // Validate next service date if provided
    if (maintenance.nextServiceDate != null) {
      final nextDateValidation = validateNextServiceDate(
        maintenance.serviceDate,
        maintenance.nextServiceDate!,
      );
      if (!nextDateValidation.isValid) {
        errors.addAll(nextDateValidation.errors);
      }
      warnings.addAll(nextDateValidation.warnings);
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate maintenance cost
  MaintenanceValidationResult validateCost(double cost) {
    final errors = <String>[];
    final warnings = <String>[];

    if (cost < 0) {
      errors.add('Custo não pode ser negativo');
    }

    if (cost == 0) {
      warnings.add('Custo está zerado');
    }

    if (cost > 50000) {
      warnings.add('Custo muito alto (acima de R\$ 50.000)');
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate odometer reading
  MaintenanceValidationResult validateOdometer(double odometer) {
    final errors = <String>[];
    final warnings = <String>[];

    if (odometer < 0) {
      errors.add('Odômetro não pode ser negativo');
    }

    if (odometer > 1000000) {
      warnings.add('Leitura de odômetro muito alta (acima de 1.000.000 km)');
    }

    if (odometer < 100 && odometer > 0) {
      warnings.add('Leitura de odômetro muito baixa (abaixo de 100 km)');
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate service date
  MaintenanceValidationResult validateServiceDate(DateTime serviceDate) {
    final errors = <String>[];
    final warnings = <String>[];
    final now = DateTime.now();

    if (serviceDate.isAfter(now.add(const Duration(days: 1)))) {
      errors.add('Data de serviço não pode ser no futuro');
    }

    final yearsAgo = now.difference(serviceDate).inDays / 365;
    if (yearsAgo > 10) {
      warnings.add('Data de serviço muito antiga (mais de 10 anos atrás)');
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate next service date
  MaintenanceValidationResult validateNextServiceDate(
    DateTime serviceDate,
    DateTime nextServiceDate,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (nextServiceDate.isBefore(serviceDate)) {
      errors.add('Próxima data de serviço não pode ser antes da data atual');
    }

    final daysBetween = nextServiceDate.difference(serviceDate).inDays;

    if (daysBetween < 7) {
      warnings.add('Próximo serviço está muito próximo (menos de 1 semana)');
    }

    if (daysBetween > 730) {
      warnings.add('Próximo serviço está muito distante (mais de 2 anos)');
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate odometer sequence (must be increasing)
  MaintenanceValidationResult validateOdometerSequence(
    List<MaintenanceEntity> previousRecords,
    MaintenanceEntity newRecord,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (previousRecords.isEmpty) {
      return MaintenanceValidationResult(
        isValid: true,
        errors: errors,
        warnings: warnings,
      );
    }

    // Get records for the same vehicle
    final vehicleRecords = previousRecords
        .where((r) => r.vehicleId == newRecord.vehicleId)
        .toList()
      ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    if (vehicleRecords.isEmpty) {
      return MaintenanceValidationResult(
        isValid: true,
        errors: errors,
        warnings: warnings,
      );
    }

    // Find records before and after the new record
    final recordsBefore = vehicleRecords
        .where((r) => r.serviceDate.isBefore(newRecord.serviceDate))
        .toList();

    final recordsAfter = vehicleRecords
        .where((r) => r.serviceDate.isAfter(newRecord.serviceDate))
        .toList();

    // Check odometer is greater than previous records
    if (recordsBefore.isNotEmpty) {
      final lastBefore = recordsBefore.last;
      if (newRecord.odometer < lastBefore.odometer) {
        errors.add(
          'Odômetro (${newRecord.odometer.toStringAsFixed(0)} km) não pode ser menor que '
          'registro anterior (${lastBefore.odometer.toStringAsFixed(0)} km)',
        );
      }
    }

    // Check odometer is less than following records
    if (recordsAfter.isNotEmpty) {
      final firstAfter = recordsAfter.first;
      if (newRecord.odometer > firstAfter.odometer) {
        errors.add(
          'Odômetro (${newRecord.odometer.toStringAsFixed(0)} km) não pode ser maior que '
          'registro seguinte (${firstAfter.odometer.toStringAsFixed(0)} km)',
        );
      }
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Check for potential duplicate records
  List<MaintenanceEntity> findPotentialDuplicates(
    List<MaintenanceEntity> records,
    MaintenanceEntity newRecord,
  ) {
    return records.where((record) {
      // Same vehicle
      if (record.vehicleId != newRecord.vehicleId) return false;

      // Same type
      if (record.type != newRecord.type) return false;

      // Same date or very close (within 1 day)
      final timeDiff = record.serviceDate.difference(newRecord.serviceDate).abs();
      if (timeDiff.inDays > 1) return false;

      // Similar cost (within 10%)
      final costDiff = (record.cost - newRecord.cost).abs();
      final costTolerance = newRecord.cost * 0.1;
      if (costDiff > costTolerance && costDiff > 10) return false;

      return true;
    }).toList();
  }

  /// Validate workshop information
  MaintenanceValidationResult validateWorkshopInfo(
    String? workshopName,
    String? workshopPhone,
    String? workshopAddress,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (workshopName == null || workshopName.isEmpty) {
      warnings.add('Nome da oficina não fornecido');
    }

    if (workshopPhone != null && workshopPhone.isNotEmpty) {
      if (workshopPhone.length < 10) {
        errors.add('Telefone da oficina inválido (muito curto)');
      }
    }

    return MaintenanceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Check if maintenance is overdue
  bool isOverdue(MaintenanceEntity maintenance) {
    if (maintenance.nextServiceDate == null) return false;
    if (maintenance.status == MaintenanceStatus.completed) return false;

    return DateTime.now().isAfter(maintenance.nextServiceDate!);
  }

  /// Calculate days until next service
  int? daysUntilNextService(MaintenanceEntity maintenance) {
    if (maintenance.nextServiceDate == null) return null;

    return maintenance.nextServiceDate!.difference(DateTime.now()).inDays;
  }
}

/// Result of validation
class MaintenanceValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const MaintenanceValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Valid: $isValid');

    if (hasErrors) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }

    if (hasWarnings) {
      buffer.writeln('Warnings:');
      for (final warning in warnings) {
        buffer.writeln('  - $warning');
      }
    }

    return buffer.toString();
  }
}
