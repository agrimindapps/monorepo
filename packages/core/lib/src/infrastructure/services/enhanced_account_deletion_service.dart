import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/contracts/i_app_data_cleaner.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../shared/utils/failure.dart';
import 'account_deletion_rate_limiter.dart';
import 'firestore_deletion_service.dart';
import 'revenuecat_cancellation_service.dart';

/// Serviço completo de exclusão de conta com todos os recursos de segurança
/// - Re-autenticação obrigatória
/// - Rate limiting
/// - Cleanup Firestore/Storage
/// - Cancelamento RevenueCat
/// - Cleanup local via IAppDataCleaner
/// - Auditoria e logging
class EnhancedAccountDeletionService {
  final IAuthRepository _authRepository;
  final IAppDataCleaner? _appDataCleaner;
  final FirestoreDeletionService _firestoreDeletion;
  final RevenueCatCancellationService _revenueCatCancellation;
  final AccountDeletionRateLimiter _rateLimiter;

  EnhancedAccountDeletionService({
    required IAuthRepository authRepository,
    IAppDataCleaner? appDataCleaner,
    FirestoreDeletionService? firestoreDeletion,
    RevenueCatCancellationService? revenueCatCancellation,
    AccountDeletionRateLimiter? rateLimiter,
  }) : _authRepository = authRepository,
       _appDataCleaner = appDataCleaner,
       _firestoreDeletion = firestoreDeletion ?? FirestoreDeletionService(),
       _revenueCatCancellation =
           revenueCatCancellation ?? RevenueCatCancellationService(),
       _rateLimiter = rateLimiter ?? AccountDeletionRateLimiter();

  /// Executa exclusão completa da conta com todas as verificações de segurança
  ///
  /// [password] Senha para re-autenticação (obrigatória para contas email/senha)
  /// [userId] ID do usuário (obtido automaticamente se não fornecido)
  /// [isAnonymous] Se é usuário anônimo (obtido automaticamente se não fornecido)
  Future<Either<Failure, EnhancedDeletionResult>> deleteAccount({
    String? password,
    String? userId,
    bool? isAnonymous,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ EnhancedAccountDeletion: Starting account deletion');
      }

      final result = EnhancedDeletionResult();
      final startTime = DateTime.now();
      result.steps.add('Verificando autenticação...');
      final isLoggedIn = await _authRepository.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(
          AuthenticationFailure('Usuário não está autenticado'),
        );
      }
      String? currentUserId = userId;
      if (currentUserId == null) {
        await for (final user in _authRepository.currentUser) {
          if (user != null) {
            currentUserId = user.id;
            isAnonymous ??= user.isAnonymous;
            break;
          }
        }
      }

      if (currentUserId == null) {
        return const Left(
          AuthenticationFailure('Não foi possível obter ID do usuário'),
        );
      }

      result.userId = currentUserId;
      if (isAnonymous == true) {
        if (kDebugMode) {
          debugPrint('❌ Anonymous users cannot delete account');
        }
        return const Left(
          ValidationFailure(
            'Usuários anônimos não podem excluir conta. '
            'Crie uma conta permanente primeiro.',
          ),
        );
      }
      result.steps.add('Verificando rate limiting...');
      if (!_rateLimiter.canAttemptDeletion(currentUserId)) {
        final cooldown = _rateLimiter.getRemainingCooldown(currentUserId);
        final minutes = cooldown?.inMinutes ?? 0;

        if (kDebugMode) {
          debugPrint('🔒 Rate limit exceeded for user $currentUserId');
        }

        return Left(
          ValidationFailure(
            'Muitas tentativas de exclusão. '
            'Aguarde $minutes minutos antes de tentar novamente.',
          ),
        );
      }
      _rateLimiter.recordDeletionAttempt(currentUserId);
      if (password != null && password.isNotEmpty) {
        result.steps.add('Re-autenticando usuário...');
        if (kDebugMode) {
          debugPrint('🔐 Re-authenticating user before deletion');
        }

        final reauthResult = await _authRepository.reauthenticate(
          password: password,
        );

        final reauthSuccess = reauthResult.fold((failure) {
          result.reauthenticationError = failure.message;
          return false;
        }, (_) => true);

        result.reauthenticationSuccess = reauthSuccess;

        if (!reauthSuccess) {
          if (kDebugMode) {
            debugPrint('❌ Re-authentication failed');
          }

          return const Left(
            AuthenticationFailure('Senha incorreta. Tente novamente.'),
          );
        }

        if (kDebugMode) {
          debugPrint('✅ Re-authentication successful');
        }
      } else {
        return const Left(
          ValidationFailure('Senha obrigatória para exclusão de conta.'),
        );
      }
      result.steps.add('Verificando assinaturas...');
      try {
        if (kDebugMode) {
          debugPrint('💳 Checking RevenueCat subscriptions');
        }

        final cancellationResult = await _revenueCatCancellation
            .handleSubscriptionCancellation();

        cancellationResult.fold(
          (error) {
            result.subscriptionCancellationError = error.message;
            if (kDebugMode) {
              debugPrint('⚠️ Subscription check failed: ${error.message}');
            }
          },
          (cancelResult) {
            result.subscriptionCancellationResult = cancelResult;
            if (kDebugMode) {
              debugPrint(
                '✅ Subscription check completed: ${cancelResult.message}',
              );
            }
          },
        );
      } catch (e) {
        result.subscriptionCancellationError = e.toString();
        if (kDebugMode) {
          debugPrint('⚠️ Error checking subscriptions: $e');
        }
      }
      result.steps.add('Limpando dados na nuvem...');
      try {
        if (kDebugMode) {
          debugPrint('☁️ Deleting Firestore/Storage data');
        }

        final firestoreResult = await _firestoreDeletion.deleteUserData(
          userId: currentUserId,
        );

        firestoreResult.fold(
          (error) {
            result.firestoreDeletionError = error.message;
            if (kDebugMode) {
              debugPrint('⚠️ Firestore deletion failed: ${error.message}');
            }
          },
          (deleteResult) {
            result.firestoreDeletionResult = deleteResult;
            if (kDebugMode) {
              debugPrint(
                '✅ Firestore data deleted: ${deleteResult.totalDocumentsDeleted} docs',
              );
            }
          },
        );
      } catch (e) {
        result.firestoreDeletionError = e.toString();
        if (kDebugMode) {
          debugPrint('⚠️ Error deleting Firestore data: $e');
        }
      }
      if (_appDataCleaner != null) {
        result.steps.add('Limpando dados locais...');
        try {
          if (kDebugMode) {
            debugPrint('🧹 Cleaning local app data');
          }

          final statsBeforeCleaning = await _appDataCleaner
              .getDataStatsBeforeCleaning();
          result.dataStatsBeforeCleaning = statsBeforeCleaning;

          final cleanupResult = await _appDataCleaner.clearAllAppData();
          result.localDataCleanupResult = cleanupResult;

          final verificationResult = await _appDataCleaner.verifyDataCleanup();
          result.dataCleanupVerified = verificationResult;

          if (kDebugMode) {
            debugPrint('✅ Local data cleaned successfully');
          }
        } catch (e) {
          result.localDataCleanupError = e.toString();
          if (kDebugMode) {
            debugPrint('⚠️ Error cleaning local data: $e');
          }
        }
      }
      result.steps.add('Excluindo conta do Firebase...');
      if (kDebugMode) {
        debugPrint('🔥 Deleting Firebase Auth account');
      }

      final firebaseResult = await _authRepository.deleteAccount();

      final deletionSuccess = firebaseResult.fold(
        (failure) {
          result.firebaseDeleteSuccess = false;
          result.firebaseDeleteError = failure.message;
          return false;
        },
        (_) {
          result.firebaseDeleteSuccess = true;
          return true;
        },
      );

      if (!deletionSuccess) {
        if (kDebugMode) {
          debugPrint(
            '❌ Firebase Auth deletion failed: ${result.firebaseDeleteError}',
          );
        }

        return Left(
          AuthenticationFailure(
            result.firebaseDeleteError ?? 'Erro ao deletar conta',
          ),
        );
      }
      _rateLimiter.clearAttempts(currentUserId);

      result.completedAt = DateTime.now();
      result.totalDurationSeconds = result.completedAt!
          .difference(startTime)
          .inSeconds;

      if (kDebugMode) {
        debugPrint('✅ Account deletion completed successfully');
        debugPrint('   Duration: ${result.totalDurationSeconds}s');
        debugPrint('   Firebase Auth: ✅');
        debugPrint(
          '   Firestore: ${result.firestoreDeletionResult?.isSuccess ?? false ? "✅" : "⚠️"}',
        );
        debugPrint(
          '   Local Data: ${result.localDataCleanupResult?["success"] == true ? "✅" : "⚠️"}',
        );
        debugPrint(
          '   Subscriptions: ${result.subscriptionCancellationResult?.isSuccess ?? true ? "✅" : "⚠️"}',
        );
      }

      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error during account deletion: $e');
      }

      return Left(UnexpectedFailure('Erro inesperado durante exclusão: $e'));
    }
  }

  /// Obtém preview detalhado do que será excluído
  /// Útil para exibir confirmação ao usuário
  Future<Either<Failure, Map<String, dynamic>>> getAccountDeletionPreview(
    String userId,
  ) async {
    try {
      final preview = <String, dynamic>{
        'userId': userId,
        'appName': _appDataCleaner?.appName ?? 'Unknown',
        'timestamp': DateTime.now().toIso8601String(),
      };
      if (_appDataCleaner != null) {
        try {
          final hasData = await _appDataCleaner.hasDataToClear();
          final stats = await _appDataCleaner.getDataStatsBeforeCleaning();
          final categories = _appDataCleaner.getAvailableCategories();

          preview['localData'] = {
            'hasData': hasData,
            'stats': stats,
            'categories': categories,
          };
        } catch (e) {
          preview['localDataError'] = e.toString();
        }
      }
      try {
        final firestoreStats = await _firestoreDeletion.getDataStats(userId);
        preview['cloudData'] = firestoreStats;
      } catch (e) {
        preview['cloudDataError'] = e.toString();
      }
      try {
        final subscriptionDetails = await _revenueCatCancellation
            .getSubscriptionDetails();
        subscriptionDetails.fold(
          (error) => preview['subscriptionError'] = error.message,
          (details) => preview['subscription'] = details,
        );
      } catch (e) {
        preview['subscriptionError'] = e.toString();
      }
      preview['rateLimitStatus'] = _rateLimiter.getStats(userId);

      return Right(preview);
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao obter preview: $e'));
    }
  }

  /// Verifica se usuário pode deletar conta (não está bloqueado por rate limit)
  bool canDeleteAccount(String userId) {
    return _rateLimiter.canAttemptDeletion(userId);
  }

  /// Obtém tempo de cooldown restante se bloqueado
  Duration? getRemainingCooldown(String userId) {
    return _rateLimiter.getRemainingCooldown(userId);
  }
}

/// Resultado detalhado da exclusão completa de conta
class EnhancedDeletionResult {
  String? userId;
  DateTime? completedAt;
  int? totalDurationSeconds;
  List<String> steps = [];
  bool reauthenticationSuccess = false;
  String? reauthenticationError;
  bool firebaseDeleteSuccess = false;
  String? firebaseDeleteError;
  FirestoreDeletionResult? firestoreDeletionResult;
  String? firestoreDeletionError;
  SubscriptionCancellationResult? subscriptionCancellationResult;
  String? subscriptionCancellationError;
  Map<String, dynamic>? localDataCleanupResult;
  String? localDataCleanupError;
  bool dataCleanupVerified = false;
  Map<String, dynamic>? dataStatsBeforeCleaning;

  /// Indica se a operação foi completamente bem-sucedida
  bool get isSuccess =>
      firebaseDeleteSuccess &&
      reauthenticationSuccess &&
      (firestoreDeletionResult?.isSuccess ?? true) &&
      (localDataCleanupResult?['success'] != false);

  /// Indica se houve sucesso parcial (Firebase deletado mas alguns cleanups falharam)
  bool get isPartialSuccess => firebaseDeleteSuccess && (!isSuccess);

  /// Retorna mensagem amigável do resultado
  String get userMessage {
    if (isSuccess) {
      return 'Conta excluída com sucesso. '
          '${subscriptionCancellationResult?.hadActiveSubscription == true ? "Lembre-se de cancelar sua assinatura manualmente." : ""}';
    } else if (isPartialSuccess) {
      return 'Conta excluída, mas alguns dados não puderam ser removidos completamente. '
          'Entre em contato com o suporte se necessário.';
    } else {
      return firebaseDeleteError ??
          reauthenticationError ??
          'Erro ao excluir conta.';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedAt': completedAt?.toIso8601String(),
      'totalDurationSeconds': totalDurationSeconds,
      'steps': steps,
      'reauthenticationSuccess': reauthenticationSuccess,
      'reauthenticationError': reauthenticationError,
      'firebaseDeleteSuccess': firebaseDeleteSuccess,
      'firebaseDeleteError': firebaseDeleteError,
      'firestoreDeletion': firestoreDeletionResult?.toMap(),
      'firestoreDeletionError': firestoreDeletionError,
      'subscriptionCancellation': subscriptionCancellationResult?.toMap(),
      'subscriptionCancellationError': subscriptionCancellationError,
      'localDataCleanup': localDataCleanupResult,
      'localDataCleanupError': localDataCleanupError,
      'dataCleanupVerified': dataCleanupVerified,
      'dataStatsBeforeCleaning': dataStatsBeforeCleaning,
      'isSuccess': isSuccess,
      'isPartialSuccess': isPartialSuccess,
    };
  }

  @override
  String toString() {
    return 'EnhancedDeletionResult('
        'isSuccess: $isSuccess, '
        'duration: ${totalDurationSeconds}s, '
        'steps: ${steps.length})';
  }
}
