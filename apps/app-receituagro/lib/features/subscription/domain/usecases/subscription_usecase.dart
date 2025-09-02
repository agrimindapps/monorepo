import 'package:core/core.dart' hide ISubscriptionRepository, SubscriptionEntity;
import 'package:dartz/dartz.dart';
import '../entities/subscription_entity.dart';
import '../repositories/i_subscription_repository.dart';

/// Use case para verificar status premium do usuário
class GetUserPremiumStatusUseCase implements UseCase<PremiumUserEntity, NoParams> {
  final ISubscriptionRepository repository;

  GetUserPremiumStatusUseCase(this.repository);

  @override
  Future<Either<Failure, PremiumUserEntity>> call(NoParams params) async {
    // Primeiro tenta cache local para resposta rápida
    final cachedResult = await repository.getCachedPremiumStatus();
    
    return cachedResult.fold(
      (failure) => repository.getCurrentUserStatus(),
      (cachedStatus) async {
        // Se tem cache válido (menos de 5 minutos), usa cache
        if (cachedStatus != null && 
            cachedStatus.lastSubscriptionCheck != null &&
            DateTime.now().difference(cachedStatus.lastSubscriptionCheck!) < 
            const Duration(minutes: 5)) {
          return Right(cachedStatus);
        }
        
        // Senão, busca status atualizado
        final freshResult = await repository.getCurrentUserStatus();
        
        // Salva no cache se bem-sucedido
        freshResult.fold(
          (failure) => null,
          (freshStatus) => repository.cachePremiumStatus(freshStatus),
        );
        
        return freshResult;
      },
    );
  }
}

/// Use case para buscar produtos disponíveis
class GetAvailableProductsUseCase implements UseCase<List<SubscriptionProductEntity>, NoParams> {
  final ISubscriptionRepository repository;

  GetAvailableProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionProductEntity>>> call(NoParams params) async {
    return await repository.getAvailableProducts();
  }
}

/// Use case para comprar produto
class PurchaseProductUseCase implements UseCase<SubscriptionEntity, String> {
  final ISubscriptionRepository repository;

  PurchaseProductUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(String productId) async {
    if (productId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do produto não pode ser vazio'));
    }

    return await repository.purchaseProduct(productId);
  }
}

/// Use case para verificar acesso a feature
class CheckFeatureAccessUseCase implements UseCase<bool, String> {
  final ISubscriptionRepository repository;

  CheckFeatureAccessUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String featureKey) async {
    if (featureKey.trim().isEmpty) {
      return const Left(ValidationFailure('Chave da feature não pode ser vazia'));
    }

    return await repository.hasFeatureAccess(featureKey);
  }
}

/// Use case para restaurar compras
class RestorePurchasesUseCase implements UseCase<PremiumUserEntity, NoParams> {
  final ISubscriptionRepository repository;

  RestorePurchasesUseCase(this.repository);

  @override
  Future<Either<Failure, PremiumUserEntity>> call(NoParams params) async {
    final result = await repository.restorePurchases();
    
    // Atualiza cache após restaurar
    result.fold(
      (failure) => null,
      (user) => repository.cachePremiumStatus(user),
    );
    
    return result;
  }
}

/// Use case para atualizar status da assinatura
class RefreshSubscriptionStatusUseCase implements UseCase<PremiumUserEntity, NoParams> {
  final ISubscriptionRepository repository;

  RefreshSubscriptionStatusUseCase(this.repository);

  @override
  Future<Either<Failure, PremiumUserEntity>> call(NoParams params) async {
    final result = await repository.refreshSubscriptionStatus();
    
    // Atualiza cache após refresh
    result.fold(
      (failure) => null,
      (user) => repository.cachePremiumStatus(user),
    );
    
    return result;
  }
}

/// Use case para verificar trial ativo
class CheckActiveTrialUseCase implements UseCase<bool, NoParams> {
  final ISubscriptionRepository repository;

  CheckActiveTrialUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.hasActiveTrial();
  }
}

/// Use case para buscar informações de trial
class GetTrialInfoUseCase implements UseCase<SubscriptionEntity?, NoParams> {
  final ISubscriptionRepository repository;

  GetTrialInfoUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity?>> call(NoParams params) async {
    return await repository.getTrialInfo();
  }
}

/// Use case para gerenciar assinatura
class ManageSubscriptionUseCase implements UseCase<void, NoParams> {
  final ISubscriptionRepository repository;

  ManageSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.manageSubscription();
  }
}

/// Use case para cancelar assinatura
class CancelSubscriptionUseCase implements UseCase<void, String> {
  final ISubscriptionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String subscriptionId) async {
    if (subscriptionId.trim().isEmpty) {
      return const Left(ValidationFailure('ID da assinatura não pode ser vazio'));
    }

    return await repository.cancelSubscription(subscriptionId);
  }
}

/// Use case para buscar histórico de compras
class GetPurchaseHistoryUseCase implements UseCase<List<SubscriptionEntity>, NoParams> {
  final ISubscriptionRepository repository;

  GetPurchaseHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> call(NoParams params) async {
    return await repository.getPurchaseHistory();
  }
}