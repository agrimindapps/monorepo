import 'package:core/core.dart';

/// Interface app-specific para repositório de assinaturas do Petiveti
/// Estende funcionalidades sobre o ISubscriptionRepository do core
abstract class IAppSubscriptionRepository {
  /// Verifica status premium específico do Petiveti
  Future<Either<Failure, bool>> hasPetivetiSubscription();

  /// Busca produtos específicos do Petiveti
  Future<Either<Failure, List<ProductInfo>>> getPetivetiProducts();

  /// Verifica se usuário tem acesso a feature premium específica
  /// Features premium: unlimited_animals, cloud_sync, advanced_reports,
  /// medication_reminders, vet_integration, export_data
  Future<Either<Failure, bool>> hasFeatureAccess(String featureKey);

  /// Busca informações de trial específicas do app
  Future<Either<Failure, bool>> hasActiveTrial();

  /// Cache local específico do app (multi-layer: Drift → SharedPrefs)
  Future<Either<Failure, void>> cachePremiumStatus(bool isPremium);
  Future<Either<Failure, bool?>> getCachedPremiumStatus();
  Future<Either<Failure, void>> clearCache();
}
