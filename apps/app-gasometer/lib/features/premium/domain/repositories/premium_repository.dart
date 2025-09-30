import 'package:core/core.dart' as core;


import '../../data/services/premium_sync_service.dart';
import '../entities/premium_status.dart';

/// Repositório para operações premium específicas do GasOMeter
abstract class PremiumRepository {
  /// Stream com o status premium atual
  Stream<PremiumStatus> get premiumStatus;

  /// Verifica se o usuário tem premium ativo
  Future<Either<core.Failure, bool>> hasActivePremium();

  /// Obtém o status premium completo
  Future<Either<core.Failure, PremiumStatus>> getPremiumStatus();

  /// Obtém os produtos disponíveis para compra
  Future<Either<core.Failure, List<core.ProductInfo>>> getAvailableProducts();

  /// Inicia o processo de compra
  Future<Either<core.Failure, core.SubscriptionEntity>> purchasePremium({
    required String productId,
  });

  /// Restaura compras anteriores
  Future<Either<core.Failure, bool>> restorePurchases();

  /// Inicia trial gratuito (se elegível)
  Future<Either<core.Failure, bool>> startFreeTrial();

  /// Verifica elegibilidade para trial
  Future<Either<core.Failure, bool>> isEligibleForTrial();

  /// Define usuário no sistema de assinatura
  Future<Either<core.Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  });

  /// Obtém URL para gerenciar assinatura
  Future<Either<core.Failure, String?>> getManagementUrl();

  /// Verifica se pode usar uma feature específica
  Future<Either<core.Failure, bool>> canUseFeature(String featureId);

  /// Verifica limites de uso
  Future<Either<core.Failure, bool>> canAddVehicle(int currentCount);
  Future<Either<core.Failure, bool>> canAddFuelRecord(int currentCount);
  Future<Either<core.Failure, bool>> canAddMaintenanceRecord(int currentCount);

  /// Métodos para desenvolvimento

  /// Gera licença local para desenvolvimento
  Future<Either<core.Failure, void>> generateLocalLicense({
    int days = 30,
  });

  /// Revoga licença local
  Future<Either<core.Failure, void>> revokeLocalLicense();

  /// Verifica se tem licença local ativa
  Future<Either<core.Failure, bool>> hasActiveLocalLicense();

  /// Métodos de sincronização avançada

  /// Força sincronização imediata do status premium
  Future<Either<core.Failure, void>> forceSyncPremiumStatus();

  /// Stream de eventos de sincronização
  Stream<PremiumSyncEvent> get syncEvents;

  /// Processa webhook do RevenueCat
  Future<Either<core.Failure, void>> processWebhook({
    required Map<String, dynamic> payload,
    String? signature,
    String? secret,
  });
}