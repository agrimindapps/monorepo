import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/subscription_entity.dart';

/// Interface para repositório de assinaturas
/// Segue padrões Clean Architecture - domain layer define contratos
/// Integra com RevenueCat para gerenciamento de assinaturas
abstract class ISubscriptionRepository {
  /// Inicializa SDK RevenueCat
  Future<Either<Failure, void>> initialize();
  
  /// Verifica status atual da assinatura
  Future<Either<Failure, PremiumUserEntity>> getCurrentUserStatus();
  
  /// Busca produtos de assinatura disponíveis
  Future<Either<Failure, List<SubscriptionProductEntity>>> getAvailableProducts();
  
  /// Inicia processo de compra de produto
  Future<Either<Failure, SubscriptionEntity>> purchaseProduct(String productId);
  
  /// Restaura compras anteriores
  Future<Either<Failure, PremiumUserEntity>> restorePurchases();
  
  /// Busca informações de assinatura específica
  Future<Either<Failure, SubscriptionEntity?>> getSubscriptionById(String subscriptionId);
  
  /// Verifica se usuário tem acesso a feature premium
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey);
  
  /// Cancela assinatura (direciona para store)
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId);
  
  /// Gerencia assinatura (direciona para store)
  Future<Either<Failure, void>> manageSubscription();
  
  /// Força atualização de status da assinatura
  Future<Either<Failure, PremiumUserEntity>> refreshSubscriptionStatus();
  
  /// Busca histórico de compras
  Future<Either<Failure, List<SubscriptionEntity>>> getPurchaseHistory();
  
  /// Configura callback para mudanças de status
  void setSubscriptionStatusListener(Function(PremiumUserEntity) onStatusChanged);
  
  /// Remove callback de mudanças
  void removeSubscriptionStatusListener();
  
  /// Verifica se tem trial ativo
  Future<Either<Failure, bool>> hasActiveTrial();
  
  /// Busca informações de trial
  Future<Either<Failure, SubscriptionEntity?>> getTrialInfo();
  
  /// Salva cache local do status premium
  Future<Either<Failure, void>> cachePremiumStatus(PremiumUserEntity user);
  
  /// Carrega cache local do status premium
  Future<Either<Failure, PremiumUserEntity?>> getCachedPremiumStatus();
  
  /// Limpa cache local
  Future<Either<Failure, void>> clearCache();
}