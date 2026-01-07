import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/contracts/i_app_data_cleaner.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../shared/utils/failure.dart';

/// Serviço centralizado de exclusão de contas
/// Coordena a exclusão de conta Firebase com limpeza de dados específicos por app
/// Baseado na implementação bem-sucedida do app-gasometer
class AccountDeletionService {
  final IAuthRepository _authRepository;
  final IAppDataCleaner? _appDataCleaner;

  const AccountDeletionService({
    required IAuthRepository authRepository,
    IAppDataCleaner? appDataCleaner,
  }) : _authRepository = authRepository,
       _appDataCleaner = appDataCleaner;

  /// Executa exclusão completa da conta
  /// 1. Limpa dados locais específicos do app
  /// 2. Remove conta do Firebase Authentication
  /// 3. Retorna resultado detalhado da operação
  Future<Either<Failure, AccountDeletionResult>> deleteAccount() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🗑️ AccountDeletionService: Starting account deletion process',
        );
      }

      final deletionResult = AccountDeletionResult();
      final isLoggedIn = await _authRepository.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(
          AuthenticationFailure('Usuário não está autenticado'),
        );
      }
      if (_appDataCleaner != null) {
        try {
          final statsBeforeCleaning = await _appDataCleaner
              .getDataStatsBeforeCleaning();
          deletionResult.dataStatsBeforeCleaning = statsBeforeCleaning;

          if (kDebugMode) {
            debugPrint(
              '📊 AccountDeletionService: Data stats before cleaning:',
            );
            debugPrint('   App: ${_appDataCleaner.appName}');
            debugPrint('   Stats: $statsBeforeCleaning');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ AccountDeletionService: Error getting data stats: $e',
            );
          }
        }
      }
      if (_appDataCleaner != null) {
        try {
          if (kDebugMode) {
            debugPrint(
              '🧹 AccountDeletionService: Cleaning app-specific data...',
            );
          }

          final cleanupResult = await _appDataCleaner.clearAllAppData();
          deletionResult.localDataCleanupResult = cleanupResult;

          if (cleanupResult['success'] == true) {
            if (kDebugMode) {
              debugPrint(
                '✅ AccountDeletionService: App data cleaned successfully',
              );
              debugPrint(
                '   Boxes cleared: ${cleanupResult['clearedBoxes']?.length ?? 0}',
              );
              debugPrint(
                '   Preferences cleared: ${cleanupResult['clearedPreferences']?.length ?? 0}',
              );
              debugPrint(
                '   Total records: ${cleanupResult['totalRecordsCleared'] ?? 0}',
              );
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ AccountDeletionService: App data cleanup had issues',
              );
              debugPrint('   Errors: ${cleanupResult['errors']}');
            }
          }
          final verificationResult = await _appDataCleaner.verifyDataCleanup();
          deletionResult.dataCleanupVerified = verificationResult;

          if (kDebugMode) {
            debugPrint(
              '🔍 AccountDeletionService: Data cleanup verification: $verificationResult',
            );
          }
        } catch (e) {
          deletionResult.localDataCleanupError = e.toString();
          if (kDebugMode) {
            debugPrint(
              '❌ AccountDeletionService: Error during app data cleanup: $e',
            );
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '⚠️ AccountDeletionService: No app data cleaner provided - skipping local cleanup',
          );
        }
      }
      if (kDebugMode) {
        debugPrint('🔥 AccountDeletionService: Deleting Firebase account...');
      }

      final firebaseResult = await _authRepository.deleteAccount();

      return firebaseResult.fold(
        (failure) {
          deletionResult.firebaseDeleteSuccess = false;
          deletionResult.firebaseDeleteError = failure.message;

          if (kDebugMode) {
            debugPrint(
              '❌ AccountDeletionService: Firebase deletion failed: ${failure.message}',
            );
          }

          return Left(failure);
        },
        (_) {
          deletionResult.firebaseDeleteSuccess = true;
          deletionResult.completedAt = DateTime.now();

          if (kDebugMode) {
            debugPrint(
              '✅ AccountDeletionService: Account deletion completed successfully',
            );
            debugPrint('   Firebase: ✅');
            debugPrint(
              '   Local Data: ${deletionResult.localDataCleanupResult?['success'] == true ? '✅' : '⚠️'}',
            );
            debugPrint(
              '   Verification: ${deletionResult.dataCleanupVerified ? '✅' : '⚠️'}',
            );
          }

          return Right(deletionResult);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ AccountDeletionService: Unexpected error during deletion: $e',
        );
      }

      return Left(UnexpectedFailure('Erro inesperado durante exclusão: $e'));
    }
  }

  /// Obter estatísticas dos dados que serão excluídos
  /// Útil para mostrar confirmação detalhada ao usuário
  Future<Either<Failure, Map<String, dynamic>>>
  getAccountDeletionPreview() async {
    try {
      final preview = <String, dynamic>{
        'hasDataCleaner': _appDataCleaner != null,
        'appName': _appDataCleaner?.appName ?? 'Unknown',
        'cleanerVersion': _appDataCleaner?.version ?? 'N/A',
        'description': _appDataCleaner?.description ?? 'Dados da aplicação',
      };

      if (_appDataCleaner != null) {
        try {
          final hasData = await _appDataCleaner.hasDataToClear();
          final stats = await _appDataCleaner.getDataStatsBeforeCleaning();
          final categories = _appDataCleaner.getAvailableCategories();

          preview.addAll({
            'hasDataToClear': hasData,
            'dataStats': stats,
            'availableCategories': categories,
          });
        } catch (e) {
          preview['dataPreviewError'] = e.toString();
        }
      }

      return Right(preview);
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao obter preview de exclusão: $e'));
    }
  }
}

/// Resultado detalhado da exclusão de conta
class AccountDeletionResult {
  DateTime? completedAt;
  bool firebaseDeleteSuccess = false;
  String? firebaseDeleteError;
  Map<String, dynamic>? localDataCleanupResult;
  String? localDataCleanupError;
  bool dataCleanupVerified = false;
  Map<String, dynamic>? dataStatsBeforeCleaning;

  AccountDeletionResult();

  /// Indica se toda a operação foi bem-sucedida
  bool get isSuccess =>
      firebaseDeleteSuccess &&
      (localDataCleanupResult?['success'] != false) &&
      localDataCleanupError == null;

  /// Resumo da operação para logs/debugging
  Map<String, dynamic> toMap() {
    return {
      'completedAt': completedAt?.toIso8601String(),
      'firebaseDeleteSuccess': firebaseDeleteSuccess,
      'firebaseDeleteError': firebaseDeleteError,
      'localDataCleanupSuccess': localDataCleanupResult?['success'],
      'localDataCleanupError': localDataCleanupError,
      'dataCleanupVerified': dataCleanupVerified,
      'isSuccess': isSuccess,
      'dataStatsBeforeCleaning': dataStatsBeforeCleaning,
    };
  }

  @override
  String toString() {
    return 'AccountDeletionResult(isSuccess: $isSuccess, '
        'firebaseDeleteSuccess: $firebaseDeleteSuccess, '
        'localDataCleanupSuccess: ${localDataCleanupResult?['success']}, '
        'dataCleanupVerified: $dataCleanupVerified)';
  }
}
