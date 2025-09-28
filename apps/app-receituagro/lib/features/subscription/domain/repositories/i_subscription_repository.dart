import 'package:core/core.dart' hide ISubscriptionRepository;
import 'package:core/core.dart';

// Usando as entidades do core package

/// Interface local para repositório de assinaturas do ReceitaAgro
/// Estende funcionalidades específicas do app sobre o ISubscriptionRepository do core
abstract class IAppSubscriptionRepository {
  /// Verifica status premium específico do ReceitaAgro
  Future<Either<Failure, bool>> hasReceitaAgroSubscription();
  
  /// Busca produtos específicos do ReceitaAgro
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts();
  
  /// Verifica se usuário tem acesso a feature premium específica
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey);
  
  /// Busca informações de trial específicas do app
  Future<Either<Failure, bool>> hasActiveTrial();
  
  /// Cache local específico do app
  Future<Either<Failure, void>> cachePremiumStatus(bool isPremium);
  Future<Either<Failure, bool?>> getCachedPremiumStatus();
  Future<Either<Failure, void>> clearCache();
}