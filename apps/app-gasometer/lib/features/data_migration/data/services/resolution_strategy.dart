import 'package:core/core.dart';

import '../../domain/entities/gasometer_anonymous_data.dart';
import '../datasources/gasometer_migration_data_source.dart';
import 'migration_progress_tracker.dart';

/// Interface para estratégias de resolução de conflitos
///
/// Responsabilidade: Definir contrato para diferentes estratégias de resolução
/// Aplica Strategy Pattern e OCP (Open/Closed Principle)
abstract class ResolutionStrategy {
  Future<Either<Failure, DataMigrationResult>> execute(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  );
}

/// Estratégia: Manter dados da conta (remover dados anônimos)
@injectable
class KeepAccountDataStrategy implements ResolutionStrategy {
  KeepAccountDataStrategy(this._dataSource, this._progressTracker);

  final GasometerMigrationDataSource _dataSource;
  final MigrationProgressTracker _progressTracker;

  @override
  Future<Either<Failure, DataMigrationResult>> execute(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  ) async {
    try {
      final anonymousData =
          conflictResult.anonymousData as GasometerAnonymousData?;

      if (anonymousData == null) {
        return const Right(
          DataMigrationResult(
            success: true,
            choiceExecuted: DataResolutionChoice.keepAccountData,
            message: 'Nenhum dado anônimo para remover',
          ),
        );
      }

      _progressTracker.emitProgress(
        percentage: 0.1,
        operation: 'Iniciando limpeza de dados anônimos',
      );

      // Passo 1: Limpar dados locais
      _progressTracker.emitProgress(
        percentage: 0.3,
        operation: 'Removendo dados locais anônimos',
      );

      final localCleanupResult = await _dataSource.cleanAnonymousLocalData(
        anonymousData.userId,
      );

      if (localCleanupResult.isLeft()) {
        return localCleanupResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      // Passo 2: Limpar dados remotos
      _progressTracker.emitProgress(
        percentage: 0.6,
        operation: 'Removendo dados remotos anônimos',
      );

      final remoteCleanupResult = await _dataSource.cleanAnonymousRemoteData(
        anonymousData.userId,
      );

      if (remoteCleanupResult.isLeft()) {
        return remoteCleanupResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      // Passo 3: Deletar conta anônima
      _progressTracker.emitProgress(
        percentage: 0.9,
        operation: 'Removendo conta anônima',
      );

      final accountDeletionResult = await _dataSource.deleteAnonymousAccount(
        anonymousData.userId,
      );

      if (accountDeletionResult.isLeft()) {
        return accountDeletionResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      // Conclusão
      _progressTracker.emitCompleted(message: 'Migração concluída com sucesso');

      final localResult = localCleanupResult.getOrElse(
        () => throw Exception('No local result'),
      );
      final remoteResult = remoteCleanupResult.getOrElse(
        () => throw Exception('No remote result'),
      );

      return Right(
        DataMigrationResult(
          success: true,
          choiceExecuted: DataResolutionChoice.keepAccountData,
          message: 'Dados da conta mantidos, dados anônimos removidos',
          affectedRecords: {
            'local_items': localResult.totalClearedItems,
            'remote_items': remoteResult.totalClearedItems,
          },
        ),
      );
    } catch (e) {
      _progressTracker.emitError('Erro ao manter dados da conta: $e');
      return Left(UnknownFailure('Erro ao manter dados da conta: $e'));
    }
  }
}

/// Estratégia: Manter dados anônimos
@injectable
class KeepAnonymousDataStrategy implements ResolutionStrategy {
  @override
  Future<Either<Failure, DataMigrationResult>> execute(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  ) async {
    // Usuário optou por manter dados anônimos
    // Será necessário criar nova conta ou continuar como anônimo
    return const Right(
      DataMigrationResult(
        success: true,
        choiceExecuted: DataResolutionChoice.keepAnonymousData,
        message:
            'Você será direcionado para criar uma nova conta com os dados anônimos',
      ),
    );
  }
}

/// Estratégia: Cancelar operação
@injectable
class CancelMigrationStrategy implements ResolutionStrategy {
  @override
  Future<Either<Failure, DataMigrationResult>> execute(
    DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams,
  ) async {
    return const Right(
      DataMigrationResult(
        success: true,
        choiceExecuted: DataResolutionChoice.cancel,
        message: 'Operação cancelada pelo usuário',
      ),
    );
  }
}

/// Factory para criar estratégias de resolução
///
/// Responsabilidade: Criar instâncias apropriadas de estratégias
/// Aplica Factory Pattern
@injectable
class ResolutionStrategyFactory {
  ResolutionStrategyFactory(this._dataSource, this._progressTracker);

  final GasometerMigrationDataSource _dataSource;
  final MigrationProgressTracker _progressTracker;

  /// Cria estratégia apropriada baseada na escolha do usuário
  ResolutionStrategy createStrategy(DataResolutionChoice choice) {
    switch (choice) {
      case DataResolutionChoice.keepAccountData:
        return KeepAccountDataStrategy(_dataSource, _progressTracker);
      case DataResolutionChoice.keepAnonymousData:
        return KeepAnonymousDataStrategy();
      case DataResolutionChoice.cancel:
        return CancelMigrationStrategy();
    }
  }
}
