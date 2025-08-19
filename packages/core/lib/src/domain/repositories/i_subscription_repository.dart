import 'package:dartz/dartz.dart';
import '../entities/subscription_entity.dart';
import '../../shared/utils/failure.dart';

/// Interface do repositório de assinaturas
/// Define os contratos para operações de assinaturas via RevenueCat
abstract class ISubscriptionRepository {
  /// Stream com o status atual da assinatura do usuário
  Stream<SubscriptionEntity?> get subscriptionStatus;

  /// Verifica se o usuário tem uma assinatura ativa
  Future<Either<Failure, bool>> hasActiveSubscription();

  /// Obtém informações detalhadas da assinatura atual
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription();

  /// Obtém todas as assinaturas do usuário (histórico)
  Future<Either<Failure, List<SubscriptionEntity>>> getUserSubscriptions();

  /// Obtém produtos disponíveis para compra
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts({
    required List<String> productIds,
  });

  /// Inicia o processo de compra de um produto
  Future<Either<Failure, SubscriptionEntity>> purchaseProduct({
    required String productId,
  });

  /// Restaura compras anteriores (iOS principalmente)
  Future<Either<Failure, List<SubscriptionEntity>>> restorePurchases();

  /// Configura/identifica o usuário no RevenueCat
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  });

  /// Define atributos do usuário para segmentação
  Future<Either<Failure, void>> setUserAttributes({
    required Map<String, String> attributes,
  });

  /// Verifica elegibilidade para trial
  Future<Either<Failure, bool>> isEligibleForTrial({
    required String productId,
  });

  /// Obtém URL para gerenciar assinatura (redirect para loja)
  Future<Either<Failure, String?>> getManagementUrl();

  /// Cancela assinatura (onde aplicável)
  Future<Either<Failure, void>> cancelSubscription({
    String? reason,
  });

  /// Verifica status de produtos específicos do app
  
  /// Para o app Plantis
  Future<Either<Failure, bool>> hasPlantisSubscription();
  
  /// Para o app ReceitaAgro
  Future<Either<Failure, bool>> hasReceitaAgroSubscription();

  /// Produtos específicos por app
  Future<Either<Failure, List<ProductInfo>>> getPlantisProducts();
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts();
  
  /// Para o app GasOMeter
  Future<Either<Failure, bool>> hasGasometerSubscription();
  Future<Either<Failure, List<ProductInfo>>> getGasometerProducts();
}

/// Informações de um produto disponível para compra
class ProductInfo {
  const ProductInfo({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    this.introPrice,
    this.freeTrialPeriod,
    this.subscriptionPeriod,
  });

  /// ID do produto
  final String productId;

  /// Título do produto
  final String title;

  /// Descrição do produto
  final String description;

  /// Preço em micros (preço * 1000000)
  final double price;

  /// Preço formatado como string (ex: "R$ 9,90")
  final String priceString;

  /// Código da moeda (ex: "BRL", "USD")
  final String currencyCode;

  /// Preço promocional/introdutório
  final IntroPrice? introPrice;

  /// Período de trial gratuito
  final String? freeTrialPeriod;

  /// Período da assinatura (mensal, anual, etc.)
  final String? subscriptionPeriod;

  /// Se é um produto de assinatura
  bool get isSubscription => subscriptionPeriod != null;

  /// Se tem trial gratuito
  bool get hasFreeTrial => freeTrialPeriod != null;

  /// Se tem preço promocional
  bool get hasIntroPrice => introPrice != null;
}

/// Informações de preço promocional/introdutório
class IntroPrice {
  const IntroPrice({
    required this.price,
    required this.priceString,
    required this.period,
    required this.cycles,
  });

  /// Preço promocional
  final double price;

  /// Preço promocional formatado
  final String priceString;

  /// Período do preço promocional
  final String period;

  /// Quantos ciclos o preço promocional dura
  final int cycles;
}