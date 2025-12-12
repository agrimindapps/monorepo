import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Either, Failure, ProductInfo;

import '../entities/premium_status.dart';

/// Repositório para operações premium específicas do Plantis
///
/// Esta abstração define o contrato para operações premium do app,
/// seguindo o princípio de Dependency Inversion (Clean Architecture).
abstract class PremiumRepository {
  /// Stream com o status premium atual
  ///
  /// Emite atualizações sempre que o status premium mudar
  /// (compra, expiração, cancelamento, etc)
  Stream<PremiumStatus> get premiumStatus;

  /// Verifica se o usuário tem premium ativo
  ///
  /// Retorna true se:
  /// - Tem assinatura ativa não expirada
  /// - Está em trial ativo
  /// - Tem licença local de desenvolvimento ativa
  Future<Either<Failure, bool>> hasActivePremium();

  /// Obtém o status premium completo
  ///
  /// Inclui:
  /// - Features disponíveis
  /// - Limites de uso
  /// - Informações da assinatura
  /// - Dias restantes até expiração
  Future<Either<Failure, PremiumStatus>> getPremiumStatus();

  /// Obtém os produtos disponíveis para compra
  ///
  /// Lista os produtos de assinatura configurados no RevenueCat
  /// específicos do app Plantis
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts();

  /// Inicia o processo de compra de um produto premium
  ///
  /// [productId] - ID do produto no RevenueCat
  ///
  /// Retorna a assinatura criada em caso de sucesso
  Future<Either<Failure, core.SubscriptionEntity>> purchasePremium({
    required String productId,
  });

  /// Restaura compras anteriores do usuário
  ///
  /// Útil quando:
  /// - Usuário reinstalou o app
  /// - Trocou de dispositivo
  /// - Perdeu acesso à assinatura
  ///
  /// Retorna true se encontrou e restaurou assinaturas
  Future<Either<Failure, bool>> restorePurchases();

  /// Define usuário no sistema de assinatura
  ///
  /// [userId] - ID único do usuário (Firebase Auth UID)
  /// [attributes] - Atributos opcionais para analytics
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  });

  /// Sincroniza o status premium com o servidor
  ///
  /// Força uma verificação no RevenueCat e atualiza o cache local
  Future<Either<Failure, PremiumStatus>> syncPremiumStatus();
}
