import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../domain/repositories/i_subscription_repository.dart';

/// Implementação do repositório de subscription específico do ReceitaAgro
/// Utiliza o core ISubscriptionRepository e adiciona funcionalidades específicas do app
class SubscriptionRepositoryImpl implements IAppSubscriptionRepository {
  final ISubscriptionRepository _coreRepository;
  final ILocalStorageRepository _localStorageRepository;

  static const String _cacheKey = 'receituagro_premium_status';

  SubscriptionRepositoryImpl(this._coreRepository, this._localStorageRepository);

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
    // Primeiro verifica se tem assinatura ativa
    final subscriptionResult = await hasReceitaAgroSubscription();
    
    return subscriptionResult.fold(
      (failure) => Left(failure),
      (hasSubscription) {
        if (!hasSubscription) {
          return const Right(false);
        }

        // Features específicas do ReceitaAgro que requerem premium
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
      },
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
      return Left(CacheFailure('Erro ao verificar trial: ${e.toString()}'));
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
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool?>> getCachedPremiumStatus() async {
    try {
      final result = await _localStorageRepository.get<Map<String, dynamic>>(
        key: _cacheKey,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (data) {
          if (data == null) {
            return const Right(null);
          }

          final timestamp = data['timestamp'] as int?;
          
          // Cache válido por 5 minutos
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final isExpired = DateTime.now().difference(cacheTime) > 
                const Duration(minutes: 5);
            
            if (isExpired) {
              clearCache();
              return const Right(null);
            }
          }

          return Right(data['isPremium'] as bool?);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao ler cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final result = await _localStorageRepository.remove(
        key: _cacheKey,
      );
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: ${e.toString()}'));
    }
  }
}