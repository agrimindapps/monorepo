import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../repositories/i_subscription_repository.dart';

/// Use case para verificar status premium do usuário ReceitaAgro
class GetUserPremiumStatusUseCase implements UseCase<bool, NoParams> {
  final IAppSubscriptionRepository repository;

  GetUserPremiumStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    // Primeiro tenta cache local para resposta rápida
    final cachedResult = await repository.getCachedPremiumStatus();
    
    return cachedResult.fold(
      (failure) => repository.hasReceitaAgroSubscription(),
      (cachedStatus) async {
        // Se tem cache, usa cache
        if (cachedStatus != null) {
          return Right(cachedStatus);
        }
        
        // Senão, busca status atualizado
        final freshResult = await repository.hasReceitaAgroSubscription();
        
        // Salva no cache se bem-sucedido
        await freshResult.fold(
          (failure) => Future<void>.value(),
          (isPremium) => repository.cachePremiumStatus(isPremium),
        );
        
        return freshResult;
      },
    );
  }
}

/// Use case para buscar produtos disponíveis do ReceitaAgro
class GetAvailableProductsUseCase implements UseCase<List<ProductInfo>, NoParams> {
  final IAppSubscriptionRepository repository;

  GetAvailableProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductInfo>>> call(NoParams params) async {
    return await repository.getReceitaAgroProducts();
  }
}

/// Parâmetros para o use case de compra
class PurchaseProductUseCaseParams {
  final String productId;
  final String? userId;
  final Map<String, dynamic>? metadata;

  const PurchaseProductUseCaseParams({
    required this.productId,
    this.userId,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseProductUseCaseParams &&
        other.productId == productId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(productId, userId);
}

/// Use case para comprar produto (usa core repository diretamente)
class PurchaseProductUseCase implements UseCase<SubscriptionEntity, PurchaseProductUseCaseParams> {
  final ISubscriptionRepository coreRepository;

  PurchaseProductUseCase(this.coreRepository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(PurchaseProductUseCaseParams params) async {
    if (params.productId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do produto não pode ser vazio'));
    }

    return await coreRepository.purchaseProduct(productId: params.productId);
  }
}

/// Use case para verificar acesso a feature
class CheckFeatureAccessUseCase implements UseCase<bool, String> {
  final IAppSubscriptionRepository repository;

  CheckFeatureAccessUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String featureKey) async {
    if (featureKey.trim().isEmpty) {
      return const Left(ValidationFailure('Chave da feature não pode ser vazia'));
    }

    return await repository.hasFeatureAccess(featureKey);
  }
}

/// Use case para restaurar compras (usa core repository)
class RestorePurchasesUseCase implements UseCase<List<SubscriptionEntity>, NoParams> {
  final ISubscriptionRepository coreRepository;
  final IAppSubscriptionRepository appRepository;

  RestorePurchasesUseCase(this.coreRepository, this.appRepository);

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> call(NoParams params) async {
    final result = await coreRepository.restorePurchases();
    
    // Atualiza cache local após restaurar
    await result.fold(
      (failure) => Future<void>.value(),
      (subscriptions) async {
        final hasReceitaAgro = subscriptions.any((s) => s.isReceitaAgroSubscription && s.isActive);
        await appRepository.cachePremiumStatus(hasReceitaAgro);
      },
    );
    
    return result;
  }
}

/// Use case para atualizar status da assinatura
class RefreshSubscriptionStatusUseCase implements UseCase<bool, NoParams> {
  final IAppSubscriptionRepository repository;

  RefreshSubscriptionStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    // Limpa cache e busca status atualizado
    await repository.clearCache();
    final result = await repository.hasReceitaAgroSubscription();
    
    // Atualiza cache após refresh
    await result.fold(
      (failure) => Future<void>.value(),
      (isPremium) => repository.cachePremiumStatus(isPremium),
    );
    
    return result;
  }
}

/// Use case para verificar trial ativo
class CheckActiveTrialUseCase implements UseCase<bool, NoParams> {
  final IAppSubscriptionRepository repository;

  CheckActiveTrialUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.hasActiveTrial();
  }
}

/// Use case para buscar informações de trial (usa core repository)
class GetTrialInfoUseCase implements UseCase<SubscriptionEntity?, NoParams> {
  final ISubscriptionRepository coreRepository;

  GetTrialInfoUseCase(this.coreRepository);

  @override
  Future<Either<Failure, SubscriptionEntity?>> call(NoParams params) async {
    final result = await coreRepository.getCurrentSubscription();
    return result.map((subscription) => 
      subscription?.isInTrial == true ? subscription : null
    );
  }
}

/// Use case para gerenciar assinatura (usa core repository)
class ManageSubscriptionUseCase implements UseCase<String?, NoParams> {
  final ISubscriptionRepository coreRepository;

  ManageSubscriptionUseCase(this.coreRepository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await coreRepository.getManagementUrl();
  }
}

/// Use case para cancelar assinatura (usa core repository)
class CancelSubscriptionUseCase implements UseCase<void, String?> {
  final ISubscriptionRepository coreRepository;

  CancelSubscriptionUseCase(this.coreRepository);

  @override
  Future<Either<Failure, void>> call(String? reason) async {
    return await coreRepository.cancelSubscription(reason: reason);
  }
}

/// Use case para buscar histórico de compras (usa core repository)
class GetPurchaseHistoryUseCase implements UseCase<List<SubscriptionEntity>, NoParams> {
  final ISubscriptionRepository coreRepository;

  GetPurchaseHistoryUseCase(this.coreRepository);

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> call(NoParams params) async {
    return await coreRepository.getUserSubscriptions();
  }
}