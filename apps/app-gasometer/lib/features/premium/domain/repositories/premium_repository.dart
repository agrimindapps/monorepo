import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/premium_status.dart';

/// Repositório para operações premium específicas do GasOMeter
abstract class PremiumRepository {
  /// Stream com o status premium atual
  Stream<PremiumStatus> get premiumStatus;

  /// Verifica se o usuário tem premium ativo
  Future<Either<Failure, bool>> hasActivePremium();

  /// Obtém o status premium completo
  Future<Either<Failure, PremiumStatus>> getPremiumStatus();

  /// Obtém os produtos disponíveis para compra
  Future<Either<Failure, List<core.ProductInfo>>> getAvailableProducts();

  /// Inicia o processo de compra
  Future<Either<Failure, core.SubscriptionEntity>> purchasePremium({
    required String productId,
  });

  /// Restaura compras anteriores
  Future<Either<Failure, bool>> restorePurchases();

  /// Inicia trial gratuito (se elegível)
  Future<Either<Failure, bool>> startFreeTrial();

  /// Verifica elegibilidade para trial
  Future<Either<Failure, bool>> isEligibleForTrial();

  /// Define usuário no sistema de assinatura
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  });

  /// Obtém URL para gerenciar assinatura
  Future<Either<Failure, String?>> getManagementUrl();

  /// Verifica se pode usar uma feature específica
  Future<Either<Failure, bool>> canUseFeature(String featureId);

  /// Verifica limites de uso
  Future<Either<Failure, bool>> canAddVehicle(int currentCount);
  Future<Either<Failure, bool>> canAddFuelRecord(int currentCount);
  Future<Either<Failure, bool>> canAddMaintenanceRecord(int currentCount);

  /// Métodos para desenvolvimento
  
  /// Gera licença local para desenvolvimento
  Future<Either<Failure, void>> generateLocalLicense({
    int days = 30,
  });

  /// Revoga licença local
  Future<Either<Failure, void>> revokeLocalLicense();

  /// Verifica se tem licença local ativa
  Future<Either<Failure, bool>> hasActiveLocalLicense();
}