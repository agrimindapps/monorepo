import 'package:app_receituagro/database/repositories/subscription_local_repository.dart';
import 'package:core/core.dart' hide Column;

import '../../domain/repositories/i_subscription_repository.dart';
import '../../presentation/services/subscription_error_message_service.dart';

/// Implementação do repositório de subscription específico do ReceitaAgro
/// Utiliza o core ISubscriptionRepository e adiciona funcionalidades específicas do app

class SubscriptionRepositoryImpl implements IAppSubscriptionRepository {
  SubscriptionRepositoryImpl(
    this._coreRepository,
    this._localStorageRepository,
    this._errorService,
    this._subscriptionLocalRepository,
    this._authRepository,
  );

  final ISubscriptionRepository _coreRepository;
  final ILocalStorageRepository _localStorageRepository;
  final SubscriptionErrorMessageService _errorService;
  final SubscriptionLocalRepository _subscriptionLocalRepository;
  final IAuthRepository _authRepository;

  static const String _cacheKey = 'receituagro_premium_status';

  @override
  Future<Either<Failure, bool>> hasReceitaAgroSubscription() async {
    return await _coreRepository.hasReceitaAgroSubscription();
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts() async {
    return await _coreRepository.getReceitaAgroProducts();
  }

  @override
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey) async {
    final subscriptionResult = await hasReceitaAgroSubscription();

    return subscriptionResult.fold((failure) => Left(failure), (
      hasSubscription,
    ) {
      if (!hasSubscription) {
        return const Right(false);
      }
      final premiumFeatures = {
        'diagnosticos_avancados',
        'receitas_completas',
        'comentarios_privados',
        'export_data',
        'offline_mode',
        'priority_support',
      };

      final hasAccess = premiumFeatures.contains(featureKey)
          ? hasSubscription
          : true; // Features gratuitas

      return Right(hasAccess);
    });
  }

  @override
  Future<Either<Failure, bool>> hasActiveTrial() async {
    try {
      final subscription = await _coreRepository.getCurrentSubscription();
      return subscription.fold(
        (failure) => Left(failure),
        (sub) => Right(sub?.isTrialActive ?? false),
      );
    } catch (e) {
      return Left(
        SubscriptionUnknownFailure(
          _errorService.getVerifyTrialError(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cachePremiumStatus(bool isPremium) async {
    try {
      final data = {
        'isPremium': isPremium,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final result = await _localStorageRepository.save<Map<String, dynamic>>(
        key: _cacheKey,
        data: data,
      );
      return result.fold((failure) => Left(failure), (_) => const Right(null));
    } catch (e) {
      return Left(CacheFailure(_errorService.getCacheSaveError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool?>> getCachedPremiumStatus() async {
    try {
      // 1. Try to get from Drift (Secure & Offline)
      try {
        final user = await _authRepository.currentUser.first;
        if (user != null) {
          final localSub = await _subscriptionLocalRepository
              .getActiveSubscription(user.id);
          if (localSub != null) {
            final now = DateTime.now();
            if (localSub.expirationDate == null ||
                localSub.expirationDate!.isAfter(now)) {
              return const Right(true);
            }
          }
        }
      } catch (e) {
        // Ignore auth/drift errors and fall back to shared prefs
      }

      final result = await _localStorageRepository.get<Map<String, dynamic>>(
        key: _cacheKey,
      );

      return result.fold((failure) => Left(failure), (data) {
        if (data == null) {
          return const Right(null);
        }

        final timestamp = data['timestamp'] as int?;
        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final isExpired =
              DateTime.now().difference(cacheTime) > const Duration(minutes: 5);

          if (isExpired) {
            clearCache();
            return const Right(null);
          }
        }

        return Right(data['isPremium'] as bool?);
      });
    } catch (e) {
      return Left(CacheFailure(_errorService.getCacheReadError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final result = await _localStorageRepository.remove(key: _cacheKey);
      return result.fold((failure) => Left(failure), (_) => const Right(null));
    } catch (e) {
      return Left(CacheFailure(_errorService.getCacheClearError(e.toString())));
    }
  }
}
