// Internal dependencies

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../repository/veiculos_repository.dart';
import '../models/veiculo_result.dart';
import '../services/error_sanitizer.dart';
import '../services/veiculo_validator.dart';

// Local imports

/// Wrapper for VeiculosRepository that implements consistent Result pattern
///
/// This wrapper provides a consistent interface with proper error handling
/// while maintaining backward compatibility with the existing repository.
/// All operations return VeiculoResult<T> instead of mixed return types.
class VeiculosRepositoryWrapper {
  final VeiculosRepository _repository;

  VeiculosRepositoryWrapper(this._repository);

  /// ========================================
  /// SELECTION OPERATIONS
  /// ========================================

  /// Get currently selected vehicle ID
  Future<VeiculoResult<String>> getSelectedVeiculoId() async {
    return VeiculoResults.tryAsync(
      () => _repository.getSelectedVeiculoId(),
      context: 'Getting selected vehicle ID',
    );
  }

  /// Set selected vehicle ID
  Future<VeiculoResult<void>> setSelectedVeiculoId(String id) async {
    return VeiculoResults.tryAsync(
      () => _repository.setSelectedVeiculoId(id),
      context: 'Setting selected vehicle ID',
    );
  }

  /// ========================================
  /// READ OPERATIONS
  /// ========================================

  /// Get all vehicles
  Future<VeiculoResult<List<VeiculoCar>>> getVeiculos() async {
    return VeiculoResults.tryAsync(
      () async {
        final vehicles = await _repository.getVeiculos();
        // Filter out inactive vehicles for cleaner API
        return vehicles.where((v) => !v.isDeleted).toList();
      },
      context: 'Getting all vehicles',
    );
  }

  /// Get vehicle by ID
  Future<VeiculoResult<VeiculoCar>> getVeiculoById(String id) async {
    if (id.trim().isEmpty) {
      return VeiculoFailure.validation('Vehicle ID cannot be empty');
    }

    return VeiculoResults.tryAsync(
      () async {
        final vehicle = await _repository.getVeiculoById(id);
        if (vehicle == null) {
          throw VeiculoNotFoundError('Vehicle with ID $id not found');
        }
        if (vehicle.isDeleted) {
          throw VeiculoNotFoundError('Vehicle with ID $id is inactive');
        }
        return vehicle;
      },
      context: 'Getting vehicle by ID: $id',
    );
  }

  /// ========================================
  /// WRITE OPERATIONS
  /// ========================================

  /// Add new vehicle
  Future<VeiculoResult<VeiculoCar>> addVeiculo(VeiculoCar veiculo) async {
    // Robust validation with security checks
    final validationResult = VeiculoValidator.validateVehicleData(veiculo);
    if (!validationResult.isValid) {
      return VeiculoFailure.validation(
        'Dados do veículo inválidos: ${validationResult.errors.join(', ')}',
        context: 'Vehicle validation',
      );
    }

    return VeiculoResults.tryAsync(
      () async {
        // Use sanitized vehicle data
        final sanitizedVeiculo = validationResult.sanitizedVehicle;
        final error = await _repository.addVeiculo(sanitizedVeiculo);
        if (error != null) {
          throw VeiculoOperationError(error);
        }
        return sanitizedVeiculo;
      },
      context: 'Adding vehicle: ${veiculo.marca} ${veiculo.modelo}',
    );
  }

  /// Update existing vehicle
  Future<VeiculoResult<VeiculoCar>> updateVeiculo(VeiculoCar veiculo) async {
    // Robust validation with security checks
    final validationResult = VeiculoValidator.validateVehicleData(veiculo);
    if (!validationResult.isValid) {
      return VeiculoFailure.validation(
        'Dados do veículo inválidos: ${validationResult.errors.join(', ')}',
        context: 'Vehicle validation',
      );
    }

    // Check if vehicle exists
    final existsResult = await getVeiculoById(veiculo.id);
    if (existsResult.isFailure) {
      return VeiculoFailure.notFound('Cannot update: vehicle not found');
    }

    return VeiculoResults.tryAsync(
      () async {
        // Use sanitized vehicle data
        final sanitizedVeiculo = validationResult.sanitizedVehicle;
        final error = await _repository.updateVeiculo(sanitizedVeiculo);
        if (error != null) {
          throw VeiculoOperationError(error);
        }
        return sanitizedVeiculo;
      },
      context: 'Updating vehicle: ${veiculo.marca} ${veiculo.modelo}',
    );
  }

  /// Delete vehicle (soft delete)
  Future<VeiculoResult<void>> deleteVeiculo(VeiculoCar veiculo) async {
    // Check if vehicle exists
    final existsResult = await getVeiculoById(veiculo.id);
    if (existsResult.isFailure) {
      return VeiculoFailure.notFound('Cannot delete: vehicle not found');
    }

    // Check if vehicle has associated records
    final hasRecordsResult = await veiculoPossuiLancamentos(veiculo.id);
    if (hasRecordsResult.isFailure) {
      return hasRecordsResult.map((_) {});
    }

    if (hasRecordsResult.value) {
      return VeiculoFailure.business(
        'Cannot delete vehicle with associated records. Archive it instead.',
        context: 'Vehicle deletion validation',
      );
    }

    return VeiculoResults.tryAsync(
      () async {
        final success = await _repository.deleteVeiculo(veiculo);
        if (!success) {
          throw VeiculoOperationError('Failed to delete vehicle');
        }
      },
      context: 'Deleting vehicle: ${veiculo.marca} ${veiculo.modelo}',
    );
  }

  /// ========================================
  /// SPECIALIZED OPERATIONS
  /// ========================================

  /// Update vehicle odometer
  Future<VeiculoResult<void>> updateOdometroAtual(
      String veiculoId, double novoOdometro) async {
    if (veiculoId.trim().isEmpty) {
      return VeiculoFailure.validation('Vehicle ID cannot be empty');
    }

    if (novoOdometro < 0) {
      return VeiculoFailure.validation('Odometer value cannot be negative');
    }

    // Check if vehicle exists
    final vehicleResult = await getVeiculoById(veiculoId);
    if (vehicleResult.isFailure) {
      return vehicleResult.map((_) {});
    }

    final vehicle = vehicleResult.value;
    if (novoOdometro < vehicle.odometroInicial) {
      return VeiculoFailure.validation(
        'New odometer value cannot be less than initial odometer (${vehicle.odometroInicial})',
      );
    }

    return VeiculoResults.tryAsync(
      () async {
        final success =
            await _repository.updateOdometroAtual(veiculoId, novoOdometro);
        if (!success) {
          throw VeiculoOperationError('Failed to update odometer');
        }
      },
      context: 'Updating odometer for vehicle: $veiculoId',
    );
  }

  /// Check if vehicle has associated records
  Future<VeiculoResult<bool>> veiculoPossuiLancamentos(String veiculoId) async {
    if (veiculoId.trim().isEmpty) {
      return VeiculoFailure.validation('Vehicle ID cannot be empty');
    }

    return VeiculoResults.tryAsync(
      () => _repository.veiculoPossuiLancamentos(veiculoId),
      context: 'Checking vehicle records for: $veiculoId',
    );
  }

  /// ========================================
  /// SECURITY-ENHANCED ERROR HANDLING
  /// ========================================

  /// Wrap async operations with enhanced error sanitization
  static Future<VeiculoResult<T>> secureAsyncOperation<T>(
    Future<T> Function() operation, {
    required String context,
  }) async {
    try {
      final value = await operation();
      return VeiculoSuccess(value);
    } catch (e) {
      // Sanitize error for security
      final sanitizedError = ErrorSanitizer.sanitizeRepositoryError(
        e,
        operation: context,
      );

      return VeiculoFailure(
        message: sanitizedError.userMessage,
        type: _mapErrorType(e),
        context: context,
        details: {
          'error_code': sanitizedError.errorCode,
          'severity': sanitizedError.severity.displayName,
        },
      );
    }
  }

  /// Map exception to appropriate error type
  static VeiculoErrorType _mapErrorType(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('validation') ||
        errorMessage.contains('invalid')) {
      return VeiculoErrorType.validation;
    }

    if (errorMessage.contains('not found') || errorMessage.contains('404')) {
      return VeiculoErrorType.notFound;
    }

    if (errorMessage.contains('permission') ||
        errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden')) {
      return VeiculoErrorType.unauthorized;
    }

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return VeiculoErrorType.network;
    }

    if (errorMessage.contains('hive') ||
        errorMessage.contains('database') ||
        errorMessage.contains('storage')) {
      return VeiculoErrorType.repository;
    }

    if (errorMessage.contains('business') ||
        errorMessage.contains('rule') ||
        errorMessage.contains('policy')) {
      return VeiculoErrorType.business;
    }

    return VeiculoErrorType.system;
  }

  /// ========================================
  /// BATCH OPERATIONS
  /// ========================================

  /// Add multiple vehicles
  Future<VeiculoResult<List<VeiculoCar>>> addVeiculos(
      List<VeiculoCar> veiculos) async {
    if (veiculos.isEmpty) {
      return VeiculoFailure.validation('Vehicle list cannot be empty');
    }

    final results = <VeiculoResult<VeiculoCar>>[];

    for (final veiculo in veiculos) {
      final result = await addVeiculo(veiculo);
      results.add(result);

      // Stop on first failure
      if (result.isFailure) {
        return result.map((_) => <VeiculoCar>[]);
      }
    }

    return VeiculoResults.combine(results);
  }

  /// Update multiple vehicles
  Future<VeiculoResult<List<VeiculoCar>>> updateVeiculos(
      List<VeiculoCar> veiculos) async {
    if (veiculos.isEmpty) {
      return VeiculoFailure.validation('Vehicle list cannot be empty');
    }

    final results = <VeiculoResult<VeiculoCar>>[];

    for (final veiculo in veiculos) {
      final result = await updateVeiculo(veiculo);
      results.add(result);

      // Stop on first failure
      if (result.isFailure) {
        return result.map((_) => <VeiculoCar>[]);
      }
    }

    return VeiculoResults.combine(results);
  }

  /// ========================================
  /// UTILITY METHODS
  /// ========================================

  /// Get repository statistics
  Future<VeiculoResult<Map<String, dynamic>>> getRepositoryStats() async {
    return VeiculoResults.tryAsync(
      () async {
        final allVehicles = await _repository.getVeiculos();
        final activeVehicles = allVehicles.where((v) => !v.isDeleted).toList();

        return {
          'total_vehicles': allVehicles.length,
          'active_vehicles': activeVehicles.length,
          'inactive_vehicles': allVehicles.length - activeVehicles.length,
          'last_updated': DateTime.now().toIso8601String(),
        };
      },
      context: 'Getting repository statistics',
    );
  }

  /// Initialize repository
  Future<VeiculoResult<void>> initialize() async {
    return VeiculoResults.tryAsync(
      () => VeiculosRepository.initialize(),
      context: 'Initializing repository',
    );
  }
}

/// ========================================
/// CUSTOM EXCEPTIONS
/// ========================================

class VeiculoNotFoundError implements Exception {
  final String message;
  VeiculoNotFoundError(this.message);

  @override
  String toString() => message;
}

class VeiculoOperationError implements Exception {
  final String message;
  VeiculoOperationError(this.message);

  @override
  String toString() => message;
}

class VeiculoValidationError implements Exception {
  final String message;
  final List<String> errors;

  VeiculoValidationError(this.message, [this.errors = const []]);

  @override
  String toString() =>
      '$message${errors.isNotEmpty ? ': ${errors.join(', ')}' : ''}';
}
