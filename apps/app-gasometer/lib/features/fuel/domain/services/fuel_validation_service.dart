import '../entities/fuel_record_entity.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/fuel_constants.dart';

/// Serviço avançado para validação contextual de registros de abastecimento
class FuelValidationService {
  static final FuelValidationService _instance = FuelValidationService._internal();
  factory FuelValidationService() => _instance;
  FuelValidationService._internal();

  /// Valida consistência entre registros de abastecimento
  ValidationResult validateFuelRecord(
    FuelRecordEntity record,
    VehicleEntity vehicle,
    FuelRecordEntity? previousRecord,
  ) {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    // Validar compatibilidade com o veículo
    _validateVehicleCompatibility(record, vehicle, errors);

    // Validar sequência de odômetro
    _validateOdometerSequence(record, vehicle, previousRecord, errors, warnings);

    // Validar consumo (se possível calcular)
    _validateConsumption(record, previousRecord, warnings);

    // Validar preços (detecção de anomalias)
    _validatePriceAnomalies(record, warnings);

    // Validar capacidade do tanque
    _validateTankCapacity(record, vehicle, errors, warnings);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida compatibilidade entre registro e veículo
  void _validateVehicleCompatibility(
    FuelRecordEntity record,
    VehicleEntity vehicle,
    Map<String, String> errors,
  ) {
    // Verificar se o veículo suporta o tipo de combustível
    if (!vehicle.supportsFuelType(record.fuelType)) {
      errors['fuelType'] = 
          'Veículo ${vehicle.displayName} não suporta ${record.fuelType.displayName}';
    }

    // Verificar se o veículo está ativo
    if (!vehicle.isActive) {
      errors['vehicle'] = 'Veículo está inativo';
    }
  }

  /// Valida sequência lógica do odômetro
  void _validateOdometerSequence(
    FuelRecordEntity record,
    VehicleEntity vehicle,
    FuelRecordEntity? previousRecord,
    Map<String, String> errors,
    Map<String, String> warnings,
  ) {
    // Verificar se odômetro não regrediu em relação ao atual do veículo
    if (record.odometer < vehicle.currentOdometer - 100) {
      errors['odometer'] = 
          'Odômetro muito abaixo do atual (${vehicle.currentOdometer.toStringAsFixed(0)} km)';
    }

    // Verificar sequência com registro anterior
    if (previousRecord != null) {
      if (record.odometer < previousRecord.odometer) {
        errors['odometer'] = 
            'Odômetro menor que o registro anterior (${previousRecord.odometer.toStringAsFixed(0)} km)';
      }

      final difference = record.odometer - previousRecord.odometer;
      final daysDifference = record.date.difference(previousRecord.date).inDays;

      // Alerta para diferenças suspeitas
      if (difference > FuelConstants.maxOdometerDifference) {
        warnings['odometer'] = 
            'Diferença muito grande desde último registro: ${difference.toStringAsFixed(0)} km';
      }

      // Alerta para rodagem diária muito alta
      if (daysDifference > 0 && difference / daysDifference > 500) {
        warnings['odometer'] = 
            'Média diária muito alta: ${(difference / daysDifference).toStringAsFixed(0)} km/dia';
      }
    }
  }

  /// Valida consumo calculado (se possível)
  void _validateConsumption(
    FuelRecordEntity record,
    FuelRecordEntity? previousRecord,
    Map<String, String> warnings,
  ) {
    if (previousRecord == null || !record.fullTank || !previousRecord.fullTank) {
      return; // Não é possível calcular consumo preciso
    }

    final distance = record.odometer - previousRecord.odometer;
    if (distance <= 0) return;

    final consumption = distance / record.liters;

    // Alertas para consumo anômalo
    if (consumption < 3.0) {
      warnings['consumption'] = 
          'Consumo muito baixo: ${consumption.toStringAsFixed(1)} km/l';
    } else if (consumption > 25.0) {
      warnings['consumption'] = 
          'Consumo muito alto: ${consumption.toStringAsFixed(1)} km/l';
    }
  }

  /// Valida preços para detectar anomalias
  void _validatePriceAnomalies(
    FuelRecordEntity record,
    Map<String, String> warnings,
  ) {
    // Preços muito baixos ou muito altos podem indicar erro
    if (record.pricePerLiter < 3.0) {
      warnings['pricePerLiter'] = 
          'Preço muito baixo: ${record.formattedPricePerLiter}';
    } else if (record.pricePerLiter > 8.0) {
      warnings['pricePerLiter'] = 
          'Preço muito alto: ${record.formattedPricePerLiter}';
    }

    // Validar coerência do valor total
    final expectedTotal = record.liters * record.pricePerLiter;
    final difference = (record.totalPrice - expectedTotal).abs();
    
    if (difference > FuelConstants.maxCalculationDifference) {
      warnings['totalPrice'] = 
          'Valor total não confere: esperado ${expectedTotal.toStringAsFixed(2)}';
    }
  }

  /// Valida em relação à capacidade do tanque
  void _validateTankCapacity(
    FuelRecordEntity record,
    VehicleEntity vehicle,
    Map<String, String> errors,
    Map<String, String> warnings,
  ) {
    final tankCapacity = vehicle.tankCapacity;
    if (tankCapacity == null) return;

    // Erro se muito acima da capacidade
    if (record.liters > tankCapacity * 1.2) {
      errors['liters'] = 
          'Quantidade muito acima da capacidade (${tankCapacity.toStringAsFixed(0)}L)';
    }
    // Aviso se próximo do limite
    else if (record.liters > tankCapacity * FuelConstants.maxTankOverfill) {
      warnings['liters'] = 
          'Quantidade próxima do limite da capacidade (${tankCapacity.toStringAsFixed(0)}L)';
    }
  }

  /// Análise de padrões de abastecimento para um veículo
  FuelPatternAnalysis analyzeFuelPatterns(
    List<FuelRecordEntity> records,
    VehicleEntity vehicle,
  ) {
    if (records.isEmpty) {
      return FuelPatternAnalysis.empty();
    }

    final sortedRecords = List<FuelRecordEntity>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calcular estatísticas
    final totalLiters = sortedRecords.fold<double>(0, (sum, r) => sum + r.liters);
    final averageLiters = totalLiters / sortedRecords.length;
    
    final totalCost = sortedRecords.fold<double>(0, (sum, r) => sum + r.totalPrice);
    final averagePricePerLiter = sortedRecords
        .fold<double>(0, (sum, r) => sum + r.pricePerLiter) / sortedRecords.length;

    // Calcular consumo médio (apenas para tanques cheios consecutivos)
    final consumptions = <double>[];
    for (int i = 1; i < sortedRecords.length; i++) {
      final current = sortedRecords[i];
      final previous = sortedRecords[i - 1];
      
      if (current.fullTank && previous.fullTank) {
        final distance = current.odometer - previous.odometer;
        if (distance > 0) {
          consumptions.add(distance / current.liters);
        }
      }
    }

    final averageConsumption = consumptions.isNotEmpty
        ? consumptions.fold<double>(0, (sum, c) => sum + c) / consumptions.length
        : null;

    // Detectar anomalias
    final anomalies = _detectAnomalies(sortedRecords);

    return FuelPatternAnalysis(
      totalRecords: sortedRecords.length,
      totalLiters: totalLiters,
      totalCost: totalCost,
      averageLiters: averageLiters,
      averagePricePerLiter: averagePricePerLiter,
      averageConsumption: averageConsumption,
      anomalies: anomalies,
      lastRecord: sortedRecords.last,
      firstRecord: sortedRecords.first,
    );
  }

  /// Detecta anomalias nos registros
  List<FuelAnomaly> _detectAnomalies(List<FuelRecordEntity> records) {
    final anomalies = <FuelAnomaly>[];
    
    // Calcular médias para detectar outliers
    final averagePrice = records.fold<double>(0, (sum, r) => sum + r.pricePerLiter) / records.length;
    final averageLiters = records.fold<double>(0, (sum, r) => sum + r.liters) / records.length;

    for (final record in records) {
      // Preço muito diferente da média
      if ((record.pricePerLiter - averagePrice).abs() > averagePrice * 0.3) {
        anomalies.add(FuelAnomaly(
          recordId: record.id,
          type: AnomalyType.priceOutlier,
          description: 'Preço ${record.pricePerLiter > averagePrice ? 'muito alto' : 'muito baixo'} '
                      'comparado à média (${averagePrice.toStringAsFixed(3)})',
          severity: AnomalySeverity.medium,
        ));
      }

      // Quantidade muito diferente da média
      if ((record.liters - averageLiters).abs() > averageLiters * 0.5) {
        anomalies.add(FuelAnomaly(
          recordId: record.id,
          type: AnomalyType.volumeOutlier,
          description: 'Quantidade ${record.liters > averageLiters ? 'muito alta' : 'muito baixa'} '
                      'comparada à média (${averageLiters.toStringAsFixed(2)}L)',
          severity: AnomalySeverity.low,
        ));
      }
    }

    return anomalies;
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Análise de padrões de abastecimento
class FuelPatternAnalysis {
  final int totalRecords;
  final double totalLiters;
  final double totalCost;
  final double averageLiters;
  final double averagePricePerLiter;
  final double? averageConsumption;
  final List<FuelAnomaly> anomalies;
  final FuelRecordEntity lastRecord;
  final FuelRecordEntity firstRecord;

  FuelPatternAnalysis({
    required this.totalRecords,
    required this.totalLiters,
    required this.totalCost,
    required this.averageLiters,
    required this.averagePricePerLiter,
    this.averageConsumption,
    required this.anomalies,
    required this.lastRecord,
    required this.firstRecord,
  });

  factory FuelPatternAnalysis.empty() {
    return FuelPatternAnalysis(
      totalRecords: 0,
      totalLiters: 0,
      totalCost: 0,
      averageLiters: 0,
      averagePricePerLiter: 0,
      averageConsumption: null,
      anomalies: [],
      lastRecord: FuelRecordEntity(
        id: '', userId: '', vehicleId: '', fuelType: FuelType.gasoline,
        liters: 0, pricePerLiter: 0, totalPrice: 0, odometer: 0,
        date: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      firstRecord: FuelRecordEntity(
        id: '', userId: '', vehicleId: '', fuelType: FuelType.gasoline,
        liters: 0, pricePerLiter: 0, totalPrice: 0, odometer: 0,
        date: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    );
  }

  bool get hasAnomalies => anomalies.isNotEmpty;
  
  String get totalCostFormatted => 'R\$ ${totalCost.toStringAsFixed(2)}';
  String get averagePriceFormatted => 'R\$ ${averagePricePerLiter.toStringAsFixed(3)}';
  String get averageConsumptionFormatted => 
      averageConsumption != null ? '${averageConsumption!.toStringAsFixed(1)} km/l' : 'N/A';
}

/// Anomalia detectada
class FuelAnomaly {
  final String recordId;
  final AnomalyType type;
  final String description;
  final AnomalySeverity severity;

  FuelAnomaly({
    required this.recordId,
    required this.type,
    required this.description,
    required this.severity,
  });
}

enum AnomalyType {
  priceOutlier,
  volumeOutlier,
  consumptionAnomaly,
  sequenceError,
}

enum AnomalySeverity {
  low,
  medium,
  high,
  critical,
}