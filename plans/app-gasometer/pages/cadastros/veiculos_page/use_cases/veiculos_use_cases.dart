// Flutter

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../repository/veiculos_repository.dart';
import '../constants/veiculos_page_constants.dart';
import '../services/business_rules_engine.dart';
import '../services/error_handler.dart';

// Internal dependencies

// Local imports

/// Use cases for vehicle operations
/// Encapsulates business logic away from the controller
class VeiculosUseCases {
  final VeiculosRepository _repository;
  final VeiculosBusinessRulesEngine _rulesEngine;

  VeiculosUseCases(this._repository, [VeiculosBusinessRulesEngine? rulesEngine])
      : _rulesEngine = rulesEngine ?? VeiculosBusinessRulesEngine();

  /// Load all vehicles from repository
  Future<List<VeiculoCar>> loadVehicles() async {
    try {
      debugPrint('VeiculosUseCases: Carregando veículos do repository...');
      final result = await _repository.getVeiculos();
      debugPrint(
          'VeiculosUseCases: Repository retornou ${result.length} veículos');
      return result;
    } catch (e) {
      debugPrint('VeiculosUseCases: Erro ao carregar veículos: $e');
      final error =
          VeiculosErrorHandler.handleVehicleLoadError(Exception(e.toString()));
      throw VehicleOperationException(error.userMessage, error);
    }
  }

  /// Load selected vehicle
  Future<VeiculoCar?> loadSelectedVehicle() async {
    try {
      final selectedId = await _repository.getSelectedVeiculoId();
      if (selectedId != VeiculosPageConstants.defaultSelectedId) {
        return await _repository.getVeiculoById(selectedId);
      }
      return null;
    } catch (e) {
      final error =
          VeiculosErrorHandler.handleVehicleLoadError(Exception(e.toString()));
      throw VehicleOperationException(error.userMessage, error);
    }
  }

  /// Delete vehicle with business logic validation
  Future<bool> deleteVehicle(VeiculoCar veiculo) async {
    try {
      final result = await _repository.deleteVeiculo(veiculo);

      if (result) {
        // Business logic: If deleted vehicle was selected, clear selection
        final selectedId = await _repository.getSelectedVeiculoId();
        if (selectedId == veiculo.id) {
          await _repository
              .setSelectedVeiculoId(VeiculosPageConstants.defaultSelectedId);
        }
      }

      return result;
    } catch (e) {
      final error = VeiculosErrorHandler.handleVehicleDeleteError(
          Exception(e.toString()));
      throw VehicleOperationException(error.userMessage, error);
    }
  }

  /// Select vehicle with validation
  Future<VeiculoCar?> selectVehicle(String id) async {
    try {
      final veiculo = await _repository.getVeiculoById(id);
      if (veiculo != null) {
        await _repository.setSelectedVeiculoId(id);
        return veiculo;
      }
      return null;
    } catch (e) {
      final error = VeiculosErrorHandler.handleVehicleUpdateError(
          Exception(e.toString()));
      throw VehicleOperationException(error.userMessage, error);
    }
  }

  /// Update vehicle odometer with validation
  Future<bool> updateOdometer(String veiculoId, double novoValor) async {
    try {
      return await _repository.updateOdometroAtual(veiculoId, novoValor);
    } catch (e) {
      final error = VeiculosErrorHandler.handleOdometerUpdateError(
          Exception(e.toString()));
      throw VehicleOperationException(error.userMessage, error);
    }
  }

  /// Check if vehicle has associated records
  Future<bool> vehicleHasRecords(String veiculoId) async {
    try {
      return await _repository.veiculoPossuiLancamentos(veiculoId);
    } catch (e) {
      // Silent error for this operation as it's not critical
      return false;
    }
  }

  /// Validate vehicle limit before creation using business rules
  Future<BusinessRuleResult> canCreateVehicle(
      List<VeiculoCar> currentVehicles) async {
    return _rulesEngine.canCreateVehicle(
      currentVehicleCount: currentVehicles.length,
    );
  }

  /// Validate vehicle data before creation/update
  Future<BusinessRuleResult> validateVehicleData(
      Map<String, dynamic> vehicleData) async {
    return _rulesEngine.validateVehicleData(vehicleData: vehicleData);
  }

  /// Check if export operation is allowed
  Future<BusinessRuleResult> canExportVehicles(List<VeiculoCar> vehicles,
      {String? format}) async {
    return _rulesEngine.canExport(
      vehicleCount: vehicles.length,
      exportFormat: format,
    );
  }

  /// Business rule validation for vehicle operations
  bool validateVehicleOperation(VeiculoCar? vehicle) {
    return vehicle != null && vehicle.id.isNotEmpty;
  }
}

/// Exception for vehicle operations
class VehicleOperationException implements Exception {
  final String message;
  final StructuredError? structuredError;

  VehicleOperationException(this.message, [this.structuredError]);

  @override
  String toString() => message;
}
