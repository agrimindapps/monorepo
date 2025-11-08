import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../domain/entities/gasometer_account_data.dart';
import '../../domain/entities/gasometer_anonymous_data.dart';
import '../datasources/gasometer_migration_data_source.dart';

/// Gasometer-specific implementation of data migration service
/// 
/// This service handles the detection and resolution of data conflicts
/// specific to the Gasometer app, including vehicles, fuel records,
/// maintenance records, and other gasometer-specific data.
@LazySingleton()
class GasometerDataMigrationService implements DataMigrationService {
  
  GasometerDataMigrationService(this._dataSource);
  final GasometerMigrationDataSource _dataSource;

  @override
  Future<Either<Failure, DataConflictResult>> detectConflicts({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    try {
      final validationResult = await validateBasicPreconditions(
        anonymousUserId: anonymousUserId,
        accountUserId: accountUserId,
      );
      
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected validation result'),
        );
      }
      final anonymousDataResult = await _dataSource.getAnonymousData(anonymousUserId);
      if (anonymousDataResult.isLeft()) {
        return anonymousDataResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }
      final accountDataResult = await _dataSource.getAccountData(accountUserId);
      if (accountDataResult.isLeft()) {
        return accountDataResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      final anonymousData = anonymousDataResult.getOrElse(() => throw Exception('No anonymous data'));
      final accountData = accountDataResult.getOrElse(() => throw Exception('No account data'));
      final conflict = _analyzeDataConflict(anonymousData, accountData);
      
      return Right(conflict);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error detecting conflicts: $e');
      }
      return Left(UnknownFailure('Erro ao detectar conflitos de dados: $e'));
    }
  }

  @override
  Future<Either<Failure, DataMigrationResult>> executeResolution({
    required DataResolutionChoice choice,
    required DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams = const {},
  }) async {
    try {
      switch (choice) {
        case DataResolutionChoice.keepAccountData:
          return await _executeKeepAccountData(conflictResult, additionalParams);
        case DataResolutionChoice.keepAnonymousData:
          return await _executeKeepAnonymousData(conflictResult, additionalParams);
        case DataResolutionChoice.cancel:
          return await _executeCancel(conflictResult, additionalParams);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error executing resolution: $e');
      }
      return Left(UnknownFailure('Erro ao executar resolução: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateMigrationPreconditions({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    try {
      final basicValidation = await validateBasicPreconditions(
        anonymousUserId: anonymousUserId,
        accountUserId: accountUserId,
      );
      
      if (basicValidation.isLeft()) return basicValidation;
      final hasConnectivity = await _dataSource.checkNetworkConnectivity();
      if (!hasConnectivity) {
        return const Left(NetworkFailure('Conectividade necessária para migração'));
      }
      final isAnonymousValid = await _dataSource.validateAnonymousUser(anonymousUserId);
      if (!isAnonymousValid) {
        return const Left(AuthFailure('Usuário anônimo inválido'));
      }

      final isAccountValid = await _dataSource.validateAccountUser(accountUserId);
      if (!isAccountValid) {
        return const Left(AuthFailure('Conta de usuário inválida'));
      }

      return const Right(true);

    } catch (e) {
      return Left(UnknownFailure('Erro na validação: $e'));
    }
  }

  @override
  Stream<MigrationProgress> get migrationProgress => 
      _progressController.stream;

  @override
  Future<Either<Failure, void>> cancelMigration() async {
    try {
      await _dataSource.cancelOngoingOperations();
      _progressController.add(const MigrationProgress(
        percentage: 0.0,
        currentOperation: 'Migração cancelada',
      ));
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Erro ao cancelar migração: $e'));
    }
  }

  final StreamController<MigrationProgress> _progressController = 
      StreamController<MigrationProgress>.broadcast();

  /// Helper method to emit progress updates
  void emitProgress({
    required double percentage,
    required String operation,
    String? details,
    Duration? estimatedTime,
  }) {
    if (kDebugMode) {
      debugPrint('Migration Progress: ${(percentage * 100).toInt()}% - $operation');
    }
  }

  /// Common validation logic
  Future<Either<Failure, bool>> validateBasicPreconditions({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    try {
      if (anonymousUserId.isEmpty) {
        return const Left(ValidationFailure('ID de usuário anônimo inválido'));
      }
      
      if (accountUserId.isEmpty) {
        return const Left(ValidationFailure('ID de conta de usuário inválido'));
      }
      
      if (anonymousUserId == accountUserId) {
        return const Left(ValidationFailure('IDs de usuário não podem ser iguais'));
      }
      
      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure('Erro na validação: $e'));
    }
  }

  DataConflictResult _analyzeDataConflict(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    final hasConflict = _hasSignificantConflict(anonymousData, accountData);
    final conflictDetails = _generateConflictDetails(anonymousData, accountData);
    final recommendation = _generateRecommendation(anonymousData, accountData);
    final availableChoices = _getAvailableChoices(anonymousData, accountData);
    
    return DataConflictResult(
      hasConflict: hasConflict,
      anonymousData: anonymousData,
      accountData: accountData,
      conflictDetails: conflictDetails,
      recommendedChoice: recommendation,
      availableChoices: availableChoices,
    );
  }

  bool _hasSignificantConflict(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    if (!anonymousData.hasSignificantData && !accountData.hasSignificantData) {
      return false;
    }
    if (anonymousData.hasSignificantData != accountData.hasSignificantData) {
      return false;
    }
    return anonymousData.hasSignificantData && accountData.hasSignificantData;
  }

  Map<String, dynamic> _generateConflictDetails(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    return {
      'anonymous_vehicles': anonymousData.vehicleCount,
      'account_vehicles': accountData.vehicleCount,
      'anonymous_fuel_records': anonymousData.fuelRecordCount,
      'account_fuel_records': accountData.fuelRecordCount,
      'anonymous_maintenance': anonymousData.maintenanceRecordCount,
      'account_maintenance': accountData.maintenanceRecordCount,
      'data_value_comparison': {
        'anonymous_score': anonymousData.breakdown['data_value_score'],
        'account_score': accountData.breakdown['data_maturity_score'],
      },
    };
  }

  DataResolutionChoice? _generateRecommendation(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    if (!_hasSignificantConflict(anonymousData, accountData)) {
      return null;
    }
    if (accountData.isEstablishedData) {
      return DataResolutionChoice.keepAccountData;
    }
    if (anonymousData.isValuableData && !accountData.hasSignificantData) {
      return DataResolutionChoice.keepAnonymousData;
    }
    return DataResolutionChoice.keepAccountData;
  }

  List<DataResolutionChoice> _getAvailableChoices(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    final choices = <DataResolutionChoice>[DataResolutionChoice.cancel];
    if (anonymousData.hasSignificantData) {
      choices.insert(0, DataResolutionChoice.keepAnonymousData);
    }
    choices.insert(0, DataResolutionChoice.keepAccountData);
    
    return choices;
  }

  Future<Either<Failure, DataMigrationResult>> _executeKeepAccountData(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  ) async {
    try {
      final anonymousData = conflictResult.anonymousData as GasometerAnonymousData?;
      if (anonymousData == null) {
        return const Right(DataMigrationResult(
          success: true,
          choiceExecuted: DataResolutionChoice.keepAccountData,
          message: 'Nenhum dado anônimo para remover',
        ));
      }

      _emitProgress(0.1, 'Iniciando limpeza de dados anônimos');
      _emitProgress(0.3, 'Removendo dados locais anônimos');
      final localCleanupResult = await _dataSource.cleanAnonymousLocalData(
        anonymousData.userId,
      );
      
      if (localCleanupResult.isLeft()) {
        return localCleanupResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }
      _emitProgress(0.6, 'Removendo dados remotos anônimos');
      final remoteCleanupResult = await _dataSource.cleanAnonymousRemoteData(
        anonymousData.userId,
      );
      
      if (remoteCleanupResult.isLeft()) {
        return remoteCleanupResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }
      _emitProgress(0.9, 'Removendo conta anônima');
      final accountDeletionResult = await _dataSource.deleteAnonymousAccount(
        anonymousData.userId,
      );
      
      if (accountDeletionResult.isLeft()) {
        return accountDeletionResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      _emitProgress(1.0, 'Migração concluída com sucesso');

      final localResult = localCleanupResult.getOrElse(() => throw Exception('No local result'));
      final remoteResult = remoteCleanupResult.getOrElse(() => throw Exception('No remote result'));

      return Right(DataMigrationResult(
        success: true,
        choiceExecuted: DataResolutionChoice.keepAccountData,
        message: 'Dados da conta mantidos, dados anônimos removidos com sucesso',
        affectedRecords: {
          'local_items': localResult.totalClearedItems,
          'remote_items': remoteResult.totalClearedItems,
        },
      ));

    } catch (e) {
      _emitProgress(0.0, 'Erro durante migração');
      return Left(UnknownFailure('Erro ao manter dados da conta: $e'));
    }
  }

  Future<Either<Failure, DataMigrationResult>> _executeKeepAnonymousData(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  ) async {
    return const Right(DataMigrationResult(
      success: true,
      choiceExecuted: DataResolutionChoice.keepAnonymousData,
      message: 'Você será direcionado para criar uma nova conta com os dados anônimos',
    ));
  }

  Future<Either<Failure, DataMigrationResult>> _executeCancel(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  ) async {
    return const Right(DataMigrationResult(
      success: true,
      choiceExecuted: DataResolutionChoice.cancel,
      message: 'Operação cancelada pelo usuário',
    ));
  }

  void _emitProgress(double percentage, String operation, {String? details}) {
    emitProgress(
      percentage: percentage,
      operation: operation,
      details: details,
    );
    
    _progressController.add(MigrationProgress(
      percentage: percentage,
      currentOperation: operation,
      details: details,
    ));
  }

  void dispose() {
    _progressController.close();
  }
}
