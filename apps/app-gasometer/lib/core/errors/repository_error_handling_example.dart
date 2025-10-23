/// Example: Enhanced Repository with Robust Error Handling
///
/// Este arquivo demonstra como aplicar error handling robusto em repositórios
/// do app-gasometer usando ExceptionMapper e FinancialLoggingService.
///
/// Padrões aplicados:
/// - ExceptionMapper para conversão de exceptions em Failures tipados
/// - FinancialLoggingService para logging de operações financeiras
/// - Try-catch em todos os métodos públicos
/// - Logging apropriado (debug/info/error/critical)
/// - Stack traces sempre capturados
/// - Metadata relevante nos logs
///
/// Este é um exemplo de referência. Os repositórios reais (VehicleRepository,
/// FuelRepository) devem ser atualizados gradualmente seguindo este padrão.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../services/financial_logging_service.dart';
import 'exception_mapper.dart';
import 'failures.dart';

/// Exemplo de repository melhorado com error handling robusto
/// NÃO É PARA SER USADO EM PRODUÇÃO - APENAS REFERÊNCIA
class EnhancedFuelRepositoryExample {
  final UnifiedSyncManager _syncManager;
  final FinancialLoggingService _logger;

  EnhancedFuelRepositoryExample({
    required UnifiedSyncManager syncManager,
    required FinancialLoggingService logger,
  })  : _syncManager = syncManager,
        _logger = logger;

  static const _appName = 'gasometer';

  /// CREATE: Adicionar abastecimento com validação e logging financeiro
  Future<Either<Failure, FuelSupply>> create(FuelSupply fuelSupply) async {
    // Log de início da operação (debug)
    _logger.debug('Creating fuel supply: ${fuelSupply.id}', {
      'fuel_id': fuelSupply.id,
      'vehicle_id': fuelSupply.vehicleId,
    });

    try {
      // ✅ VALIDAÇÃO FINANCEIRA (antes de persistir)
      if (fuelSupply.cost < 0) {
        _logger.logFinancialValidationError(
          entityType: 'fuel_supply',
          fieldName: 'cost',
          invalidValue: fuelSupply.cost,
          constraint: 'cost >= 0',
          additionalContext: {'fuel_id': fuelSupply.id},
        );

        return Left(
          ExceptionMapper.createFinancialIntegrityFailure(
            message: 'Valor não pode ser negativo',
            fieldName: 'cost',
            invalidValue: fuelSupply.cost,
            constraint: 'cost >= 0',
          ),
        );
      }

      if (fuelSupply.liters <= 0) {
        _logger.logFinancialValidationError(
          entityType: 'fuel_supply',
          fieldName: 'liters',
          invalidValue: fuelSupply.liters,
          constraint: 'liters > 0',
          additionalContext: {'fuel_id': fuelSupply.id},
        );

        return Left(
          ExceptionMapper.createFinancialIntegrityFailure(
            message: 'Litros deve ser maior que zero',
            fieldName: 'liters',
            invalidValue: fuelSupply.liters,
            constraint: 'liters > 0',
          ),
        );
      }

      // ✅ PERSISTÊNCIA com UnifiedSyncManager
      await _syncManager.create('gasometer', fuelSupply.toEntity());

      // ✅ LOGGING FINANCEIRO detalhado (auditoria)
      _logger.logFinancialOperation(
        operation: 'CREATE',
        entityType: 'fuel_supply',
        entityId: fuelSupply.id,
        amount: fuelSupply.cost,
        vehicleId: fuelSupply.vehicleId,
        additionalData: {
          'liters': fuelSupply.liters,
          'price_per_liter': fuelSupply.pricePerLiter,
          'date': fuelSupply.date.toIso8601String(),
          'odometer': fuelSupply.odometer,
        },
      );

      _logger.info('Fuel supply created successfully', {
        'fuel_id': fuelSupply.id,
        'cost': fuelSupply.cost,
        'vehicle_id': fuelSupply.vehicleId,
      });

      return Right(fuelSupply);
    } on FirebaseException catch (e, stackTrace) {
      // ✅ FIREBASE ERROR - Mapear e logar
      _logger.error(
        'Failed to create fuel supply (Firebase)',
        error: e,
        stackTrace: stackTrace,
        metadata: {
          'fuel_id': fuelSupply.id,
          'firebase_code': e.code,
          'firebase_message': e.message,
        },
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    } catch (e, stackTrace) {
      // ✅ UNEXPECTED ERROR - Logar como crítico
      _logger.critical(
        'Unexpected error creating fuel supply',
        error: e,
        stackTrace: stackTrace,
        metadata: {
          'fuel_id': fuelSupply.id,
          'cost': fuelSupply.cost,
          'vehicle_id': fuelSupply.vehicleId,
        },
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }

  /// UPDATE: Atualizar abastecimento com detecção de conflitos
  Future<Either<Failure, FuelSupply>> update(FuelSupply fuelSupply) async {
    _logger.debug('Updating fuel supply: ${fuelSupply.id}');

    try {
      // ✅ VALIDAÇÃO FINANCEIRA
      if (fuelSupply.cost < 0) {
        _logger.logFinancialValidationError(
          entityType: 'fuel_supply',
          fieldName: 'cost',
          invalidValue: fuelSupply.cost,
          constraint: 'cost >= 0',
        );

        return Left(
          ExceptionMapper.createFinancialIntegrityFailure(
            message: 'Valor não pode ser negativo',
            fieldName: 'cost',
            invalidValue: fuelSupply.cost,
            constraint: 'cost >= 0',
          ),
        );
      }

      // ✅ BUSCAR VERSÃO ATUAL (para comparação)
      final currentResult = await _syncManager.findById<FuelSupply>(
        _appName,
        fuelSupply.id,
      );

      final currentSupply = currentResult.fold(
        (failure) => null,
        (supply) => supply,
      );

      // ✅ UPDATE com versioning
      final updatedSupply = fuelSupply.markAsDirty().incrementVersion();

      await _syncManager.update<FuelSupply>(
        _appName,
        fuelSupply.id,
        updatedSupply,
      );

      // ✅ LOGGING FINANCEIRO
      _logger.logFinancialOperation(
        operation: 'UPDATE',
        entityType: 'fuel_supply',
        entityId: fuelSupply.id,
        amount: fuelSupply.cost,
        vehicleId: fuelSupply.vehicleId,
        additionalData: {
          'previous_cost': currentSupply?.cost,
          'new_cost': fuelSupply.cost,
          'liters': fuelSupply.liters,
        },
      );

      return Right(updatedSupply);
    } on FirebaseException catch (e, stackTrace) {
      // ✅ DETECTAR CONFLITOS (failed-precondition, aborted)
      if (e.code == 'failed-precondition' || e.code == 'aborted') {
        _logger.logFinancialConflict(
          entityType: 'fuel_supply',
          entityId: fuelSupply.id,
          localData: fuelSupply.toJson(),
          remoteData: null, // Precisaria buscar do Firebase
          resolution: 'manual_required',
        );

        return Left(
          ExceptionMapper.createFinancialConflictFailure(
            message: 'Conflito ao atualizar. Os dados foram modificados por outro dispositivo.',
            entityType: 'fuel_supply',
            entityId: fuelSupply.id,
            localData: fuelSupply,
            remoteData: null,
          ),
        );
      }

      _logger.error(
        'Failed to update fuel supply (Firebase)',
        error: e,
        stackTrace: stackTrace,
        metadata: {
          'fuel_id': fuelSupply.id,
          'firebase_code': e.code,
        },
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    } catch (e, stackTrace) {
      _logger.critical(
        'Unexpected error updating fuel supply',
        error: e,
        stackTrace: stackTrace,
        metadata: {'fuel_id': fuelSupply.id},
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }

  /// DELETE: Remover abastecimento com logging de auditoria
  Future<Either<Failure, void>> delete(String id) async {
    _logger.debug('Deleting fuel supply: $id');

    try {
      // ✅ BUSCAR REGISTRO ANTES DE DELETAR (para auditoria)
      final recordResult = await _syncManager.findById<FuelSupply>(
        _appName,
        id,
      );

      final record = recordResult.fold(
        (failure) => null,
        (supply) => supply,
      );

      if (record == null) {
        _logger.warning('Fuel supply not found for deletion', {'fuel_id': id});
        return Left(NotFoundFailure('Abastecimento não encontrado'));
      }

      // ✅ DELETE
      await _syncManager.delete<FuelSupply>(_appName, id);

      // ✅ LOGGING FINANCEIRO DE DELEÇÃO (importante para auditoria)
      _logger.logFinancialOperation(
        operation: 'DELETE',
        entityType: 'fuel_supply',
        entityId: id,
        amount: record.cost,
        vehicleId: record.vehicleId,
        additionalData: {
          'deleted_at': DateTime.now().toIso8601String(),
          'liters': record.liters,
          'date': record.date.toIso8601String(),
        },
      );

      _logger.info('Fuel supply deleted successfully', {
        'fuel_id': id,
        'cost': record.cost,
      });

      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error(
        'Failed to delete fuel supply (Firebase)',
        error: e,
        stackTrace: stackTrace,
        metadata: {
          'fuel_id': id,
          'firebase_code': e.code,
        },
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    } catch (e, stackTrace) {
      _logger.critical(
        'Unexpected error deleting fuel supply',
        error: e,
        stackTrace: stackTrace,
        metadata: {'fuel_id': id},
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }

  /// SYNC: Sincronizar com logging de falhas
  Future<Either<Failure, void>> sync() async {
    _logger.debug('Starting fuel supply sync');

    try {
      await _syncManager.forceSyncEntity<FuelSupply>(_appName);

      _logger.info('Fuel supply sync completed successfully');

      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.logSyncFailure(
        entityType: 'fuel_supply',
        entityId: 'all',
        failure: ExceptionMapper.mapException(e, stackTrace),
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    } catch (e, stackTrace) {
      _logger.critical(
        'Unexpected error during fuel supply sync',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }
}

/// Exemplo de entidade FuelSupply (para referência)
class FuelSupply {
  final String id;
  final String vehicleId;
  final double cost;
  final double liters;
  final double pricePerLiter;
  final DateTime date;
  final double? odometer;
  final bool isDirty;
  final int version;

  FuelSupply({
    required this.id,
    required this.vehicleId,
    required this.cost,
    required this.liters,
    required this.pricePerLiter,
    required this.date,
    this.odometer,
    this.isDirty = false,
    this.version = 1,
  });

  FuelSupply copyWith({
    String? id,
    String? vehicleId,
    double? cost,
    double? liters,
    double? pricePerLiter,
    DateTime? date,
    double? odometer,
    bool? isDirty,
    int? version,
  }) {
    return FuelSupply(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      cost: cost ?? this.cost,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
    );
  }

  FuelSupply markAsDirty() => copyWith(isDirty: true);

  FuelSupply incrementVersion() => copyWith(version: version + 1);

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'cost': cost,
        'liters': liters,
        'pricePerLiter': pricePerLiter,
        'date': date.toIso8601String(),
        'odometer': odometer,
        'isDirty': isDirty,
        'version': version,
      };

  // Placeholder - implementação real está em outro lugar
  dynamic toEntity() => {};
}
