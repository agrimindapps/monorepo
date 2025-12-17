import 'package:core/core.dart' hide SubscriptionRepository;

import '../../../../core/auth/auth_service.dart';
import '../../../../core/constants/product_ids.dart';
import '../../../../core/constants/subscription_features.dart';
import '../../../../database/repositories/subscription_local_repository.dart';
import '../../domain/repositories/i_app_subscription_repository.dart';
import '../services/subscription_error_handling_service.dart';

/// Implementação do repositório de subscription específico do Petiveti
/// Utiliza o core ISubscriptionRepository (RevenueCat) e adiciona funcionalidades específicas do app
class SubscriptionRepositoryImpl implements IAppSubscriptionRepository {
  SubscriptionRepositoryImpl(
    this._coreRepository,
    this._localStorageRepository,
    this._errorService,
    this._subscriptionLocalRepository,
    this._authService,
  );

  final ISubscriptionRepository _coreRepository;
  final ILocalStorageRepository _localStorageRepository;
  final SubscriptionErrorHandlingService _errorService;
  final SubscriptionLocalRepository? _subscriptionLocalRepository;
  final AuthService? _authService;

  static const String _cacheKey = 'petiveti_premium_status';

  @override
  Future<Either<Failure, bool>> hasPetivetiSubscription() async {
    return await _coreRepository.hasActiveSubscription();
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getPetivetiProducts() async {
    return await _coreRepository.getAvailableProducts(
      productIds: [
        PetivetiProducts.monthlyPremium,
        PetivetiProducts.yearlyPremium,
        PetivetiProducts.lifetime,
      ],
    );
  }

  @override
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey) async {
    // Free features sempre disponíveis
    if (PetivetiFeatures.isFreeFeature(featureKey)) {
      return const Right(true);
    }

    // Premium features requerem subscription
    if (!PetivetiFeatures.isPremiumFeature(featureKey)) {
      return const Right(false); // Feature desconhecida
    }

    final subscriptionResult = await hasPetivetiSubscription();

    return subscriptionResult.fold(
      (failure) => Left(failure),
      (hasSubscription) => Right(hasSubscription),
    );
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
        SubscriptionUnknownFailure('Erro ao verificar trial: ${e.toString()}'),
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
      return Left(CacheFailure('Erro ao salvar cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool?>> getCachedPremiumStatus() async {
    try {
      // Layer 1: Try Drift database (Secure & Offline)
      if (_authService != null && _subscriptionLocalRepository != null) {
        try {
          final userResult = await _authService.getCurrentUser();
          await userResult.fold(
            (failure) async {
              // Ignore auth errors, fall through to layer 2
            },
            (user) async {
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
            },
          );
        } catch (e) {
          // Ignore auth/drift errors and fall back to shared prefs
        }
      }

      // Layer 2: Try SharedPreferences (fallback)
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
      return Left(CacheFailure('Erro ao ler cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final result = await _localStorageRepository.remove(key: _cacheKey);
      return result.fold((failure) => Left(failure), (_) => const Right(null));
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: ${e.toString()}'));
    }
  }
}
